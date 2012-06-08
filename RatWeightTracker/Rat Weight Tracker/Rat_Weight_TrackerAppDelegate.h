//
//  Rat_Weight_TrackerAppDelegate.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Rat_Weight_TrackerViewController;

@interface Rat_Weight_TrackerAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Rat_Weight_TrackerViewController *viewController;

@end
