//
//  ExperimentCreatorViewController.h
//  Rat Weight Tracker
//
//  Created by Help Desk on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"
#import "MOGlassButton.h"

@interface ExperimentCreatorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;

@property (nonatomic,retain) IBOutlet UITextField* nameField;

@property (nonatomic,retain) IBOutlet UITextField* ratNameField;

@property (nonatomic,retain) IBOutlet MOGlassButton* addRatButton;

@property (nonatomic,retain) IBOutlet MOGlassButton* removeRatButton;

@property (nonatomic,retain) NSIndexPath* selectedRat;

@property (nonatomic,retain) IBOutlet UITableView* ratTable;

@property (nonatomic,retain) NSMutableArray* ratList;

@property (nonatomic,retain) NSDate* startDate;

@property (nonatomic,retain) NSDate* endDate;

@property (nonatomic,retain) IBOutlet MOGlassButton* editStartButton;

@property (nonatomic,retain) IBOutlet MOGlassButton* editEndButton;

- (id) initWithService:(GDataServiceGoogleSpreadsheet*)serv;

- (IBAction) buttonPressed:(id)sender;

@end
