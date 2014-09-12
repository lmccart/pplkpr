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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    
    NSString *date = [dateFormatter stringFromDate:self.date];
    NSString *rsDate = [dateFormatter stringFromDate:self.rangeStartDate];
    NSString *reDate = [dateFormatter stringFromDate:self.rangeEndDate];
    
    return [NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\n", date, self.person.name, self.person.fbid, self.emotion, self.rating, rsDate, reDate];
}
@end
