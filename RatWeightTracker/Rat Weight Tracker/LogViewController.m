//
//  LogViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LogViewController.h"
#import "GData.h"
#import "RatInfoViewController.h"
#import "MBProgressHUD.h"


@implementation LogViewController

@synthesize utility;
@synthesize service;
@synthesize selectedWorksheet, selectedRat, selectedWorksheetPath;
@synthesize selectedSpreadsheet;
@synthesize populationsList, ratList;
@synthesize spreadsheetsList;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationPortrait) return YES;
	else return NO;
}

- (id) initWithSpreadsheet:(NSDictionary *)sprd andService:(GDataServiceGoogleSpreadsheet *)serv
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.service = serv;
    
    SpreadsheetUtility *new_util = [[SpreadsheetUtility alloc] initWithService:serv 
                                                                      delegate:self 
                                                              andWorksheetDict:sprd];
    self.utility = new_util;
    
    return self;
}

- (id) initWithWorksheets:(NSArray*)ws andService:(GDataServiceGoogleSpreadsheet*)serv;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.populationsList = ws;
    self.service = serv;
        
    NSLog(@"length of populations = %d", [self.populationsList count]);
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.utility setDelegate:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Populations";
    self.tableView.backgroundView = nil;
    
    // Send request to fetch spreadsheets.
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
    [self.service fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithSpreadsheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    if (error == nil){
        
        //Successful retrieval of spreadsheet fields.
        
        NSArray *entries = [feed entries];
        NSMutableArray *tempEntries = [[NSMutableArray alloc] init];
        
        // Eventually, do a scan where we look for a certain keyword in the title. 
        for (int i = 0; i < [entries count]; i++) {
            
            GDataEntrySpreadsheet *next = [entries objectAtIndex:i];
            GDataTextConstruct *titleTextConstruct = [next title];
            NSString *title = [titleTextConstruct stringValue];
            
            if ([title rangeOfString:@"Kemere Lab Rat Weights"].location == NSNotFound){
                NSLog(@"I do not care about %@", title);
            } else {
                NSLog(@"Found %@", title);
                [tempEntries addObject:next];
            }
        }
        
        self.spreadsheetsList = [NSArray arrayWithArray:tempEntries];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        [self.tableView reloadData];
        
    } else {
        NSLog(@"Fetch error: %@", error.description);
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; // Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // First section, populations
    if (section == 0) return [self.spreadsheetsList count];
    
    // Second section, rats
    else return [ratList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // First section, populations
    if (section == 0) return @"Experiments";
    
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
    
    // Experiment cell
    if (indexPath.section == 0) {
        
        GDataEntryWorksheet *this = [self.spreadsheetsList objectAtIndex:indexPath.row];
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
        self.selectedSpreadsheet = [self.spreadsheetsList objectAtIndex:indexPath.row];
        
        GDataTextConstruct *titleTextConstruct = [self.selectedSpreadsheet title];
        NSString *title = [titleTextConstruct stringValue];
        
        NSLog(@"[LogView] Selected experiment %@", title);
        
        // Send query to get the rat list for this worksheet
        
        NSURL *worksheetsURL = [self.selectedSpreadsheet worksheetsFeedURL];
        
        [service fetchFeedWithURL:worksheetsURL 
                         delegate:self 
                didFinishSelector:@selector(ticket:finishedWithWorksheetFeed:error:)];
        
        [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
    }
    
    // Selected a rat
    if (indexPath.section == 1){
        
        self.selectedRat = [ratList objectAtIndex:indexPath.row];
        
        UINavigationController *navcon = [self navigationController];
        RatInfoViewController *ratcon = [[RatInfoViewController alloc] initWithUtility:self.utility andRat:self.selectedRat];
        [navcon pushViewController:ratcon animated:YES];
    }
}


#pragma mark - GData selectors

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWorksheetFeed:(GDataFeedWorksheet *)feed
         error:(NSError *)error {
    
    if (error == nil){
        
        //Successfully retrieved worksheet feed.
        //Create new worksheet dict and then fetch rat list.
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < [[feed entries] count]; i++) {
            
            GDataEntryWorksheet *ws = [[feed entries] objectAtIndex:i];
            
            NSLog(@"[LogView] Found worksheet %@ : with rows:%d and columns:%d", 
                  [[ws title] stringValue], [ws rowCount], [ws columnCount]);
                
            [temp setObject:ws forKey:[[ws title] stringValue]];
        }
        
        [self.utility setWorksheetDict:[[NSDictionary alloc] initWithDictionary:temp]];
        NSLog(@"[LogView] Calling utility... %@", self.utility);
        [self.utility fetchRatNames];
        
    } else NSLog(@"[LogView] worksheet fetch error:%@", error);
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithRatNameCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    NSLog(@"%@", [feed entries]);
    
    NSMutableArray *temp = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < [[feed entries] count] ; i++){
        
        GDataEntrySpreadsheetCell *this = [[feed entries] objectAtIndex:i];
        NSString *name = [[this cell] resultString];
        
        NSLog(@"Found cell R%dC1 with value %@", i+2, name);
        
        if ([name isEqualToString:@"Pellets:"] || [name length] == 0) break;
        
        NSDictionary *next = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", [NSString stringWithFormat:@"%d", i+2], @"column", nil];
        
        [temp addObject:next];
        
    }
    
    self.ratList = [[NSArray alloc] initWithArray:temp];
    
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    
}

@end
