//
//  NewEntryViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewEntryViewController.h"


@implementation NewEntryViewController

@synthesize which;

@synthesize notesButton, notes;

@synthesize addButton, one, two, three, four, five, six, seven, eight, nine, zero, clear;

@synthesize populationTable, ratTable;

@synthesize weightLabel, dateLabel, pelletLabel;

@synthesize service;

@synthesize selectedRat, selectedWorksheet;

@synthesize worksheetPopulations, ratList;

@synthesize cellEntries, foundCell;

- (id)initWithWorksheets:(NSArray *)ws andService:(GDataServiceGoogleSpreadsheet *)serv
{
    [super init];
    
    NSLog(@"Initializing NewEntry with %d worksheets", [ws count]);
    
    self.worksheetPopulations = ws;
    self.service = serv;
    
    [self.ratTable setDelegate:self];
    [self.populationTable setDelegate:self];
    
    return self;
}

- (void)dealloc
{
    
    self.addButton = nil;
    
    
    self.one = nil;
    self.two = nil;
    self.three = nil;
    self.four = nil;
    self.five = nil;
    self.six = nil;
    self.seven = nil;
    self.eight = nil;
    self.nine = nil;
    self.zero = nil;
    self.clear = nil; 
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == populationTable) return [worksheetPopulations count];
    if (tableView == ratTable) return [ratList count];
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *title;
    
    if (tableView == populationTable) {
        
        GDataEntryWorksheet* this = [worksheetPopulations objectAtIndex:indexPath.row];
        GDataTextConstruct* titleTextConstruct = [this title];
        title = [titleTextConstruct stringValue];
        
    }
    
    if (tableView == ratTable){
        
        NSDictionary *thisRat = [ratList objectAtIndex:indexPath.row];
        title = [thisRat objectForKey:@"name"];
        
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithRatNameCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {

    NSMutableArray *temp = [[[NSMutableArray alloc] init] autorelease];
    
    numRats = 0;
    
    for (int i = 0; i < [[feed entries] count] ; i++){
        
        GDataEntrySpreadsheetCell *this = [[feed entries] objectAtIndex:i];
        
        NSString *name = [[this cell] resultString];
        
        NSLog(@"Found cell R%dC1 with value %@", i+2, name);
        
        if ([name isEqualToString:@"Pellets:"]) break;
        
        numRats++;
        
        NSDictionary *next = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", [NSString stringWithFormat:@"%d", i+2], @"column", nil];
        
        [temp addObject:next];
        
    }
    
    NSLog(@"There are %d unique rats.", numRats);
    
    ratList = [[NSArray alloc] initWithArray:temp];
    
    [ratTable reloadData];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == populationTable) {
        
        selectedWorksheet = [worksheetPopulations objectAtIndex:indexPath.row];
        
        // Load the ratlist for this worksheet and reload the rat Table
        
        GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[selectedWorksheet cellsLink] URL]];
        
        cellQuery.minimumRow = 1;
        cellQuery.maximumRow = 1;
        cellQuery.minimumColumn = 2;
        
        [service fetchFeedWithQuery:cellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithRatNameCellFeed:error:)];
        
    }
    
    if (tableView == ratTable) {
        
        selectedRat = [ratList objectAtIndex:indexPath.row];
        
    }
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.which = @"Weight";
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"M/d/yyyy"];
    dateLabel.text = [formatter stringFromDate:now];
    
    [populationTable reloadData];
    [ratTable reloadData];
    
    [populationTable setBackgroundView:nil];
    [ratTable setBackgroundView:nil];
    
    populationTable.layer.borderWidth = 2.0;
    ratTable.layer.borderWidth = 2.0;
   
    [addButton setupAsRedButton];
    
    [notesButton setupAsSmallGreenButton];
    
    
    [one setupAsSmallGreenButton];
    [two setupAsSmallGreenButton];
    [three setupAsSmallGreenButton];
    [four setupAsSmallGreenButton];
    [five setupAsSmallGreenButton];
    [six setupAsSmallGreenButton];
    [seven setupAsSmallGreenButton];
    [eight setupAsSmallGreenButton];
    [nine setupAsSmallGreenButton];
    [zero setupAsSmallGreenButton];
    [clear setupAsSmallGreenButton];
    
}

