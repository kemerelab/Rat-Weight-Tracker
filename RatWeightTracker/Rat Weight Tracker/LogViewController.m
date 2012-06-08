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

@synthesize populations;

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Populations";
}

- (id) initWithPopulations:(NSArray *)pops
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    self.populations = pops;
    
    NSLog(@"length of populations = %d", [self.populations count]);
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [populations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    GDataEntryDocBase *this = [populations objectAtIndex:indexPath.row];
    GDataTextConstruct *titleTextConstruct = [this title];
    NSString *title = [titleTextConstruct stringValue];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Need to get the spreadsheet...
    
    //GDataEntrySpreadsheet *spreadsheet = [populations objectAtIndex:indexPath.row];
    
    
    
}

@end
