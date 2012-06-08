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


@interface MainMenuViewController : UIViewController  {
    
}

@property (nonatomic,retain) IBOutlet MOGlassButton* logButton;
@property (nonatomic,retain) IBOutlet MOGlassButton* addNewButton;

@property (nonatomic,retain) GDataFeedSpreadsheet* spreadSheetFeed;
@property (nonatomic,retain) GDataFeedWorksheet* workSheetFeed;
@property (nonatomic,retain) GDataFeedSpreadsheetTable* tableFeed;
@property (nonatomic,retain) GDataFeedSpreadsheetRecord* recordFeed;

@property (nonatomic,retain) GDataEntrySpreadsheet* spreadSheet;
@property (nonatomic,retain) NSArray *worksheets;
@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;

- (IBAction) logPressed;

- (IBAction) addNewPressed;

@end
