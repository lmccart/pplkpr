//
//  DayLog.m
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "DayLog.h"

@implementation DayLog

@dynamic date;
@dynamic rrs;
@dynamic rr_times;
@dynamic hrvs;
@dynamic hrv_times;


+ (NSDate *)getTodayDate {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    return today;
}

@end
