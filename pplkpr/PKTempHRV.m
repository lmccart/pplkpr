//
//  PKTempHRV.m
//  pplkpr
//
//  Created by Lauren McCarthy on 6/21/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "PKTempHRV.h"
#import "PKAppDelegate.h"

@interface PKTempHRV()

@end


@implementation PKTempHRV

+ (id)data {
    static PKTempHRV *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}

- (id)init {
	
    if (self = [super init]) {
        PKAppDelegate* appDelegate = (PKAppDelegate*)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
	}
    
    return self;
}



- (NSMutableDictionary *)getHRVEvent {
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithFloat:0.5] forKey:@"intensity"];

	return dict;
}

@end