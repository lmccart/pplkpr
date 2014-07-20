//
//  HRViewController.h
//  HRM
//
//  Created by Tim Burks on 4/17/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

@interface HRViewController : NSObject


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(void) startScan;
-(void) stopScan;


+(id)data;
-(id)init;

@end
