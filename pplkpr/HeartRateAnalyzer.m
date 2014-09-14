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

#import "linear.h"

@interface HeartRateAnalyzer()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *lastHRVUpdate;
@property (nonatomic, retain) DayLog *recentData;

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
    
        if (!self.recentData) {
            // create new object for this day
            self.recentData = [NSEntityDescription insertNewObjectForEntityForName:@"DayLog"
                                                   inManagedObjectContext:_managedObjectContext];
            // init props
            [self.recentData setDate:[NSDate date]];
            [self.recentData setRrs:[[NSMutableArray alloc] init]];
            [self.recentData setRr_times:[[NSMutableArray alloc] init]];
            [self.recentData setHrvs:[[NSMutableArray alloc] init]];
            [self.recentData setHrv_times:[[NSMutableArray alloc] init]];
            
            // save object
            NSError *error;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
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
    
    [self.recentData.rrs addObject:[NSNumber numberWithInteger:rr]];
    [self.recentData.rr_times addObject:time];
    NSLog(@"Saved RR");
    
    // calculate hrv every so many (~100 hundreds seconds)
    if (!self.lastHRVUpdate) {
        [self setLastHRVUpdate:time];
    }
    
    else if ([time timeIntervalSinceDate:self.lastHRVUpdate] >= 10) {
        
        // calculate HRV
        NSNumber *hrv = [dayLog.rrs lastObject];
        // PEND: calculate hrv properly from the last 100 seconds of data
        
        struct parameter param;
        struct problem prob;
        struct model* model_;
//        model_=train(&prob, &param);
        
        [dayLog.hrvs addObject:hrv];
        [dayLog.hrv_times addObject:time];
    
        [self.recentData.hrvs addObject:hrv];
        [self.recentData.hrv_times addObject:time];
        
        self.lastHRVUpdate = time;
        NSLog(@"Saved HRV %@", hrv);
        
        // PEND: trigger a push notification based on analysis of whether our current state is significant
        if ([hrv integerValue] > 0) {
            
            // trigger alert
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate triggerNotification:@"hrv"];
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

- (NSString *)getRRDataString {
    // stick together stored sensor data since last call to this method
    NSMutableString *dataString = [[NSMutableString alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    
    for (int i=0; i<[self.recentData.rrs count]; i++) {
        NSString *dateString = [dateFormatter stringFromDate:self.recentData.rr_times[i]];
        [dataString appendString:[NSString stringWithFormat:@"%@\t%d\n", dateString, [self.recentData.rrs[i] integerValue]]];
    }
    
    // clear out stored sensor data
    [self.recentData.rrs removeAllObjects];
    [self.recentData.rr_times removeAllObjects];
    
    // save object
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return dataString;
}

- (NSString *)getHRVDataString {
    // stick together stored sensor data since last call to this method
    NSMutableString *dataString = [[NSMutableString alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    
    for (int i=0; i<[self.recentData.hrvs count]; i++) {
        NSString *dateString = [dateFormatter stringFromDate:self.recentData.hrv_times[i]];
        [dataString appendString:[NSString stringWithFormat:@"%@\t%d\n", dateString, [self.recentData.hrvs[i] integerValue]]];
    }
    
    // clear out stored sensor data
    [self.recentData.hrvs removeAllObjects];
    [self.recentData.hrv_times removeAllObjects];
    
    // save object
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return dataString;
}


@end