//
//  NewEntryViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NewEntryViewController.h"
#import "MBProgressHUD.h"


@implementation NewEntryViewController

@synthesize utility;

@synthesize which;

@synthesize notesButton, notes;

@synthesize addButton, one, two, three, four, five, six, seven, eight, nine, zero, clear;

@synthesize populationTable, ratTable;

@synthesize weightLabel, dateLabel, pelletLabel;

@synthesize service;

@synthesize selectedRat, selectedWorksheet, selectedSpreadsheet;

@synthesize spreadsheetList, worksheetPopulations, ratList;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.utility = [[SpreadsheetUtility alloc] initWithService:self.service delegate:self andWorksheetDict:nil];
    
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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
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
    
    // Send query for spreadsheets...
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        
        self.spreadsheetList = [NSArray arrayWithArray:tempEntries];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.populationTable reloadData];
        
    } else {
        NSLog(@"Fetch error: %@", error.description);
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationPortrait) return YES;
	else return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



#pragma mark - table View methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == populationTable) return [self.spreadsheetList count];
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
    
    if (tableView == self.populationTable) {
        GDataEntryWorksheet* this = [self.spreadsheetList objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == populationTable) {
        
        self.selectedSpreadsheet = [self.spreadsheetList objectAtIndex:indexPath.row];
        
        // Load the ratlist for this worksheet and reload the rat Table
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSURL *worksheetsURL = [self.selectedSpreadsheet worksheetsFeedURL];
        [service fetchFeedWithURL:worksheetsURL 
                         delegate:self 
                didFinishSelector:@selector(ticket:finishedWithWorksheetFeed:error:)];
    }
    
    if (tableView == ratTable) {
        selectedRat = [ratList objectAtIndex:indexPath.row];
    }
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWorksheetFeed:(GDataFeedWorksheet *)feed
         error:(NSError *)error {
    
    if (error == nil){
        
        //Successfully retrieved worksheet feed.
        //Create new worksheet dict and then fetch rat list.
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < [[feed entries] count]; i++) {
            
            GDataEntryWorksheet *ws = [[feed entries] objectAtIndex:i];
            
            NSLog(@"[NewEntry] Found worksheet %@ : with rows:%d and columns:%d", 
                  [[ws title] stringValue], [ws rowCount], [ws columnCount]);
            
            [temp setObject:ws forKey:[[ws title] stringValue]];
        }
        
        [self.utility setWorksheetDict:[[NSDictionary alloc] initWithDictionary:temp]];
        NSLog(@"[NewEntry] Calling utility... %@", self.utility);
        [self.utility fetchRatNames];
        
    } else NSLog(@"[NewEntry] worksheet fetch error:%@", error);
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
    
    [self.ratTable reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - button reaction methods

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
}


#pragma mark - adding new entry methods...

- (IBAction) addEntryPressed{
    
    NSLog(@"Add New Entry Pressed!");
    NSLog(@"Population:%@ \n Rat:%@ \n Row: %@ \n NewWeight = %@", [[selectedWorksheet title] stringValue], [selectedRat objectForKey:@"name"], [selectedRat objectForKey:@"column"], [weightLabel text]);
    
    // Do input checking...
    if (selectedSpreadsheet == nil){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Entry" 
                                                        message:@"No selected experiment!"
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
    
    // TODO: add baselines... 
    
    
    // Figure out the row for today's date... NEW ASSUMPTION - THE DATE MUST ALREADY EXIST IN OUR SPREADSHEET. WE ARE NOT ADDING NEW ROWS.
    // Can edit the time length of an experiment in a separate feature... 
    
    // use utility to fetch first column of date list..
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.utility fromWorksheet:@"Weights" fetchColumn:1 selector:@selector(ticket:finishedWithDateCellFeed:error:)];
    
    NSString* entryMsg = [NSString stringWithFormat:@"Population: %@\nRat: %@\nDate: %@\nWeight: %@\nPellets: %@\nNote: %@", [[selectedWorksheet title]stringValue], [selectedRat objectForKey:@"name"], [dateLabel text], [weightLabel text], [pelletLabel text], notes];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Addding Entry" 
                                                    message:entryMsg
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
    
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
            
            dateRow =  i+2;
            NSLog(@"Date exists! at row %d", dateRow);
            
            [self.utility fetchCellfromWorksheet:@"Weights" row:dateRow column:ratColumn selector:@selector(ticket:finishedWithWeightCellFeed:error:)];
            return;
        }
    }
    
    NSLog(@"Date does not exist!!");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Adding Entry" 
                                                    message:@"Selected date does not exist." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Try Again" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWeightCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error{
    
    GDataEntrySpreadsheetCell* this = [[feed entries] objectAtIndex:0];
    NSLog(@"Going to edit cell %@ to %@", [[this title] contentStringValue], [weightLabel text]);
    
    [[this cell] setInputString:[weightLabel text]];
    [self.utility insertEntry:this into:@"Weights" selector:nil];
    [self.utility fetchCellfromWorksheet:@"Pellets" row:[this cell].row column:[this cell].column selector:@selector(ticket:finishedWithPelletCellFeed:error:)];
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithPelletCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error{
    
    GDataEntrySpreadsheetCell* this = [[feed entries] objectAtIndex:0];
    NSLog(@"Going to edit cell %@ to %@", [[this title] contentStringValue], [pelletLabel text]);
    
    [[this cell] setInputString:[pelletLabel text]];
    [self.utility insertEntry:this into:@"Pellets" selector:nil];
    [self.utility fetchCellfromWorksheet:@"Notes" row:[this cell].row column:[this cell].column selector:@selector(ticket:finishedWithNoteCellFeed:error:)];
    
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithNoteCellFeed:(GDataFeedSpreadsheetCell *)feed
         error:(NSError *)error {
    
    GDataEntrySpreadsheetCell* this = [[feed entries] objectAtIndex:0];
    NSLog(@"Going to edit cell %@ to %@", [[this title] contentStringValue], notes);
    
    [[this cell] setInputString:notes];
    [self.utility insertEntry:this into:@"Notes" selector:nil];
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

@end
