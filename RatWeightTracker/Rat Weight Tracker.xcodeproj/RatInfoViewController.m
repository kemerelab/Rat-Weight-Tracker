//
//  RatInfoViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RatInfoViewController.h"


@implementation RatInfoViewController

@synthesize ratNameLabel;

@synthesize service, worksheet;

@synthesize weightEntries;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithWorksheet:(GDataEntryWorksheet *)ws andService:(GDataServiceGoogleSpreadsheet *)serv andRat:(NSDictionary *)rat
{
    [super init];
    
    self.worksheet = ws;
    self.service = serv;
    self.ratNameLabel.text = [rat objectForKey:@"name"];
    ratColumn = [[rat objectForKey:@"row"] intValue];
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}



@end
