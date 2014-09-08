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

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (id)data;
- (id)init;

- (Person *)addReport:(NSString *)name withFbid:(NSString *)fbid withEmotion:(NSString *)emotion withRating:(NSNumber *)rating;
- (NSArray*)getAllReports;
- (NSArray*)getAllPeople;
- (void)calculateGlobalAverages;
- (NSMutableDictionary *)getRankedPeople;
- (NSMutableArray *)getPriorities;
- (NSArray *)getSortedPriorities;
- (NSArray *)getRecentPeople;
- (void)takeAction;



@end


