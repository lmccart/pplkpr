//
//  InteractionData.h
//  pplkpr
//
//  Created by Lauren McCarthy on 8/20/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface InteractionData : NSObject

@property (retain) NSMutableArray *locationsArray;

@property (retain) NSDictionary *summary;

@property (retain) Person *jumpToPerson;
@property (retain) NSString *jumpToEmotion;
@property BOOL jumpToOrder;

@property (nonatomic, strong) NSArray *emotionsArray;
@property (nonatomic, strong) NSDictionary *possibleActionsDict; // emotion -> array [order of actions]
@property (nonatomic, strong) NSDictionary *descriptiveActionsDict; // action -> array [future, past]
@property (nonatomic, strong) NSDictionary *messageDict; // emotion -> array [possible msgs for given emotion]

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (id)data;
- (id)init;
+ (NSDate *)getTodayDate;

- (Person *)getPerson:(NSString *)name withFbid:(NSString *)fbid save:(BOOL)save;
- (Report *)addReport:(NSString *)name
             withFbid:(NSString *)fbid
          withEmotion:(NSString *)emotion
           withRating:(NSNumber *)rating
             withDate:(NSDate *)date;
- (NSArray*)getAllPeople;
- (NSMutableDictionary *)getRankedPeople;
- (NSMutableArray *)getPriorities;
- (NSArray *)getSortedPriorities;
- (NSArray *)getRecentPeople;
- (void)saveLastReportDate:(NSDate *)date;
- (NSTimeInterval)getTimeSinceLastReport;
- (void)checkTakeAction;
- (void)takeAction;
- (void)checkTickets;

- (NSString *)getFutureAction:(NSString *)emotion forIndex:(int)ind;
- (NSString *)getFutureDescriptiveAction:(NSString *)emotion;
- (NSString *)getPastDescriptiveAction:(NSString *)action;
- (NSString *)getMessage:(NSString *)emotion;


@end


