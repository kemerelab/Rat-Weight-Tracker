//
//  NewEntryViewController.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOGlassButton.h"
#import "GData.h"

@interface NewEntryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
    BOOL dateExists;
    int dateRow;
    int numRats;
    
}

@property (nonatomic,retain) NSString* which;

@property (nonatomic,retain) IBOutlet MOGlassButton* addButton;

@property (nonatomic,retain) IBOutlet MOGlassButton* notesButton;

@property (nonatomic,retain) NSString *notes;

@property (nonatomic,retain) IBOutlet UITableView* populationTable;

@property (nonatomic,retain) IBOutlet UITableView* ratTable;

@property (nonatomic,retain) IBOutlet UILabel* weightLabel;

@property (nonatomic,retain) IBOutlet UILabel* dateLabel;

@property (nonatomic,retain) IBOutlet UILabel* pelletLabel;

@property (nonatomic,retain) NSArray* cellEntries;

@property (nonatomic,retain) GDataEntrySpreadsheetCell* foundCell;


@property (nonatomic,retain) IBOutlet MOGlassButton* one;
@property (nonatomic,retain) IBOutlet MOGlassButton* two;
@property (nonatomic,retain) IBOutlet MOGlassButton* three;
@property (nonatomic,retain) IBOutlet MOGlassButton* four;
@property (nonatomic,retain) IBOutlet MOGlassButton* five;
@property (nonatomic,retain) IBOutlet MOGlassButton* six;
@property (nonatomic,retain) IBOutlet MOGlassButton* seven;
@property (nonatomic,retain) IBOutlet MOGlassButton* eight;
@property (nonatomic,retain) IBOutlet MOGlassButton* nine;
@property (nonatomic,retain) IBOutlet MOGlassButton* zero;
@property (nonatomic,retain) IBOutlet MOGlassButton* clear; 

@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;

@property (nonatomic,retain) GDataEntryWorksheet* selectedWorksheet;
@property (nonatomic,retain) NSDictionary* selectedRat;

@property (nonatomic,retain) NSArray* worksheetPopulations; // Of GDataEntryWorksheets.

@property (nonatomic,retain) NSArray* ratList; // of NSDictionaries with row: and name:

- (id) initWithWorksheets:(NSArray*)ws andService:(GDataServiceGoogleSpreadsheet*)serv;

- (IBAction) addEntryPressed;

- (IBAction) notesPressed;

- (IBAction) digitPressed: (MOGlassButton*)sender;

- (IBAction) switchPressed: (UISegmentedControl*)sender;


@end
