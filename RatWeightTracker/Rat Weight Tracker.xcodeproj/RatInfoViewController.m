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
    
    
    // Draw the graph here....
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationPortrait) return YES;
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
    
    return;
}



@end
