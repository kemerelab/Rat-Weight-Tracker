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

@synthesize nameField, ratNameField, baselineField;

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

- (void) expressError
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Occurred" message:@"An error occurred while processing you request. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(IBAction)buttonPressed:(id)sender
{
    if (sender == self.addRatButton){
        [self.ratList addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:self.ratNameField.text, @"name", self.baselineField.text, @"baseline", nil]];
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
        
        // Calculate number of rows and columns.
        numCols = [ratList count];
        NSTimeInterval startInterval = [startDate timeIntervalSinceNow];
        NSTimeInterval endInterval = [endDate timeIntervalSinceNow];
        NSTimeInterval diff = endInterval - startInterval;
        numRows = diff / (60*60*24) + 1;
        NSLog(@"%d rows and %d columns", numRows, numCols);
        
        
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
 
    if (error) {NSLog(@"[Uploading new spreadsheet error] %@", error); [self expressError]; return;}
    
    GDataQuerySpreadsheet *query = [GDataQuerySpreadsheet queryWithFeedURL:[NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed]];
    [query setTitleQuery:[[self.nameField text] stringByAppendingString:@" Rat Weights"]];
    
    [self.service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithSpreadsheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    if (error) {NSLog(@"[Fetching spreadsheets error] %@", error); [self expressError]; return;}
    
    self.newSpreadsheet = [[feed entries] objectAtIndex:0];
    
    // Edit the first worksheet to be the weights..
    
    [self.service fetchFeedWithURL:[self.newSpreadsheet worksheetsFeedURL] delegate:self didFinishSelector:@selector(ticket:finishedWithWeightWorksheetFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWeightWorksheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    if (error) {NSLog(@"[Getting worksheets error] %@", error); [self expressError]; return;}
    
    GDataEntryWorksheet* weights = [[feed entries] objectAtIndex:0];
    [weights setTitleWithString:@"Weights"];
    [weights setRowCount:numRows+1];
    [weights setColumnCount:numCols+1]; // Padding of one.
    
    [self.service fetchEntryByUpdatingEntry:weights delegate:self didFinishSelector:@selector(ticket:finishedWithWorksheet:error:)];
}

- (void) getAllDataFromWorksheet:(GDataEntryWorksheet*)worksheet
{
    NSString *name = [[worksheet title] contentStringValue];
    NSLog(@"Getting all data from %@", name);
    if ([name isEqualToString:@"Baselines"]){
        GDataQuerySpreadsheet* query = [GDataQuerySpreadsheet  queryWithFeedURL:[[worksheet cellsLink] URL]];
        query.minimumRow = 1;
        query.maximumRow = 2;
        query.minimumColumn = 1;
        query.maximumColumn = numCols;
        [query setShouldReturnEmpty:YES];
        
        [self.service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(ticket:finishedWithRetrievingBaselineData:error:)];
    }
    
    else { // Everyone else has the regular dimensions.
        GDataQuerySpreadsheet* query = [GDataQuerySpreadsheet queryWithFeedURL:[[worksheet cellsLink] URL]];
        query.minimumRow = 1;
        query.minimumColumn = 1;
        query.maximumColumn = numCols+1;
        query.maximumRow = numRows+1;
        [query setShouldReturnEmpty:YES];
        
        [self.service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(ticket:finishedWithRetrievingData:error:)];
        
        if ([name isEqualToString:@"Relative"]){
            [self.service fetchFeedWithQuery:query completionHandler:^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error){
               
                if (error) {NSLog(@"[getting cells...] %@", error); [self expressError]; return;}
                
                NSLog(@"starting batch set up for relatives else...");
                
                for (int i = 0; i < [[feed entries] count]; i ++){
                    GDataEntrySpreadsheetCell* thisCellEntry = [[feed entries] objectAtIndex:i];
                    GDataSpreadsheetCell* cell = [thisCellEntry cell];
                    
                    if ([cell row] > 1 && [cell column] > 1) {
                        
                        
                        [cell setInputString:[NSString stringWithFormat:@"=IF(Baselines!R2C%d = \"\", \"\", Weights!R%dC%d / Baselines!R2C%d)", [cell column]-1, [cell row],[cell column], [cell column] -1]];
                        
                    }
                    
                }
                
                NSURL *batchUrl = [[feed batchLink] URL];
                GDataFeedSpreadsheetCell *batchFeed = [GDataFeedSpreadsheetCell spreadsheetCellFeed];
                
                [batchFeed setEntriesWithEntries:[feed entries]];
                
                GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
                [batchFeed setBatchOperation:op];
                [batchFeed setETag:[feed ETag]];
                
                [self.service fetchFeedWithBatchFeed:batchFeed forBatchFeedURL:batchUrl
                                   completionHandler:
                 ^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
                     
                     if (error) {NSLog(@"[batch error...] %@", error); [self expressError]; return;}
                     
                 }];
                
            }];
        }
    }
    
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithRetrievingBaselineData:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    if (error) {NSLog(@"[getting cells...] %@", error); [self expressError]; return;}
    
    NSLog(@"starting batch set up for baselines...");
    
    for (int i = 0; i < [[feed entries] count]; i ++){
        GDataEntrySpreadsheetCell* thisCellEntry = [[feed entries] objectAtIndex:i];
        GDataSpreadsheetCell* cell = [thisCellEntry cell];
        
        if ([[thisCellEntry cell]row] == 1){
            [cell setInputString:[[ratList objectAtIndex:[cell column]-1] objectForKey:@"name"]];
        }
        
        if ([[thisCellEntry cell]row] == 2){
            [cell setInputString:[[ratList objectAtIndex:[cell column]-1] objectForKey:@"baseline"]];
        }
    }
    
    NSURL *batchUrl = [[feed batchLink] URL];
    GDataFeedSpreadsheetCell *batchFeed = [GDataFeedSpreadsheetCell spreadsheetCellFeed];
    
    [batchFeed setEntriesWithEntries:[feed entries]];
    
    GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
    [batchFeed setBatchOperation:op];
    [batchFeed setETag:[feed ETag]];
    
    [self.service fetchFeedWithBatchFeed:batchFeed forBatchFeedURL:batchUrl
                  completionHandler:
     ^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
         
        if (error) {NSLog(@"[batch error...] %@", error); [self expressError]; return;}
         
     }];
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithRetrievingData:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    if (error) {NSLog(@"[getting cells...] %@", error); [self expressError]; return;}
    
    NSLog(@"starting batch set up for everyone else...");
    
    for (int i = 0; i < [[feed entries] count]; i ++){
        GDataEntrySpreadsheetCell* thisCellEntry = [[feed entries] objectAtIndex:i];
        GDataSpreadsheetCell* cell = [thisCellEntry cell];
        
        if ([cell row] == 1 && [cell column] == 1) continue;
        
        if ([cell row] == 1){
            
            [cell setInputString:[[ratList objectAtIndex:[cell column]-2] objectForKey:@"name"]];
        }
        
        if ([cell column] == 1){
            NSDate *newDate = [NSDate dateWithTimeInterval:([cell row]-2)*60*60*24 sinceDate:startDate]; 
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"M/d/yyyy"];
            [cell setInputString:[formatter stringFromDate:newDate]];
        }
        
        
    }
    
    NSURL *batchUrl = [[feed batchLink] URL];
    GDataFeedSpreadsheetCell *batchFeed = [GDataFeedSpreadsheetCell spreadsheetCellFeed];
    
    [batchFeed setEntriesWithEntries:[feed entries]];
    
    GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
    [batchFeed setBatchOperation:op];
    [batchFeed setETag:[feed ETag]];
    
    [self.service fetchFeedWithBatchFeed:batchFeed forBatchFeedURL:batchUrl
                       completionHandler:
     ^(GDataServiceTicket *ticket, GDataFeedBase *feed, NSError *error) {
         
         if (error) {NSLog(@"[batch error...] %@", error); [self expressError]; return;}
         
     }];
}
         

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWorksheet:(GDataEntryWorksheet *)entry
         error:(NSError *)error {
 
    if (error) {NSLog(@"[Updating worksheets] %@", error); [self expressError]; return;}
    
    NSString * which = [[entry title] contentStringValue];
    
    if ([which isEqualToString:@"Weights"]){
    
        [self getAllDataFromWorksheet:entry];
    
        GDataEntryWorksheet* pellets = [GDataEntryWorksheet worksheetEntry];
        [pellets setTitleWithString:@"Pellets"];
        [pellets setRowCount:numRows+1];
        [pellets setColumnCount:numCols+1];
        
        [self.service fetchEntryByInsertingEntry:pellets forFeedURL:[self.newSpreadsheet worksheetsFeedURL] delegate:self didFinishSelector:@selector(ticket:finishedWithWorksheet:error:)];
    }
    
    if ([which isEqualToString:@"Pellets"]){
        
        // TODO : put in actual data
        [self getAllDataFromWorksheet:entry];
        
        GDataEntryWorksheet* notes = [GDataEntryWorksheet worksheetEntry];
        [notes setTitleWithString:@"Notes"];
        [notes setRowCount:numRows+1];
        [notes setColumnCount:numCols+1];
        
        [self.service fetchEntryByInsertingEntry:notes forFeedURL:[self.newSpreadsheet worksheetsFeedURL] delegate:self didFinishSelector:@selector(ticket:finishedWithWorksheet:error:)];
        
    }
    
    if ([which isEqualToString:@"Notes"]){
        
        [self getAllDataFromWorksheet:entry];
        
        GDataEntryWorksheet* baselines = [GDataEntryWorksheet worksheetEntry];
        [baselines setTitleWithString:@"Baselines"];
        [baselines setRowCount:2];
        [baselines setColumnCount:numCols];
        
        [self.service fetchEntryByInsertingEntry:baselines forFeedURL:[self.newSpreadsheet worksheetsFeedURL] delegate:self didFinishSelector:@selector(ticket:finishedWithWorksheet:error:)];
        
    }
    
    if ([which isEqualToString:@"Baselines"]){
        
        [self getAllDataFromWorksheet:entry];
        
        GDataEntryWorksheet* relative = [GDataEntryWorksheet worksheetEntry];
        [relative setTitleWithString:@"Relative"];
        [relative setColumnCount:numCols+1];
        [relative setRowCount:numRows+1];
        
        [self.service fetchEntryByInsertingEntry:relative forFeedURL:[self.newSpreadsheet worksheetsFeedURL] delegate:self didFinishSelector:@selector(ticket:finishedWithWorksheet:error:)];
        
    }
    
    if ([which isEqualToString:@"Relative"]){
        
        [self getAllDataFromWorksheet:entry];
        
        NSLog(@"DONE!");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [[self.ratList objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[self.ratList objectAtIndex:indexPath.row] objectForKey:@"baseline"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRat = indexPath;
}


@end
