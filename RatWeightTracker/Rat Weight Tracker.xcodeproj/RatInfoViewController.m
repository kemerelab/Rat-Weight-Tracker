//
//  RatInfoViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RatInfoViewController.h"


@implementation RatInfoViewController

@synthesize ratNameLabel, entriesTable;

@synthesize service, worksheet;

@synthesize weightEntries;

- (void)dealloc
{
    [super dealloc];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithCellRatDataFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    for (int i = 0; i < [[feed entries] count]; i++) {
        
        if (i == [self.weightEntries count]) break;
        
        NSLog(@"%@ - %@", [self.weightEntries objectAtIndex:i], [[[[feed entries] objectAtIndex:i] cell] resultString]);
        
        NSString *weight = [[[[feed entries] objectAtIndex:i] cell] resultString];
        
        if ([weight length] == 0) continue;
        
        NSMutableDictionary *thisEntry = [self.weightEntries objectAtIndex:i];
        
        [thisEntry setValue:weight forKey:@"weight"];
        
    }
    
    [self.entriesTable reloadData];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithDates:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    self.weightEntries = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [[feed entries] count]; i++) {
        
        NSString *date = [[[[feed entries] objectAtIndex:i] cell] resultString];
        
        [weightEntries addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:date, @"date", nil, @"weight", nil]];
        
    }

    GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[self.worksheet cellsLink] URL]];
    
    [cellQuery setShouldReturnEmpty:YES];
    
    cellQuery.minimumColumn = ratColumn;
    cellQuery.maximumColumn = ratColumn;
    cellQuery.minimumRow = 2;

    [service fetchFeedWithQuery:cellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithCellRatDataFeed:error:)];
}

- (id)initWithWorksheet:(GDataEntryWorksheet *)ws andService:(GDataServiceGoogleSpreadsheet *)serv andRat:(NSDictionary *)rat
{
    [super init];
    
    self.worksheet = ws;
    self.service = serv;
    self.ratNameLabel.text = [rat objectForKey:@"name"];
    ratColumn = [[rat objectForKey:@"column"] intValue]; // Really rat row for now..
    
    GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[self.worksheet cellsLink] URL]];
    
    cellQuery.minimumColumn = 1;
    cellQuery.maximumColumn = 1;
    cellQuery.minimumRow = 2;
    
    [service fetchFeedWithQuery:cellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithDates:error:)];
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

#pragma mark - Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    cell.detailTextLabel.text = [thisRat objectForKey:@"weight"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}



@end
