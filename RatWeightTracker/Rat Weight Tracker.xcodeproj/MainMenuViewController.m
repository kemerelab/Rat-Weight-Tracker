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

@implementation MainMenuViewController

@synthesize logButton, addNewButton;

@synthesize spreadSheet;
@synthesize spreadSheetFeed, workSheetFeed, tableFeed, recordFeed;

@synthesize service;

@synthesize worksheets;


- (void)ticket:(GDataServiceTicket *)ticket
finishedWithListFeed:(GDataFeedWorksheet *)feed
         error:(NSError *)error {
    
    if (error == nil) {
        
        NSLog(@"found list! woot.");
        
        GDataEntrySpreadsheetList *firstlist = [[feed entries] objectAtIndex:0];
        
        NSLog(@"first list title = %@", [[firstlist title] stringValue]);
        
        for (int i = 0; i < [[firstlist customElements] count]; i++){
           
            //GDataSpreadsheetCustomElement *this = [[firstlist customElements] objectAtIndex:i];
            
            //NSLog(@"Value = %@", [this stringValue]);
            
        }
        
    }
    
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithWorksheetFeed:(GDataFeedWorksheet *)feed
         error:(NSError *)error {
    
    if (error == nil){
        
        self.workSheetFeed = feed;
        
        self.worksheets = [feed entries];
        
        for (int i = 0; i < [[feed entries] count]; i++) {
            GDataEntryWorksheet *ws = [[feed entries] objectAtIndex:i];
            NSLog(@"Found worksheet %@ : with rows:%d and columns:%d", [[ws title] stringValue], [ws rowCount], [ws columnCount]);
            
            NSURL *listURL = [ws listFeedURL];
            
            [service fetchFeedWithURL:listURL delegate:self didFinishSelector:@selector(ticket:finishedWithListFeed:error:)];
        }
    }
}

- (void)ticket:(GDataServiceTicket *)ticket
finishedWithSpreadsheetFeed:(GDataFeedSpreadsheet *)feed
         error:(NSError *)error {
    
    if (error == nil) {
        
        self.spreadSheetFeed = feed;
        
        NSArray *entries = [feed entries];
        
        if ([entries count] > 0) {
            
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
                
                
                NSURL *worksheetsURL = [spreadSheet worksheetsFeedURL];
                
                if (worksheetsURL){
                    
                    [service fetchFeedWithURL:worksheetsURL delegate:self didFinishSelector:@selector(ticket:finishedWithWorksheetFeed:error:)];
                    
                } else {
                    NSLog(@"No worksheets...!");
                }
                
            } else {
                NSLog(@"Couldn't find the spreadsheet!!");
            }  
            
            
        } else {
            NSLog(@"user has no spreadsheets..");
        }
        
    } else {
        NSLog(@"fetch error: %@", error);
    }
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"In Main Menu Init..");
        
        if (!self.service) {
            self.service = [[[GDataServiceGoogleSpreadsheet alloc] init] retain];
            
            [self.service setShouldCacheResponseData:YES];
            
            [self.service setUserCredentialsWithUsername:@"kemere.lab.sum2012" password:@"r@tweight@pp"];
            
            NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
            
            GDataServiceTicket *ticket;
            ticket = [self.service fetchFeedWithURL:feedURL delegate:self didFinishSelector:@selector(ticket:finishedWithSpreadsheetFeed:error:)];
            
        } 
    }
    return self;
}

- (void)dealloc
{
    
    self.logButton = nil;
    self.addNewButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [logButton setupAsGreenButton];
    [addNewButton setupAsRedButton];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction) logPressed {
    
    UINavigationController *navcon = [self navigationController];
    LogViewController *newcon = [[LogViewController alloc] initWithWorksheets:worksheets andService:service];
    [navcon pushViewController:newcon animated:YES];
    
}

- (IBAction) addNewPressed {
    
    UINavigationController *navcon = [self navigationController];
    NewEntryViewController *newcon = [[NewEntryViewController alloc] initWithWorksheets:worksheets andService:service];
    [navcon pushViewController:newcon animated:YES];
    
}
     

@end
