//
//  SpreadsheetUtility.h
//  Rat Weight Tracker
//
//  Created by dummy on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GData.h"

@interface SpreadsheetUtility : NSObject {
    
}


@property (nonatomic,retain) GDataServiceGoogleSpreadsheet* service;
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSDictionary *worksheetDict;

- (id) initWithService:(GDataServiceGoogleSpreadsheet*)serv delegate:(id)del andWorksheetDict:(NSDictionary*)dict;

- (void) setWorksheetDict:(NSDictionary *)newdict;

- (void) setDelegate:(id)del;

- (void) fetchRatNames;

- (void) fromWorksheet:(NSString *)which fetchColumn:(int)col selector:(SEL)sel;

- (void) fromWorksheet:(NSString *)which fetchRow:(int)row selector:(SEL)sel;

- (void) fetchCellfromWorksheet:(NSString *)which row:(int)r column:(int)c selector:(SEL)sel;

- (void) insertEntry:(GDataEntrySpreadsheetCell*)entry into:(NSString*)which selector:(SEL)sel;

@end
