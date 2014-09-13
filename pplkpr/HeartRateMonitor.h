//
//  HeartRateMonitor.h
//  HRM
//
//  Created by Lauren McCarthy on 7/15/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "ViewController.h"

@interface HeartRateMonitor : NSObject



@property BOOL sensorWarned;

+(id)data;
-(id)init;
-(void) startScan;
-(void) stopScan;
-(void)setViewController:(ViewController *)viewController;
-(void)scheduleCheckSensor;
-(void)checkSensor;

@end
