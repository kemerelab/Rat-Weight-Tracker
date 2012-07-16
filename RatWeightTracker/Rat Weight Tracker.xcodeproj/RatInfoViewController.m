//
//  RatInfoViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RatInfoViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "MBProgressHUD.h"


@implementation RatInfoViewController

@synthesize utility;
@synthesize ratNameLabel, entriesTable, notesView;
@synthesize service, worksheet;
@synthesize weightEntries;
@synthesize graphView, weightGraph, pelletGraph;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.ratNameLabel.text = name;
    
    self.entriesTable.layer.borderWidth = 1.0;
    
    self.notesView.layer.borderWidth = 1.0;
    self.notesView.text = @"Notes...";
    
    // Send cell query for that rat's data...
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Send query for dates -> must be completed first to create dictionaries
    [self.utility fromWorksheet:@"Weights" fetchColumn:1 selector:@selector(ticket:finishedWithDateFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithDateFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    for (int i = 0; i < [[feed entries] count]; i++) {
        
        NSString *date = [[[[feed entries] objectAtIndex:i] cell] resultString];
        
        if ([date length] == 0) break;
        
        // index indicates relative row
        [self.weightEntries addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  date, @"date", nil]];
    }
    
    NSLog(@"%@", self.weightEntries);
    
    [self.utility fromWorksheet:@"Weights" fetchColumn:ratColumn selector:@selector(ticket:finsihedWithWeightFeed:error:)];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finsihedWithWeightFeed:(GDataFeedSpreadsheetCell*) feed
         error:(NSError *)error {
    
    NSLog(@"Starting Weights. %d", [[feed entries] count]);
    
    for (int i = 0; i < [weightEntries count]; i++) {
        
        NSString *weight = [[[[feed entries] objectAtIndex:i] cell] resultString];
        NSMutableDictionary* prev = [weightEntries objectAtIndex:i];
        NSLog(@"weight = %@ prev = %@", weight, prev);
        [prev setObject:weight forKey:@"weight"];
    }
    
    NSLog(@"[RatInfo] Finished adding weights for %@", ratNameLabel.text);
    
    [self.utility fromWorksheet:@"Pellets" fetchColumn:ratColumn selector:@selector(ticket:finishedWithPelletFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithPelletFeed:(GDataFeedSpreadsheetCell*) feed
         error:(NSError *)error {
    
    NSLog(@"Starting pellets..");
    
    for (int i = 0; i < [weightEntries count]; i++){
        
        NSString *pellets = [[[[feed entries] objectAtIndex:i] cell] resultString];
        NSMutableDictionary* prev = [weightEntries objectAtIndex:i];
        [prev setObject:pellets forKey:@"pellets"];
    }
    
    NSLog(@"[RatInfo] Finished adding pellets for %@", ratNameLabel.text);
    
    [self.utility fromWorksheet:@"Notes" fetchColumn:ratColumn selector:@selector(ticket:finishedWithNoteFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithNoteFeed:(GDataFeedSpreadsheetCell*) feed
         error:(NSError *)error {
    
    NSLog(@"starting notes...");
    
    for (int i = 0; i < [weightEntries count]; i++){
        
        NSString *note = [[[[feed entries] objectAtIndex:i] cell] resultString];
        NSMutableDictionary* prev = [weightEntries objectAtIndex:i];
        [prev setObject:note forKey:@"notes"];
    }
    
    NSLog(@"[RatInfo] Finished adding notes for %@", ratNameLabel.text);  
    
    [self drawGraph];

    [self.entriesTable reloadData]; 
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) drawGraph {
    
    
    NSLog(@"Starting to draw graph..");
    
    NSDateFormatter* dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"M/d/yyyy"];
    NSDate *refDate = [dateformat dateFromString:[[weightEntries objectAtIndex:0] objectForKey:@"date"]];
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    // Create graph from theme
    weightGraph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[weightGraph applyTheme:theme];
    weightGraph.name = @"Weights";
    graphView.hostedGraph = weightGraph;
    
    // Setup scatter plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)weightGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
	NSTimeInterval xLow		  = 0.0f;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow) length:CPTDecimalFromFloat(oneDay * 7)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-100.0) length:CPTDecimalFromFloat(1200.0)];

    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)weightGraph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
	x.majorIntervalLength		  = CPTDecimalFromFloat(oneDay);
	x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
	x.minorTicksPerInterval		  = 0;
    
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.dateStyle = kCFDateFormatterShortStyle;
	CPTTimeFormatter *timeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
	timeFormatter.referenceDate = refDate;
	x.labelFormatter			= timeFormatter;
    
	CPTXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength		  = CPTDecimalFromString(@"100.0");
	y.minorTicksPerInterval		  = 5;
	y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);
    
    
	// Create a plot that uses the data source method
	CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    
	CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth				 = 3.f;
	lineStyle.lineColor				 = [CPTColor greenColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;
    
	dataSourceLinePlot.dataSource = self;
	
    CPTColor *areaColor		  = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
	CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
	areaGradient.angle = -90.0f;
	CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
	dataSourceLinePlot.areaFill		 = areaGradientFill;
	dataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"1.75");
    dataSourceLinePlot.identifier = @"weights";
    [weightGraph addPlot:dataSourceLinePlot];
    
    
    
    
    // Create the pellet graph.
    pelletGraph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *ptheme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[pelletGraph applyTheme:ptheme];
    pelletGraph.name = @"Pellets";
    
    CPTXYPlotSpace *pelletPlotSpace = (CPTXYPlotSpace *)pelletGraph.defaultPlotSpace;
    pelletPlotSpace.allowsUserInteraction = YES;
	pelletPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow) length:CPTDecimalFromFloat(oneDay * 7)];
	pelletPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(12.0)];
    
    // Axes
	CPTXYAxisSet *pelletAxisSet = (CPTXYAxisSet *)pelletGraph.axisSet;
	CPTXYAxis *pelletX		  = pelletAxisSet.xAxis;
	pelletX.majorIntervalLength		  = CPTDecimalFromFloat(oneDay);
	pelletX.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	pelletX.minorTicksPerInterval		  = 0;
    
	timeFormatter.referenceDate = refDate;
	pelletX.labelFormatter			= timeFormatter;
    
	CPTXYAxis *pelletY = pelletAxisSet.yAxis;
	pelletY.majorIntervalLength		  = CPTDecimalFromString(@"1");
	pelletY.minorTicksPerInterval		  = 0;
	pelletY.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);

    // Create a plot that uses the data source method
	CPTScatterPlot *pelletDataSourceLinePlot = [[[CPTScatterPlot alloc] init] autorelease];    
	CPTMutableLineStyle *pelletLineStyle = [[pelletDataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	pelletLineStyle.lineWidth				 = 3.f;
	pelletLineStyle.lineColor				 = [CPTColor blueColor];
	pelletDataSourceLinePlot.dataLineStyle = pelletLineStyle;
    
	pelletDataSourceLinePlot.dataSource = self;
	
    CPTColor *pelletAreaColor		  = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
	CPTGradient *pelletAreaGradient = [CPTGradient gradientWithBeginningColor:pelletAreaColor endingColor:[CPTColor clearColor]];
	pelletAreaGradient.angle = -90.0f;
	CPTFill *pelletAreaGradientFill = [CPTFill fillWithGradient:pelletAreaGradient];
	pelletDataSourceLinePlot.areaFill		 = pelletAreaGradientFill;
	pelletDataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"0");
    pelletDataSourceLinePlot.identifier = @"pellets";
    
    [pelletGraph addPlot:pelletDataSourceLinePlot];
    
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return weightEntries.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    //NSLog(@"index = %d", index);
    
    if (fieldEnum == CPTScatterPlotFieldY) {
        
        if ([plot.identifier isEqual:@"weights"]){
            NSString* weight = [[weightEntries objectAtIndex:index] objectForKey:@"weight"];
            //NSLog(@"index = %d, x = %d", index, [weight intValue]);
    
            if ([weight length] == 0) return nil;
    
            else return [NSDecimalNumber numberWithInt:[weight intValue]];
        }
        
        if ([plot.identifier isEqual:@"pellets"]){
            
            NSString* pellets = [[weightEntries objectAtIndex:index] objectForKey:@"pellets"];
            if ([pellets length] == 0) return nil;
            else return [NSDecimalNumber numberWithInt:[pellets intValue]];
        }
        
        else return nil;
    }
    
    if (fieldEnum == CPTScatterPlotFieldX){
        NSTimeInterval oneDay = 24 * 60 * 60;
        NSTimeInterval x = oneDay*index;
        return [NSDecimalNumber numberWithFloat:x];
    }
    
    else return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
	else return NO;
}


