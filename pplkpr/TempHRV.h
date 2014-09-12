//
//  TempHRV.h
//  pplkpr
//
//  Created by Lauren McCarthy on 6/21/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempHRV : NSObject

+(id)data;
-(id)init;

- (NSMutableDictionary *)getHRVEvent;

@end


