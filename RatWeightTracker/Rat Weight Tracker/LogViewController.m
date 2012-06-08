//
//  LogViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LogViewController.h"
#import "GData.h"


@implementation LogViewController

@synthesize service;

@synthesize selectedWorksheet, selectedRat, selectedWorksheetPath;

@synthesize populationsList, ratList;



- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Populations";
}

- (id) initWithWorksheets:(NSArray*)ws andService:(GDataServiceGoogleSpreadsheet*)serv;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.populationsList = ws;
    
    self.service = serv;
    
    NSLog(@"length of populations = %d", [self.populationsList count]);
    
    return self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // First section, populations
    if (section == 0) return [populationsList count];
    
    // Second section, rats
    else return [ratList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // First section, populations
    if (section == 0) return @"Populations";
    
    // Second section, rats
    else return @"Rats";
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Population cell
    if (indexPath.section == 0) {
        
        GDataEntryWorksheet *this = [populationsList objectAtIndex:indexPath.row];
        GDataTextConstruct *titleTextConstruct = [this title];
        NSString *title = [titleTextConstruct stringValue];
        
        cell.textLabel.text = title;
    }
    
    // Rat cell
    if (indexPath.section == 1) {
        
        NSDictionary *this = [ratList objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [this objectForKey:@"name"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Selected a population
    if (indexPath.section == 0){
        
        if (selectedWorksheetPath) [tableView cellForRowAtIndexPath:selectedWorksheetPath].accessoryType = UITableViewCellAccessoryNone;
        
        self.selectedWorksheetPath = indexPath;
        self.selectedWorksheet = [populationsList objectAtIndex:indexPath.row];
        GDataTextConstruct *titleTextConstruct = [selectedWorksheet title];
        NSString *title = [titleTextConstruct stringValue];
        
        NSLog(@"Selected populations %@", title);
        
        // Send query to get the rat list for this worksheet
        
        GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[selectedWorksheet cellsLink] URL]];
        
        cellQuery.minimumRow = 2;
        cellQuery.minimumColumn = 1;
        cellQuery.maximumColumn = 1; // Get the first column of every row after 2.
        
        [service fetchFeedWithQuery:cellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithRatNameCellFeed:error:)];
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    
    // Selected a rat
    if (indexPath.section == 1){
        
        
        
        
        
    }
}


#pragma mark - GData selectors

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithRatNameCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    NSMutableArray *temp = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < [[feed entries] count] ; i++){
        
        GDataEntrySpreadsheetCell *this = [[feed entries] objectAtIndex:i];
        NSString *name = [[this cell] resultString];
        
        NSLog(@"Found cell R%dC1 with value %@", i+2, name);
        NSDictionary *next = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", [NSString stringWithFormat:@"%d", i], @"row", nil];
        
        [temp addObject:next];
        
    }
    
    ratList = [[NSArray alloc] initWithArray:temp];
    
    [self.tableView reloadData];
    
}

@end
