//
//  MainMenuViewController.m
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "NewEntryViewController.h"
#import "GData.h"
#import "LogViewController.h"
#import "MBProgressHUD.h"
#import "ExperimentCreatorViewController.h"

@implementation MainMenuViewController


@synthesize logButton, addNewButton, loginButton, exprButton;
@synthesize usernameLabel;
@synthesize worksheetDict;
@synthesize spreadSheet;
@synthesize spreadSheetFeed, workSheetFeed, tableFeed, recordFeed;
@synthesize service;
@synthesize worksheets;

- (void)setUsername:(NSString *)name{
 
    NSString *newText = [NSString stringWithFormat:@"Logged in as:%@", name];
    
    self.usernameLabel.text = newText;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Initializing Main Menu View Controller..");
        
        
        // Currently default logs in to kemere.lab.sum2012 for easier testing.
        if (!self.service) {
            
            self.service = [[[GDataServiceGoogleSpreadsheet alloc] init] retain];
            [self.service setShouldCacheResponseData:YES];
            [self.service setUserCredentialsWithUsername:@"kemere.lab.sum2012" password:@"r@tweight@pp"];
            
            NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
            [self.service fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
        } 
    }
    return self;
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithSpreadsheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    if (error == nil){
        
        //Successful retrieval of spreadsheet fields.
        self.spreadSheetFeed = feed;
        NSArray *entries = [feed entries];
        
        for (int i = 0; i < [entries count]; i++) {
            
            GDataEntrySpreadsheet *next = [entries objectAtIndex:i];
            GDataTextConstruct *titleTextConstruct = [next title];
            NSString *title = [titleTextConstruct stringValue];
            
            if ([title rangeOfString:@"Kemere Lab Rat Weights"].location == NSNotFound){
                NSLog(@"I do not care about %@", title);
            } else {
                NSLog(@"Found %@", title);
                self.spreadSheet = next;
            }
        }
        
        if (spreadSheet) {
            
            //Found spreadsheet, send query to fetch its worksheets.
            NSURL *worksheetsURL = [spreadSheet worksheetsFeedURL];
            
            [service fetchFeedWithURL:worksheetsURL 
                             delegate:self 
                    didFinishSelector:@selector(ticket:finishedWithWorksheetFeed:error:)];
            
        } else NSLog(@"Could not find the spreadsheet Kemere Lab Rat Weights");
        
        
    } else {
        NSLog(@"Fetch error: %@", error.description);
        
        if ([error.description rangeOfString:@"BadAuthentication"].location == NSNotFound){
            NSLog(@"I do not care about this error.");
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                            message:@"Incorrect username or password." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Try Again" 
                                                  otherButtonTitles:nil];
            
            [alert show];
    
            self.service = nil;
            [self setUsername:@""];
        }
    }
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWorksheetFeed:(GDataFeedWorksheet *)feed
         error:(NSError *)error {
    
    if (error == nil){
        
        //Successfully retrieved worksheet feed.
        self.workSheetFeed = feed;
        self.worksheets = [feed entries];
        
        NSMutableDictionary *temp = [[[NSMutableDictionary alloc] init] autorelease];
        
        for (int i = 0; i < [[feed entries] count]; i++) {
            GDataEntryWorksheet *ws = [[feed entries] objectAtIndex:i];
            
            NSLog(@"Found worksheet %@ : with rows:%d and columns:%d", 
                  [[ws title] stringValue], [ws rowCount], [ws columnCount]);
            
            [temp setObject:ws forKey:[[ws title] stringValue]];
        }
        
        self.worksheetDict = [[NSDictionary alloc]  initWithDictionary:temp];
        
        NSLog(@"%@", [worksheetDict allKeys]);
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

#pragma mark - View stuff

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [logButton setupAsGreenButton];
    [addNewButton setupAsRedButton];
    [loginButton setupAsGreenButton];
    [exprButton setupAsRedButton];
    
    self.view.backgroundColor = [UIColor clearColor];
        
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationPortrait) return YES;
	else return NO;
}

#pragma mark - Button pressed response methods

- (IBAction) logPressed {
    
    UINavigationController *navcon = [self navigationController];
    LogViewController *newcon = [[LogViewController alloc] initWithSpreadsheet:self.worksheetDict andService:self.service];
    [navcon pushViewController:newcon animated:YES];
    
}

- (IBAction) addNewPressed {
    
    UINavigationController *navcon = [self navigationController];
    NewEntryViewController *newcon = [[NewEntryViewController alloc] initWithWorksheets:worksheets andService:service];
    [navcon pushViewController:newcon animated:YES];
    
}

- (IBAction) newExperimentPressed
{
    UINavigationController *navcon = [self navigationController];
    ExperimentCreatorViewController *exprCon = [[ExperimentCreatorViewController alloc] initWithService:self.service];
    [navcon pushViewController:exprCon animated:YES];
}

- (IBAction) loginPressed {
    
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Enter your Google login information." delegate:self cancelButtonTitle:@"OK." otherButtonTitles:nil];
    
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    [loginAlert show];
    [loginAlert release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    
    NSLog(@"Username: %@",[[alertView textFieldAtIndex:0] text]);
    NSLog(@"Passowrd: %@",[[alertView textFieldAtIndex:1] text]);
    
    NSString *username = [[alertView textFieldAtIndex:0] text];
    NSString *password = [[alertView textFieldAtIndex:1] text];
    
    GDataServiceGoogleSpreadsheet *tempservice = [[[GDataServiceGoogleSpreadsheet alloc] init] retain];
    
    [tempservice setShouldCacheResponseData:YES];
    
    [tempservice setUserCredentialsWithUsername:username password:password];
    
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [tempservice fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
    
    [self setUsername:username];
    
    NSLog(@"Done..");
}
     

@end
