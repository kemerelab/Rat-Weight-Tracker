//
//  ExperimentCreatorViewController.m
//  Rat Weight Tracker
//
//  Created by Help Desk on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExperimentCreatorViewController.h"
#import "MBProgressHUD.h"
#import "ActionSheetDatePicker.h"

@interface ExperimentCreatorViewController ()

@end

@implementation ExperimentCreatorViewController

@synthesize nameField, ratNameField;

@synthesize ratList, selectedRat, ratTable;

@synthesize addRatButton, removeRatButton, editStartButton, editEndButton;

@synthesize startDate, endDate, startDateLabel, endDateLabel;

@synthesize createButton;

@synthesize service, docsService, newSpreadsheet;

- (id) initWithService:(GDataServiceGoogleSpreadsheet *)serv andDocsService:(GDataServiceGoogleDocs*)docs
{
    [super init];
    self.service = serv;
    self.ratList = [[NSMutableArray alloc] init];
    self.docsService = docs;
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
    
    [self.createButton setupAsGreenButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    else return NO;
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {

    NSDateFormatter* dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"M/d/yyyy"];
    
    if (element == self.editStartButton) {
        self.startDate = selectedDate;
        self.startDateLabel.text = [@"Start Date: " stringByAppendingString:[dateformat stringFromDate:self.startDate]];
    }
    
    if (element == self.editEndButton) {
        self.endDate = selectedDate;
        self.endDateLabel.text = [@"End Date: " stringByAppendingString:[dateformat stringFromDate:self.endDate]];
    }
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
        
        ActionSheetDatePicker* picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select Start Date" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:sender];
        [picker showActionSheetPicker];
    }
    
    if (sender == self.editEndButton){
        
        ActionSheetDatePicker* picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select End Date" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:sender];
        [picker showActionSheetPicker];
    }
    
    if (sender == self.createButton){
        
        NSLog(@"In create button handler...");
        
        if ([[self.nameField text] length] == 0){
            NSLog(@"No name inputted!"); return;
        }
        
        GDataEntrySpreadsheetDoc *newEntry = [GDataEntrySpreadsheetDoc documentEntry]; 
        [newEntry setUploadSlug:@"newEntry.csv"];
        [newEntry setTitleWithString:[[self.nameField text] stringByAppendingString:@" Rat Weights"]];
        [newEntry setUploadMIMEType:@"text/csv"];
        
        NSData *data = [@" " dataUsingEncoding:NSUTF8StringEncoding]; 
        [newEntry setUploadData:data]; 
        
        NSURL *uploadURL = [GDataServiceGoogleDocs docsUploadURL];
        
        GDataQueryDocs *query = [GDataQueryDocs queryWithFeedURL:uploadURL];
        [query setShouldConvertUpload:YES];
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.docsService fetchEntryByInsertingEntry:newEntry
                                 forFeedURL:uploadURL
                                   delegate:self
                          didFinishSelector:@selector(uploadFileTicket:finishedWithEntry:error:)];
    }

}

- (void)uploadFileTicket:(GDataServiceTicket *)ticket
       finishedWithEntry:(GDataEntryDocBase *)entry
                   error:(NSError *)error {
 
    if (error) {NSLog(@"%@", error); return;}
    
    GDataQuerySpreadsheet *query = [GDataQuerySpreadsheet queryWithFeedURL:[NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed]];
    [query setTitleQuery:[[self.nameField text] stringByAppendingString:@" Rat Weights"]];
    
    [self.docsService fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithSpreadsheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    if (error) {NSLog(@"%@", error); return;}
    
    self.newSpreadsheet = [[feed entries] objectAtIndex:0];
    
    // Edit the first worksheet to be the weights..
    
    [self.service fetchFeedWithURL:[self.newSpreadsheet worksheetsFeedURL] delegate:self didFinishSelector:@selector(ticket:finishedWithWeightWorksheetFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWeightWorksheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    GDataEntryWorksheet* weights = [[feed entries] objectAtIndex:0];
    [weights setTitleWithString:@"Weights"];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.ratList count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Total Rats:%d", [self.ratList count]];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Total Rats:%d", [self.ratList count]];
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