/*
 * Finisher method for DATE FEED
 */
- (void)ticket:(GDataServiceTicket *)ticket
finishedWithDateCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
 
    self.cellEntries = [feed entries];
    
    int ratColumn = [[selectedRat objectForKey:@"column"] intValue];
    
    for (int i = 0; i < [[feed entries] count]; i++) {
        
        GDataEntrySpreadsheetCell *this = [[feed entries] objectAtIndex:i];
        
        NSString *date = [[this cell] resultString];
        
        //NSLog(@"Found date - %@ : Today's date - %@", date, [dateLabel text]);
        
        if ([dateLabel.text isEqualToString:date]){
            dateExists = YES;
            dateRow =  i+2;
            
            NSLog(@"Date exists! at row %d", i+2);
            
            GDataQuerySpreadsheet *weightCellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[selectedWorksheet cellsLink] URL]];
            
            weightCellQuery.minimumColumn = ratColumn;
            weightCellQuery.maximumColumn = ratColumn;
            weightCellQuery.minimumRow = dateRow;
            weightCellQuery.maximumRow = dateRow;
            
            [weightCellQuery setShouldReturnEmpty:YES];
            
            [service fetchFeedWithQuery:weightCellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithFindCellFeed:error:)];
            
            return;
            
        }
    }
    
    dateExists = NO;
    dateRow = [[feed entries] count];
    
    NSLog(@"Date does not exist!!");
    
    GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[selectedWorksheet cellsLink] URL]];
    
    [cellQuery setShouldReturnEmpty:YES];
    
    cellQuery.minimumRow = dateRow;
    cellQuery.maximumRow = dateRow;
    
    NSLog(@"New row at %d", dateRow);
    
    for (int i = 0; i < [ratList count] + 1; i ++ ) {
        
        
        cellQuery.minimumColumn = i + 1;
        cellQuery.maximumColumn = i + 1;
        NSLog(@"Doing column %d", i + 1);
        
        [service fetchFeedWithQuery:cellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithNewColumnCellFeed:error:)];
        
    }
    
}

/*
 * If date not found, creates new ROW!
 */
- (void)ticket:(GDataServiceTicket *)ticket
finishedWithNewColumnCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    foundCell = [[feed entries] objectAtIndex:0];
    
    int ratColumn = [[selectedRat objectForKey:@"column"] intValue];
    int thisColumn = [[foundCell cell] column];
    
    NSLog(@"Rat row = %d & This Row = %d", ratColumn, thisColumn);
    
    if (thisColumn == 1) {
        [[foundCell cell] setInputString:[dateLabel text]];
    }
    
    else if (ratColumn == thisColumn){
        [[foundCell cell] setInputString:[weightLabel text]];
    }
    
    else {
        [[foundCell cell] setInputString:@"--"];
    }
    
    [service fetchEntryByInsertingEntry:foundCell forFeedURL:[[selectedWorksheet cellsLink] URL] delegate:nil didFinishSelector:nil];
    
}
             
- (void)ticket:(GDataServiceTicket *)ticket
finishedWithInsertingPellets:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    GDataEntrySpreadsheetCell* this = [[feed entries] objectAtIndex:0];
    NSLog(@"Going to edit cell %@ to %@", [[this title] contentStringValue], [pelletLabel text]);
    NSLog(@"Current value - %@", [[this cell] resultString]);
    
    [[this cell] setInputString:[pelletLabel text]];
    [service fetchEntryByInsertingEntry:this forFeedURL:[[selectedWorksheet cellsLink] URL] delegate:self didFinishSelector:@selector(ticket:finishedPellets:error:)];
}
             
             

/*
 * Inserts new entry into found cell...
 */ 
- (void)ticket:(GDataServiceTicket *)ticket
finishedWithFindCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    foundCell = [[feed entries] objectAtIndex:0];
    NSLog(@"Going to edit cell %@ to %@", [[foundCell title] contentStringValue], [weightLabel text]);
    NSLog(@"Current value - %@", [[foundCell cell] resultString]);
    
    // Insert the weight...
    [[foundCell cell] setResultString:[weightLabel text]];
    [[foundCell cell] setInputString:[weightLabel text]];
    [[foundCell cell] setNumericValue:[NSNumber numberWithInt:[[weightLabel text] intValue]]];
    [service fetchEntryByInsertingEntry:foundCell forFeedURL:[[selectedWorksheet cellsLink] URL] delegate:self didFinishSelector:@selector(ticket:finished:error:)];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
      finishedPellets:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    NSLog(@"COMPLETED ENTRY - NEW VALUE");
}

