//
//  HeartRateAnalyzer.m
//  pplkpr
//
//  Created by Lauren McCarthy on 6/21/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "HeartRateAnalyzer.h"
#import "AppDelegate.h"
#import "DayLog.h"

@interface HeartRateAnalyzer()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *lastHRVUpdate;

@end


@implementation HeartRateAnalyzer

+ (id)data {
    static HeartRateAnalyzer *data = nil;
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


- (DayLog *)getTodayLog {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DayLog"
                                              inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    
    NSDate *date = [DayLog getTodayDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
    
    DayLog *dayLog;
    
    if (results && [results count] > 0) {
        // return existing object
        dayLog = [results objectAtIndex:0];
    } else {
        // create new object for this day
        dayLog = [NSEntityDescription insertNewObjectForEntityForName:@"DayLog"
                                               inManagedObjectContext:_managedObjectContext];
        // init props
        [dayLog setDate:date];
        [dayLog setRrs:[[NSMutableArray alloc] init]];
        [dayLog setRr_times:[[NSMutableArray alloc] init]];
        [dayLog setHrvs:[[NSMutableArray alloc] init]];
        [dayLog setHrv_times:[[NSMutableArray alloc] init]];
        
        // save object
        NSError *error;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }

    return dayLog;
}



- (void)addRR:(NSInteger)rr withTime:(NSDate *)time {
    // store in core data the values
    DayLog *dayLog = [self getTodayLog];
    [dayLog.rrs addObject:[NSNumber numberWithInteger:rr]];
    [dayLog.rr_times addObject:time];
    NSLog(@"Saved RR");
    
    // calculate hrv every so many (~100 hundreds seconds)
    if (!self.lastHRVUpdate) {
        [self setLastHRVUpdate:time];
    }
    
    else if ([time timeIntervalSinceDate:self.lastHRVUpdate] >= 10) {
        
        // calculate HRV
        NSNumber *hrv = [dayLog.rrs lastObject];
        // PEND: calculate hrv properly from the last 100 seconds of data
        
        [dayLog.hrvs addObject:hrv];
        [dayLog.hrv_times addObject:time];
    
        self.lastHRVUpdate = time;
        NSLog(@"Saved HRV %@", hrv);
        
        // PEND: trigger a push notification based on analysis of whether our current state is significant
        if ([hrv integerValue] > 0) {
            
            // trigger alert
            UILocalNotification * notification = [[UILocalNotification alloc] init];
            notification.alertBody = @"What's your damage bra?";
            notification.alertAction = @"Report";
            notification.hasAction = YES;
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    
    // save object
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}


- (NSMutableDictionary *)getHRVEvent {
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithFloat:0.5] forKey:@"intensity"];

	return dict;
}

- (NSString *)getSensorData {
    // stick together stored sensor data since last call to this method
    // clear out stored sensor data
    return @"this is a test string of data @todo";
}


@end