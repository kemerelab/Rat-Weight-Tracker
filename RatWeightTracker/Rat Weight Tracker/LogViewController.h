//
//  LogViewController.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"


@interface LogViewController : UITableViewController {
    
}

@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;

@property (nonatomic,retain) GDataEntryWorksheet* selectedWorksheet;
@property (nonatomic,retain) NSIndexPath* selectedWorksheetPath;

@property (nonatomic,retain) NSDictionary* selectedRat;

@property (nonatomic,retain) NSArray* populationsList; // Of GDataEntryWorksheets.

@property (nonatomic,retain) NSArray* ratList; // of NSDictionaries with row: and name:

- (id) initWithWorksheets:(NSArray*)ws andService:(GDataServiceGoogleSpreadsheet*)serv;

@end
