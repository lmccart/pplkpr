//
//  Person.h
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Report;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * calm;
@property (nonatomic, retain) NSNumber * excited;
@property (nonatomic, retain) NSNumber * aroused;
@property (nonatomic, retain) NSNumber * angry;
@property (nonatomic, retain) NSNumber * scared;
@property (nonatomic, retain) NSNumber * anxious;
@property (nonatomic, retain) NSNumber * bored;
@property (nonatomic, retain) NSSet *reports;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addReportsObject:(Report *)value;
- (void)removeReportsObject:(Report *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;

@end
