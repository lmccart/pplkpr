//
//  TempHRV.m
//  pplkpr
//
//  Created by Lauren McCarthy on 6/21/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "TempHRV.h"
#import "AppDelegate.h"

@interface TempHRV()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end


@implementation TempHRV

+ (id)data {
    static TempHRV *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}

- (id)init {
	
    if (self = [super init]) {
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
	}
    
    return self;
}



- (NSMutableDictionary *)getHRVEvent {
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithFloat:0.5] forKey:@"intensity"];

	return dict;
}

- (NSString *)getSensorData {
    return @"this is a test string of data @todo";
}

@end