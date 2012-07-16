//
//  RatInfoViewController.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"
#import "SpreadsheetUtility.h"
#import "CorePlot-CocoaTouch.h"

@interface RatInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CPTPlotDataSource>{
 
    int ratColumn;
    NSString* name;
}

@property (nonatomic, retain) IBOutlet UILabel* ratNameLabel;

@property (nonatomic, retain) IBOutlet UITableView* entriesTable;

@property (nonatomic, retain) IBOutlet UITextView* notesView;

@property (nonatomic, retain) IBOutlet CPTGraphHostingView* graphView;

@property (nonatomic, retain) CPTXYGraph* weightGraph;

@property (nonatomic, retain) CPTXYGraph* pelletGraph;

@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;

@property (nonatomic,retain) GDataEntryWorksheet* worksheet;

@property (nonatomic,retain) NSMutableArray* weightEntries; // Of NSDictionary objects with keys date, pellets, weight

@property (nonatomic,retain) SpreadsheetUtility* utility;

-(id)initWithUtility:(SpreadsheetUtility*)util andRat:(NSDictionary*)rat;

- (IBAction) switchPressed: (UISegmentedControl*)sender;

@end