- (void)ticket:(GDataServiceTicket *)ticket
finished:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    NSLog(@"COMPLETED ENTRY - NEW VALUE");
    
    GDataQuerySpreadsheet *pelletCellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[selectedWorksheet cellsLink] URL]];
    
    int ratColumn = [[selectedRat objectForKey:@"column"] intValue];
    
    pelletCellQuery.minimumColumn = ratColumn + numRats + 1;
    pelletCellQuery.maximumColumn = ratColumn + numRats + 1;
    pelletCellQuery.minimumRow = dateRow;
    pelletCellQuery.maximumRow = dateRow;
    
    [pelletCellQuery setShouldReturnEmpty:YES];
    
    [service fetchFeedWithQuery:pelletCellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithInsertingPellets:error:)];
}

- (IBAction) addEntryPressed{
    
    
    
    
    NSLog(@"Add New Entry Pressed!");
    NSLog(@"Population:%@ \n Rat:%@ \n Row: %@ \n NewWeight = %@", [[selectedWorksheet title] stringValue], [selectedRat objectForKey:@"name"], [selectedRat objectForKey:@"column"], [weightLabel text]);
    
    // Do entry checking...
    
    if (selectedWorksheet == nil){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Entry" 
                                                        message:@"No selected population!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (selectedRat == nil){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Entry" 
                                                        message:@"No selected rat!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    
        // Check baseline weight of rat...
    
    int numPellets = [[pelletLabel text] intValue];
    
    if (numPellets == 0 || numPellets > 10){
        
        NSString *msg;
        if (numPellets == 0) msg = @"Number of pellets zero!";
        if (numPellets > 10) msg = @"Number of pellets too large!";
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Entry" 
                                                        message:msg
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    
    // check if the current date exists in a column header
    
    GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[selectedWorksheet cellsLink] URL]];
    
    cellQuery.minimumColumn = 1;
    cellQuery.maximumColumn = 1;
    cellQuery.minimumRow = 2;
    
    [service fetchFeedWithQuery:cellQuery delegate:self didFinishSelector:@selector(ticket:finishedWithDateCellFeed:error:)];
    
    NSString* entryMsg = [NSString stringWithFormat:@"Population: %@\nRat: %@\nDate: %@\nWeight: %@\nPellets: %@\nNote: %@", [[selectedWorksheet title]stringValue], [selectedRat objectForKey:@"name"], [dateLabel text], [weightLabel text], [pelletLabel text], notes];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Addding Entry" 
                                                    message:entryMsg
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
    
}

- (IBAction) digitPressed: (MOGlassButton*)sender{
    
    if ([which isEqualToString:@"Weight"]){
        if (sender == clear) weightLabel.text = @"0";
        
        else {
            
            int oldWeight = [weightLabel.text integerValue];
            int newWeight = 10 * oldWeight + [sender.titleLabel.text integerValue];
            weightLabel.text = [NSString stringWithFormat:@"%d", newWeight];
        }
    }
    
    if ([which isEqualToString:@"Pellets"]){
        if (sender == clear) pelletLabel.text = @"0";
        
        else {
            
            int oldWeight = [pelletLabel.text integerValue];
            int newWeight = 10 * oldWeight + [sender.titleLabel.text integerValue];
            pelletLabel.text = [NSString stringWithFormat:@"%d", newWeight];
        }
    }
}

- (IBAction) switchPressed: (UISegmentedControl*)sender;
{
    if (sender.selectedSegmentIndex == 0){
        self.which = @"Weight";
    }
    if (sender.selectedSegmentIndex == 1){
        self.which = @"Pellets";
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    
    self.notes = [[alertView textFieldAtIndex:0] text];
}

- (IBAction) notesPressed
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Notes" message:@"Edit your note here:" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    if (self.notes != nil) {
        UITextField* textField = [alert textFieldAtIndex:0];
        textField.text = self.notes;
    }
    
    [alert show];
    [alert release];
}

@end
