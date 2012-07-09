//
//  SpreadsheetUtility.m
//  Rat Weight Tracker
//
//  Created by dummy on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpreadsheetUtility.h"

@implementation SpreadsheetUtility

@synthesize service, delegate, worksheetDict;

-(id)initWithService:(GDataServiceGoogleSpreadsheet *)serv delegate:(id)del andWorksheetDict:(NSDictionary *)dict
{
    [super init];
    
    self.service = serv;
    self.delegate = del;
    self.worksheetDict = dict;
    
    return self;
}

- (BOOL) checkUtility
{
    if (service == nil || delegate == nil || worksheetDict == nil) {
        NSLog(@"Utility imporoperly formatted -> one or more properties nil.");
        return NO;
    }
    else return YES;
}

- (void) fetchRatNames{
    
    NSLog(@"In fetch rat names...");
    
    if (![self checkUtility]) return;
    
    GDataEntryWorksheet* weightWorksheet = [self.worksheetDict objectForKey:@"Weights"];
    
    GDataQuerySpreadsheet *cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[weightWorksheet cellsLink] URL]];
    
    [cellQuery setShouldReturnEmpty:YES];
    
    cellQuery.minimumRow = 1;
    cellQuery.maximumRow = 1;
    cellQuery.minimumColumn = 2;
    
    [self.service fetchFeedWithQuery:cellQuery delegate:self.delegate didFinishSelector:@selector(ticket:finishedWithRatNameCellFeed:error:)];
    
    NSLog(@"Sent cell query...");
    
}

- (void) fromWorksheet:(NSString *)which fetchRow:(int)row selector:(SEL)sel{
    
    if (![self checkUtility]) return;
    
    GDataEntryWorksheet* whichWorksheet = [self.worksheetDict objectForKey:which];
    
    GDataQuerySpreadsheet* rowQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[whichWorksheet cellsLink] URL]];
    
    rowQuery.minimumColumn = 2;
    rowQuery.minimumRow = row;
    rowQuery.maximumRow = row;
    
    [self.service fetchFeedWithQuery:rowQuery delegate:self.delegate didFinishSelector:sel];
}

- (void) fetchCellfromWorksheet:(NSString *)which row:(int)row column:(int)col selector:(SEL)sel{
    
    if (![self checkUtility]) return;
    
    GDataEntryWorksheet* whichWorksheet = [self.worksheetDict objectForKey:which];
    
    GDataQuerySpreadsheet* cellQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[whichWorksheet cellsLink] URL]];
    
    [cellQuery setShouldReturnEmpty:YES];
    
    cellQuery.minimumColumn = col;
    cellQuery.maximumColumn = col;
    cellQuery.minimumRow = row;
    cellQuery.maximumRow = row;
    
    [self.service fetchFeedWithQuery:cellQuery delegate:self.delegate didFinishSelector:sel];
}

- (void) fromWorksheet:(NSString *)which fetchColumn:(int)col selector:(SEL)sel{
    
    if (![self checkUtility]) return;
    
    GDataEntryWorksheet* whichWorksheet = [self.worksheetDict objectForKey:which];
    
    GDataQuerySpreadsheet* columnQuery = [GDataQuerySpreadsheet queryWithFeedURL:[[whichWorksheet cellsLink] URL]];
    
    [columnQuery setShouldReturnEmpty:YES];
    
    columnQuery.minimumRow = 2;
    columnQuery.minimumColumn = col;
    columnQuery.maximumColumn = col;
    
    [self.service fetchFeedWithQuery:columnQuery delegate:self.delegate didFinishSelector:sel];
}

- (void) insertEntry:(GDataEntrySpreadsheetCell *)entry into:(NSString *)which selector:(SEL)sel
{
    if (![self checkUtility]) return;
    
    GDataEntryWorksheet* whichWorksheet = [self.worksheetDict objectForKey:which];
    
    [self.service fetchEntryByInsertingEntry:entry forFeedURL:[[whichWorksheet cellsLink] URL] delegate:self.delegate didFinishSelector:sel];
    
}

@end
