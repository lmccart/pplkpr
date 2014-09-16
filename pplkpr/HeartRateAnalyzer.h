//
//  HeartRateAnalyzer.h
//  pplkpr
//
//  Created by Lauren McCarthy on 6/21/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeartRateAnalyzer : NSObject

+(id)data;
-(id)init;

- (NSMutableDictionary *)getStressEvent;

- (void)addRR:(NSInteger)rr withTime:(NSDate *)time;

- (NSString *)getRRDataString;
- (NSString *)getHRVDataString;
- (void) resetRecentData;

@end