- (id) initWithUtility:(SpreadsheetUtility *)util andRat:(NSDictionary *)rat
{
    [super init];
    
    self.utility = util;
    [self.utility setDelegate:self];
    name = [rat objectForKey:@"name"];
    ratColumn = [[rat objectForKey:@"column"] intValue];
    
    self.weightEntries = [[NSMutableArray alloc] init];
    
    return self;
}

- (IBAction) switchPressed: (UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0){
        graphView.hostedGraph = weightGraph;
    }
    if (sender.selectedSegmentIndex == 1){
        graphView.hostedGraph = pelletGraph;
    }
}


#pragma mark - Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Weight Entries over Time";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [weightEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *thisRat = [weightEntries objectAtIndex:indexPath.row];
    cell.textLabel.text = [thisRat objectForKey:@"date"];
    
    int weight = [[thisRat objectForKey:@"weight"] intValue];
    int pellets = [[thisRat objectForKey:@"pellets"] intValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%dg : %d pellets", weight, pellets];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.notesView setText:[[weightEntries objectAtIndex:indexPath.row] objectForKey:@"notes"]];
    
    // Highlight this point on the graph here...?
    NSTimeInterval oneDay = 60*60*24;
    NSDateFormatter* dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"M/d/yyyy"];
    NSDate *startDate = [dateformat dateFromString:[[weightEntries objectAtIndex:0] objectForKey:@"date"]];
    NSDate *refdate = [dateformat dateFromString:[[weightEntries objectAtIndex:indexPath.row] objectForKey:@"date"]];
    
    NSTimeInterval startInterval = [startDate timeIntervalSinceNow];
    NSTimeInterval endInterval = [refdate timeIntervalSinceNow];
    NSTimeInterval diff = endInterval - startInterval;
    int diffDays = abs(diff / (60*60*24));
    
    //NSLog(@"Difference of %d days...", diffDays);
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)weightGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(diffDays*oneDay - 2*oneDay) length:CPTDecimalFromFloat(4*oneDay)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-100.0) length:CPTDecimalFromFloat(1200.0)];
    
    CPTXYPlotSpace *pelletSpace = (CPTXYPlotSpace *)pelletGraph.defaultPlotSpace;
    pelletSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(diffDays*oneDay - 2*oneDay) length:CPTDecimalFromFloat(4*oneDay)];
    pelletSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(12.0)];
    
    return;
}



@end
