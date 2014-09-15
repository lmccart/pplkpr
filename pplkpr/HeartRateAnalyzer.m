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
@property (nonatomic, retain) DayLog *recentData;

@property (nonatomic, retain) NSDate *lastStressUpdateTime;
@property (nonatomic, retain) NSMutableArray *rrs;
@property float lastStressValue;

// configuration
@property float stressUpdateInterval;
@property float stressThreshold;
@property float stressThresholdRate;
@property float stressSmoothedRate;
@property float notifyTimeMinimum;

// running values
@property float stressSmoothed;
@property (nonatomic, retain) NSDate *notifyTimePrevious;


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
        self.rrs = [[NSMutableArray alloc] init];
        self.lastStressValue = 0.5;
        
        // configuration
        self.stressUpdateInterval = 100; // smallest HRV interval used by researchers is 100 seconds
        self.stressThreshold = 0.5; // lower this to have a notification pop up sooner on startup
        self.stressThresholdRate = 0.01; // this allows the threshold to slowly adapt on too many/few crossings
        self.stressSmoothedRate = 0.5; // adapt rate, means that stress must be sustained to cause a notification, 1 disables
        self.notifyTimeMinimum = 3600; // minimum time between notifications, 1 hour in seconds
        
        // running values
        self.stressSmoothed = 0.5;
        
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

- (float) lerpFrom:(float)a to:(float)b at:(float)t {
    return ((1 - t) * a) + (t * b);
}

- (void)addRR:(NSInteger)rr withTime:(NSDate *)time {
    [self.rrs addObject:[NSNumber numberWithInteger:rr]];
    [self.recentData.rrs addObject:[NSNumber numberWithInteger:rr]];
    [self.recentData.rr_times addObject:time];
    
    // calculate hrv every stressUpdateInterval seconds
    if (!self.lastStressUpdateTime) {
        self.lastStressUpdateTime = time;
    } else if ([time timeIntervalSinceDate:self.lastStressUpdateTime] > self.stressUpdateInterval) {
        // PEND: if not enough data is available, forget about calculating hrv metrics
        
        // convert NSMutableArray of NSNumbers to vector<float>
        int n = [self.rrs count];
        NSLog(@"Processing %d rrs over %f seconds", n, self.stressUpdateInterval);
        std::vector<float> rrms(n);
        for(int i = 0; i < n; i++) {
            rrms[i] = [self.rrs[i] floatValue];
        }
        // clear in preparation for next update
        [self.rrs removeAllObjects];
        
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
        // PEND: cache model by loading it once in init
        NSString * path = [[NSBundle mainBundle] pathForResource: @"mio-8" ofType: @"model"];
        struct model* model_ = load_model(path.UTF8String);
        float stress = (float) predict(model_, &(data.front()));
        free_and_destroy_model(&model_);
        
        // clamp output to 0 to 1 range?
        // people might go above/below if the data is very different from the driver-stress dataset
        NSLog(@"Raw stress is %f", stress);
        stress = MAX(stress, 0);
        stress = MIN(stress, 1);
    
        [self.recentData.hrvs addObject:[NSNumber numberWithFloat:stress]];
        [self.recentData.hrv_times addObject:time];
        
        self.lastStressUpdateTime = time;
        self.lastStressValue = stress;
        
        NSLog(@"Saved stress is %f", stress);
        
        self.stressSmoothed = [self lerpFrom:self.stressSmoothed to:stress at:self.stressSmoothedRate];
        double timeElapsed = [time timeIntervalSinceDate:self.notifyTimePrevious];
        if(!self.notifyTimePrevious) {
            timeElapsed = self.notifyTimeMinimum;
        }
        if (self.stressSmoothed >= self.stressThreshold) {
            if (timeElapsed >= self.notifyTimeMinimum) {
                self.notifyTimePrevious = time;
                NSLog(@"Sending notification duration %f > %f and stress %f > %f", timeElapsed, self.notifyTimeMinimum, self.stressSmoothed, self.stressThreshold);
                AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate triggerNotification:@"hrv"];
            } else {
                NSLog(@"Notifying too often, raising threshold %f towards %f", self.stressThreshold, self.stressSmoothed);
                self.stressThreshold = [self lerpFrom:self.stressThreshold to:self.stressSmoothed at:self.stressThresholdRate];
                NSLog(@"New threshold is %f", self.stressThreshold);
            }
        }
        if(timeElapsed >= self.notifyTimeMinimum) {
            NSLog(@"Notifying too rarely, lowering threshold %f towards %f", self.stressThreshold, self.stressSmoothed);
            self.stressThreshold = [self lerpFrom:self.stressThreshold to:self.stressSmoothed at:self.stressThresholdRate];
            NSLog(@"New threshold is %f", self.stressThreshold);
        }
    }
}


- (NSMutableDictionary *)getStressEvent {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithFloat:self.lastStressValue] forKey:@"intensity"];
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