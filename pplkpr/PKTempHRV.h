//
//  PKTempHRV.h
//  pplkpr
//
//  Created by Lauren McCarthy on 6/21/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKTempHRV : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


+(id)data;
-(id)init;

- (NSMutableDictionary *)getHRVEvent;

@end


