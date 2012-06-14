//
//  RatInfoViewController.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"

@interface RatInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
 
    int ratColumn;
}

@property (nonatomic, retain) IBOutlet UILabel* ratNameLabel;

@property (nonatomic, retain) IBOutlet UITableView* entriesTable;

@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;

@property (nonatomic,retain) GDataEntryWorksheet* worksheet;

@property (nonatomic,retain) NSMutableArray* weightEntries; // Of NSDictionary objects with keys date, pellets, weight

-(id)initWithWorksheet:(GDataEntryWorksheet*)ws andService:(GDataServiceGoogleSpreadsheet*)serv andRat:(NSDictionary*)rat;

@end
