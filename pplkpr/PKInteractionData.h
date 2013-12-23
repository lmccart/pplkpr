//
//  PKInteractionData.h
//  pplkpr
//
//  Created by Lauren McCarthy on 8/20/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKInteractionData : NSObject

@property (retain) NSMutableArray *locationsArray;

@property (retain) NSDictionary *summary;

@property (retain) NSString *jumpToName;

@property (nonatomic, strong) NSArray *emotionsArray;



@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+(id)data;
-(id)init;

- (void)addReport:(NSString *)name withEmotion:(NSString *)emotion withRating:(NSNumber *)rating;
- (NSArray*)getAllReports;
- (NSArray*)getAllPeople;
- (void)calculateGlobalAverages;
- (NSMutableDictionary *)getRankedPeople;

@end


