//
//  DayLog.h
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DayLog : NSManagedObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSMutableArray *rrs;
@property (nonatomic, retain) NSMutableArray *rr_times;
@property (nonatomic, retain) NSMutableArray *hrvs;
@property (nonatomic, retain) NSMutableArray *hrv_times;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+(NSDate *)getTodayDate;

@end