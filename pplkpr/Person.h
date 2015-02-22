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

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *number;
@property (nonatomic, retain) NSDate *date;

// tracking FB actions
@property (nonatomic, retain) NSMutableDictionary *fbTickets; // ticket - action
@property (nonatomic, retain) NSMutableDictionary *fbActions; // emotion - actions arr

@property (nonatomic, retain) NSNumber *calm;
@property (nonatomic, retain) NSNumber *excited;
@property (nonatomic, retain) NSNumber *aroused;
@property (nonatomic, retain) NSNumber *angry;
@property (nonatomic, retain) NSNumber *scared;
@property (nonatomic, retain) NSNumber *anxious;
@property (nonatomic, retain) NSNumber *bored;

@property (nonatomic, retain) NSNumber *angryN;
@property (nonatomic, retain) NSNumber *anxiousN;
@property (nonatomic, retain) NSNumber *excitedN;
@property (nonatomic, retain) NSNumber *boredN;
@property (nonatomic, retain) NSNumber *calmN;
@property (nonatomic, retain) NSNumber *arousedN;
@property (nonatomic, retain) NSNumber *scaredN;
@property (nonatomic, retain) NSSet *reports;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addReportsObject:(Report *)value;
- (void)removeReportsObject:(Report *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;

- (void)updateRecentActions;

@end
