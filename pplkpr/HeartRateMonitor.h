//
//  HeartRateMonitor.h
//  HRM
//
//  Created by Lauren McCarthy on 7/15/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "ViewController.h"

@interface HeartRateMonitor : NSObject



-(void) startScan;
-(void) stopScan;

+(id)data;
-(id)init;
-(void)setViewController:(ViewController *)viewController;

@end
