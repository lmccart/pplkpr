//
//  Report.h
//  pplkpr
//
//  Created by Lauren McCarthy on 12/17/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Report : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * emotion;

@end
