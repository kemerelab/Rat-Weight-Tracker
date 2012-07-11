//
//  MainMenuViewController.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOGlassButton.h"

#import "GData.h"

@class Reachability;

@interface MainMenuViewController : UIViewController  {
    Reachability* internetReachable;
    BOOL loggedIn;
}

@property (nonatomic,retain) IBOutlet MOGlassButton* logButton;
@property (nonatomic,retain) IBOutlet MOGlassButton* addNewButton;
@property (nonatomic,retain) IBOutlet MOGlassButton* loginButton;
@property (nonatomic,retain) IBOutlet MOGlassButton* exprButton;

@property (nonatomic,retain) IBOutlet UILabel* usernameLabel;

@property (nonatomic,retain) NSDictionary* worksheetDict;

@property (nonatomic,retain) GDataFeedSpreadsheet* spreadSheetFeed;
@property (nonatomic,retain) GDataFeedWorksheet* workSheetFeed;
@property (nonatomic,retain) GDataFeedSpreadsheetTable* tableFeed;
@property (nonatomic,retain) GDataFeedSpreadsheetRecord* recordFeed;

@property (nonatomic,retain) GDataEntrySpreadsheet* spreadSheet;
@property (nonatomic,retain) NSArray *worksheets;
@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;
@property (nonatomic,retain) GDataServiceGoogleDocs* docsService;

- (IBAction) logPressed;

- (IBAction) addNewPressed;

- (IBAction) loginPressed;

- (IBAction) newExperimentPressed;

- (void)checkNetworkStatus:(NSNotification *)notice;

@end
