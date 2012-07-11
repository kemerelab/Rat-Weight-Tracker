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
#import "Reachability.h"

@implementation MainMenuViewController

@synthesize logButton, addNewButton, loginButton, exprButton;
@synthesize usernameLabel;
@synthesize worksheetDict;
@synthesize spreadSheet;
@synthesize spreadSheetFeed, workSheetFeed, tableFeed, recordFeed;
@synthesize service, docsService;
@synthesize worksheets;

- (void)setUsername:(NSString *)name{
 
    NSLog(@"Setting username...");
    NSString *newText = [NSString stringWithFormat:@"Logged in as:%@", name];
    
    self.usernameLabel.text = newText;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Initializing Main Menu View Controller..");
        
        loggedIn = NO;
        // Currently default logs in to kemere.lab.sum2012 for easier testing.
        if (!self.service) {
            
            self.docsService = [[GDataServiceGoogleDocs alloc] init];
            [self.docsService setShouldCacheResponseData:YES];
            [self.docsService setUserCredentialsWithUsername:@"kemere.lab.sum2012" password:@"r@tweight@pp"];
            
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
            
            [self enable:addNewButton];
            [self enable:logButton];
            
            //Found spreadsheet, send query to fetch its worksheets.
            NSURL *worksheetsURL = [spreadSheet worksheetsFeedURL];
            
            [service fetchFeedWithURL:worksheetsURL 
                             delegate:self 
                    didFinishSelector:@selector(ticket:finishedWithWorksheetFeed:error:)];
            
        } else NSLog(@"Could not find the spreadsheet Kemere Lab Rat Weights");
        
        
    } else {
        NSLog(@"Fetch error: %@", error.description);
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

- (void)disable:(MOGlassButton*)button{
    button.enabled = NO;
    button.alpha = 0.5;
}

- (void)enable:(MOGlassButton*)button{
    button.enabled = YES;
    button.alpha = 1.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [logButton setupAsRedButton];
    [addNewButton setupAsGreenButton];
    [loginButton setupAsGreenButton];
    [exprButton setupAsRedButton];
    
    [self disable:logButton];
    [self disable:addNewButton];
    [self disable:exprButton];
    
    self.view.backgroundColor = [UIColor clearColor];
        
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    NetworkStatus status = [internetReachable currentReachabilityStatus];
    
    if (status == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection." message:@"Your device is currently not connected to the internet. Because of that, the app will not be able to connect retrieve your rat weight spreadsheets or edit them." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
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
    ExperimentCreatorViewController *exprCon = [[ExperimentCreatorViewController alloc] initWithService:self.service andDocsService:self.docsService];
    [navcon pushViewController:exprCon animated:YES];
}

- (IBAction) loginPressed {
    
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Enter your Google login information." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login",nil];
    
    loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    NSString* prevUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"ratweightusername"];
    NSLog(@"found prev user %@", prevUser);
    if (prevUser != nil) {
        NSLog(@"found prev user %@", prevUser);
        [loginAlert textFieldAtIndex:0].text = prevUser;
        
    }
    
    [loginAlert show];
    [loginAlert release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    
    if ([alertView.title isEqualToString:@"Login"]){
    
        NSLog(@"Username: %@",[[alertView textFieldAtIndex:0] text]);
        NSLog(@"Passowrd: %@",[[alertView textFieldAtIndex:1] text]);

        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];

        if ([username length] == 0) {
            UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"No username given!" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [failAlert show];
            [failAlert release];
            return;
        }

        self.service = [[[GDataServiceGoogleSpreadsheet alloc] init] retain];

        [self.service setShouldCacheResponseData:YES];

        [self.service setUserCredentialsWithUsername:username password:password];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [self.service authenticateWithDelegate:self didAuthenticateSelector:@selector(ticket:authenticatedWithError:)];

        [self setUsername:username];
    }
    
    if ([alertView.title isEqualToString:@"Successful Login"]){
        NSLog(@"Saving name...");
        NSString* username = [self.usernameLabel.text stringByReplacingOccurrencesOfString:@"Logged in as:" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"ratweightusername"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (void)ticket:(GDataServiceTicket *)ticket
   authenticatedWithError:(NSError *)error {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Incorrect username or password." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Try Again" 
                                              otherButtonTitles:nil];
        
        [alert show];
        
        self.service = nil;
        [self setUsername:@""];
    }
    
    else {
        
        UIAlertView *remember = [[UIAlertView alloc] initWithTitle:@"Successful Login" message:@"You have successfully logged in. Would you like the application to remember your username for future use?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [remember show];
        [remember release];
        
        NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
        
        [self enable:exprButton];
        
        [self.service fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
        
        NSLog(@"Done..");
    }
    
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
            
        {   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You have lost connection to the internet. Without a reliable connection, the application will not be able to retrieve your spreadsheets or add changes to them." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
            break;
            
        default:
            NSLog(@"Internet available.");
            break;
    }
}
     

@end
