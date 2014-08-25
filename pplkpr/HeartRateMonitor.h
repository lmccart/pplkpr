//
//  HeartRateMonitor.h
//  HRM
//
//  Created by Lauren McCarthy on 7/15/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

@interface HeartRateMonitor : NSObject


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(void) startScan;
-(void) stopScan;


+(id)data;
-(id)init;

@end
