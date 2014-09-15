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

#include "linear.h"
#include "hrv.h"

@interface HeartRateAnalyzer()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *lastStressUpdateTime;
@property (nonatomic, retain) NSNumber *lastStressValue;
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
    [self.recentData.rrs addObject:[NSNumber numberWithInteger:rr]];
    [self.recentData.rr_times addObject:time];
//    NSLog(@"Saved RR");
    
    // calculate hrv every so many (~100 seconds)
    if (!self.lastStressUpdateTime) {
        self.lastStressUpdateTime = time;
        self.lastStressValue = [NSNumber numberWithFloat:0.5];
    } else if ([time timeIntervalSinceDate:self.lastStressUpdateTime] >= 10) {
        
        // PEND: instead of using all rrs, just need last 100 seconds
        // PEND: if 100 seconds of data isn't available, forget about it (e.g., right after POSTing the data)
        NSMutableArray* chunk = self.recentData.rrs;
        
        // convert NSMutableArray of NSNumbers to vector<float>
        int n = [chunk count];
        std::vector<float> rrms(n);
        for(int i = 0; i < n; i++) {
            rrms[i] = [chunk[i] floatValue];
        }
        
        // get all hrv metrics
        std::vector<double> hrvMetrics = hrv::buildMetrics(rrms);
        
        // prepare hrv metrics in feature_nodes
        int featureCount = hrvMetrics.size();
        std::vector<feature_node> data(featureCount + 1); // need extra for end feature
        for(int i = 0; i < featureCount; i++) {
            data[i].index = i + 1; // features are 1-indexed for liblinear
            data[i].value = hrvMetrics[i];
//            NSLog(@"HRV metric %d: %f", i, hrvMetrics[i]);
        }
        data[featureCount].index = -1; // end of elements list
        
        // load linear regression model and run prediction
        NSString * path = [[NSBundle mainBundle] pathForResource: @"mio-8" ofType: @"model"];
        struct model* model_ = load_model(path.UTF8String);
        double stress = predict(model_, &(data.front()));
        free_and_destroy_model(&model_);
        
        // clamp output to 0 to 1 range?
        // people might go above/below if the data is very different from the driver-stress dataset
        stress = MAX(stress, 0);
        stress = MIN(stress, 1);
        
        NSNumber *stressNumber = [NSNumber numberWithFloat:stress];
    
        [self.recentData.hrvs addObject:stressNumber];
        [self.recentData.hrv_times addObject:time];
        
        self.lastStressUpdateTime = time;
        self.lastStressValue = stressNumber;
        
        NSLog(@"Saved stress level %@", stressNumber);
        
        // PEND: trigger a push notification based on analysis of whether our current state is significant
        if (stress > .9) {
            // trigger alert
            AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate triggerNotification:@"hrv"];
        }
    }
}


- (NSMutableDictionary *)getStressEvent {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:self.lastStressValue forKey:@"intensity"];
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