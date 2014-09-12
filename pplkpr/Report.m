//
//  Report.m
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "Report.h"
#import "Person.h"


@implementation Report

@dynamic emotion;
@dynamic rating;
@dynamic date;
@dynamic rangeStartDate;
@dynamic rangeEndDate;
@dynamic person;

- (NSString *)toString {
    return [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@", self.person.name, self.person.fbid, self.emotion, self.rating, self.rangeStartDate, self.rangeEndDate];
}
@end
