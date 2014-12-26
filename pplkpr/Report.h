//
//  Report.h
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSString * emotion;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * date; // dates referred to in report
@property (nonatomic, retain) Person * person;

- (NSString *)toString;

@end
