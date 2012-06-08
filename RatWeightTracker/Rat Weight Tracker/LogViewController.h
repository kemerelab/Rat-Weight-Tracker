//
//  LogViewController.h
//  Rat Weight Tracker
//
//  Created by Carolyn E Boland on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogViewController : UITableViewController {
    
}

@property (nonatomic, retain) NSArray *populations;

-(id)initWithPopulations:(NSArray *)pops;

@end
