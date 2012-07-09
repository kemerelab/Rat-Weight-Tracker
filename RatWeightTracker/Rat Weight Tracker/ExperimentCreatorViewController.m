//
//  ExperimentCreatorViewController.m
//  Rat Weight Tracker
//
//  Created by Help Desk on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExperimentCreatorViewController.h"

#import "ActionSheetDatePicker.h"

@interface ExperimentCreatorViewController ()

@end

@implementation ExperimentCreatorViewController

@synthesize nameField, ratNameField;

@synthesize ratList, selectedRat, ratTable;

@synthesize addRatButton, removeRatButton, editStartButton, editEndButton;

@synthesize startDate, endDate;

@synthesize service;

- (id) initWithService:(GDataServiceGoogleSpreadsheet *)serv
{
    [super init];
    self.service = serv;
    self.ratList = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ratTable.layer.borderWidth = 1.0;
    
    [self.addRatButton setupAsGreenButton];
    [self.removeRatButton setupAsRedButton];
    
    [self.editStartButton setupAsSmallGreenButton];
    [self.editEndButton setupAsSmallGreenButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    else return NO;
}

-(IBAction)buttonPressed:(id)sender
{
    if (sender == self.addRatButton){
        [self.ratList addObject:ratNameField.text];
        self.ratNameField.text = @"";
        [self.ratTable reloadData];
    }
    
    if (sender == self.removeRatButton){
        [self.ratList removeObjectAtIndex:selectedRat.row];
        [self.ratTable reloadData];
    }
    
    if (sender == self.editStartButton){
        
        
    }
    
    if (sender == self.editEndButton){
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.ratList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [self.ratList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRat = indexPath;
}


@end
