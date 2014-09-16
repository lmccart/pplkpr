//
//  DayLog.m
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "DayLog.h"


@implementation DayLog

- (id)init {
    self = [super init];
    if (self) {
        self.date = [NSDate date];
        self.rrs = [[NSMutableArray alloc] init];
        self.rr_times = [[NSMutableArray alloc] init];
        self.hrvs = [[NSMutableArray alloc] init];
        self.hrv_times = [[NSMutableArray alloc] init];
    }
    return self;
}


@end
