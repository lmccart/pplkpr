//
//  InteractionData.m
//  pplkpr
//
//  Created by Lauren McCarthy on 8/20/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "InteractionData.h"
#import "Report.h"
#import "Person.h"
#import "AppDelegate.h"
#import "FBHandler.h"

@interface InteractionData()

@end

@implementation InteractionData

+ (id)data {
    static InteractionData *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}


- (id)init {
	
    if (self = [super init]) {

		self.emotionsArray = [[NSArray alloc] initWithObjects:@"Excited",@"Aroused",@"Angry",@"Scared", @"Anxious", @"Bored", @"Calm", nil];
		self.locationsArray = [[NSMutableArray alloc] init];
		self.summary = [[NSDictionary alloc] init];
		
		self.jumpToPerson = nil;
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        [self purgeOldRecords];
        
    }
	
    return self;
}



- (NSArray*)getRankedReports {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Report"
											  inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError* error;
	NSArray *fetchedReports = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
	return fetchedReports;
}

- (NSArray*)getAllPeople {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person"
											  inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError* error;
	NSArray *fetchedPeople = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	return fetchedPeople;
}


- (NSArray*)getAllReports {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"JOHN"];
	[request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:_managedObjectContext]];
	[request setPredicate:predicate];
	NSError* error;
	NSArray *fetchedReports = [self.managedObjectContext executeFetchRequest:request error:&error];
	return fetchedReports;
}

- (Report *)getLatestReport {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:_managedObjectContext]];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:1];
    NSError* error;
    NSArray *fetchedReports = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (fetchedReports && [fetchedReports count] > 0) {
        return fetchedReports[0];
    } else return nil;
}

- (NSTimeInterval)getTimeSinceLastReport {
    Report *r = [self getLatestReport];
    if (r) {
        return [[NSDate date] timeIntervalSinceDate:r.date];
    } else {
        return 0;
    }
}

// returns existing person or makes new one
- (Person *)getPerson:(NSString *)name withFbid:(NSString *)fbid save:(BOOL)save {
    NSLog(@"GETTING PERSON %@", fbid);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbid == %@", fbid];
    [request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
    
    Person *person;
    
    
    if (result == nil) {
        NSLog(@"fetch result = nil");
    } else {
        if([result count] > 0) {
            person = (Person *)[result objectAtIndex:0];
        } else {
            
            person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                   inManagedObjectContext:_managedObjectContext];
            [person setName:name];
            [person setFbid:fbid];
            [person setDate:[NSDate date]]; // update for recency
            
            NSMutableDictionary *tickets_arr = [[NSMutableDictionary alloc] init];
            [person setFbTickets:tickets_arr];
            
            NSMutableArray *actions_arr = [[NSMutableArray alloc] init];
            [person setFbCompletedActions:actions_arr];
            
            if (save) {
                NSError *error;
                if (![_managedObjectContext save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
            }
        }
    }
    
    return person;
}

- (Person *)addReport:(NSString *)name
             withFbid:(NSString *)fbid
          withEmotion:(NSString *)emotion
           withRating:(NSNumber *)rating
   withRangeStartDate:(NSDate *)rangeStartDate
     withRangeEndDate:(NSDate *)rangeEndDate; {
	
	NSLog(@"ADDING REPORT %@ %@ %@ %@ %@ %@", name, fbid, rating, emotion, rangeStartDate, rangeEndDate);
	
	// create new report
	Report *newReport = [NSEntityDescription insertNewObjectForEntityForName:@"Report"
													   inManagedObjectContext:_managedObjectContext];
    
    NSString *emotionKey = [emotion lowercaseString];
    [newReport setEmotion:emotion];
    [newReport setRating:rating];
    [newReport setDate:[NSDate date]];
    [newReport setRangeStartDate:rangeStartDate];
    [newReport setRangeEndDate:rangeEndDate];
    
    // add report to person
    Person *person = [self getPerson:name withFbid:fbid save:false];
    newReport.person = person;
    
    // update totals
    NSNumber *tot = [person valueForKey:[NSString stringWithFormat:@"%@N", emotion]];
    tot = [NSNumber numberWithInteger:[tot intValue] + 1];
	[person setValue:tot
              forKey:[NSString stringWithFormat:@"%@N", emotionKey]];
    NSLog(@"reports n for %@ %@ %@ now at %@", person.name, person.fbid, newReport.emotion, tot);
    [person setDate:[NSDate date]]; // update for recency


    NSError *error;
	if (![_managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
    
    return person;
}


// calc average reports for each category for one person
- (void)averagePerson:(Person *)person {
	
	// init dicts
	NSMutableDictionary *valsDict = [[NSMutableDictionary alloc] init];
	for (id e in _emotionsArray) {
		[valsDict setObject:[NSNumber numberWithFloat:0] forKey:e];
	}
	
	// add up vals and tots
	for (Report *r in person.reports) {
		NSNumber *val = [valsDict objectForKey:r.emotion];
		val = [NSNumber numberWithFloat:[val floatValue] + [r.rating floatValue]];
		[valsDict setObject:val forKey:r.emotion];
	}
	
	// divide
	//NSLog(@"averaging %@", person.name);
	for (id e in _emotionsArray) {
		NSNumber *val = [valsDict objectForKey:e];
  
        NSNumber *tot = [person valueForKey:[NSString stringWithFormat:@"%@N", [e lowercaseString]]];
        
		if ([tot intValue] > 0) {
            
            [person setValue:[NSNumber numberWithFloat:[val floatValue]/[tot floatValue]]
                      forKey:[e lowercaseString]];
		}
	}
	// save context
	NSError* error;
	if (![_managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
}

// calc average category values across all people
- (void)calculateGlobalAverages {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person"
											  inManagedObjectContext:_managedObjectContext];
	[request setEntity:entity];
	NSError* error;
	NSArray *people = [_managedObjectContext executeFetchRequest:request error:&error];
	
	// init dicts
	NSMutableDictionary *valsDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *totalsDict = [[NSMutableDictionary alloc] init];
	for (id e in _emotionsArray) {
		[valsDict setObject:[NSNumber numberWithFloat:0] forKey:e];
		[totalsDict setObject:[NSNumber numberWithFloat:0] forKey:e];
	}
	
	// add up ppl vals
	for (Person *p in people) {
		[self averagePerson:p];
		for (id e in _emotionsArray) {
            NSNumber *pVal = [p valueForKey:[e lowercaseString]];
            
			if ([pVal floatValue] > 0) {
				NSNumber *val = [valsDict objectForKey:e];
				val = [NSNumber numberWithFloat:[val floatValue] + [pVal floatValue]];
				[valsDict setObject:val forKey:e];
				
				NSNumber *tot = [totalsDict objectForKey:e];
				tot = [NSNumber numberWithInteger:[tot intValue] + 1];
				[totalsDict setObject:tot forKey:e];
			}
		}
	}
	
	// obtain global avgs
	for (id e in _emotionsArray) {
		NSNumber *val = [valsDict objectForKey:e];
		NSNumber *tot = [totalsDict objectForKey:e];
		if ([tot intValue] > 0) {
			val = [NSNumber numberWithFloat:[val floatValue] / [tot floatValue]];
			[valsDict setObject:val forKey:e];
			//NSLog(@"global avg %@ %@", e, val);
		}
	}
	
	// revalue people
	for (Person *p in people) {
		[self revaluePerson:p withGlobalVals:valsDict];
	}
}

// determine "true val" of category by mixing person avg vals
// with global avgs. more reports make the mix biased toward
// person's own avg.
- (void)revaluePerson:(Person *)person withGlobalVals:(NSMutableDictionary *)globalVals {
	for (id e in _emotionsArray) {
        NSNumber *pVal = [person valueForKey:[e lowercaseString]];
        
		NSNumber *globalVal = [globalVals valueForKey:e];
		
		if ([pVal floatValue] > 0) {
            NSNumber *tot = [person valueForKey:[NSString stringWithFormat:@"%@N", [e lowercaseString]]];
            
			float factor = 1.0; // determines how much the weight shifts with new reports
			
			NSNumber *avgVal = [NSNumber numberWithFloat:([pVal floatValue] * [tot floatValue] * factor + [globalVal floatValue]) / ([tot floatValue] * factor + 1 ) ];
			
			
			// for now just 50/50 avg with global
            [person setValue:avgVal forKey:[e lowercaseString]];
			//NSLog(@"revalued avg %@ %@", e, avgVal);
		}
	}
}

// returns dictionary {emotion:array of people} sorted most to least
- (NSMutableDictionary *)getdRankedPeople {
	
	[self calculateGlobalAverages];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	for (id e in _emotionsArray) {
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
		
		NSString *predString = [NSString stringWithFormat:@"%@N > %@", [e lowercaseString], [NSNumber numberWithInteger:0]];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
		[request setPredicate:predicate];
		
		NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:[NSString stringWithFormat:@"%@", [e lowercaseString]] ascending:NO]; // default to most first
		[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
		
		NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
        if ([results count] > 0) {
            [dict setObject:results forKey:e];
        }
	}
	return dict;
}

- (NSArray *)getRecentPeople {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]; // default to newest first
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
    
    return results;
}




- (NSMutableArray *)getPriorities {
	
    NSMutableDictionary *ranked = [self getRankedPeople];
	NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (int i=0; i < [[ranked allKeys] count]; i++) {
        
        NSString *e = [[ranked allKeys] objectAtIndex:i];
        NSString *eKey = [e lowercaseString];
        NSArray *people_arr = (NSArray *)[ranked objectForKey:e];
        
        if ([people_arr count] > 0) {
            // add most person
            Person *mostPerson = [people_arr objectAtIndex:0];
            NSNumber *abs = [NSNumber numberWithFloat:1- [[mostPerson valueForKey:eKey] floatValue]];
            NSArray *mostEntry = [[NSArray alloc] initWithObjects: abs, mostPerson, [NSNumber numberWithInt:0], e, nil];
            [results addObject:mostEntry];
            
            // add least person
            Person *leastPerson = [people_arr objectAtIndex:[people_arr count]-1];
            NSArray *leastEntry = [[NSArray alloc] initWithObjects: [leastPerson valueForKey:eKey], leastPerson, [NSNumber numberWithInt:1], e, nil];
            [results addObject:leastEntry];
        }
    }
    
	return results;
}

- (NSArray *)getSortedPriorities {
    NSArray *sortedArray = [[self getPriorities] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectAtIndex:0] floatValue] > [[obj2 objectAtIndex:0] floatValue])
            return NSOrderedDescending;
        else if ([[obj1 objectAtIndex:0] floatValue] < [[obj2 objectAtIndex:0] floatValue])
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
//    NSLog(@"sorted priorities");
//    for (id k in sortedArray) {
//        NSLog(@"%@", [[k objectAtIndex:1] name]);
//    }
    return sortedArray;
}

- (void)takeAction {
    NSArray *priorities = [self getSortedPriorities];
    if ([priorities count] > 0) {
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *lastPeople = [defaults objectForKey:@"lastPeople"];
        NSMutableArray *mutableLastPeople;
        if (!lastPeople) {
            mutableLastPeople = [[NSMutableArray alloc] init];
        } else {
            mutableLastPeople = [lastPeople mutableCopy];
        }
        //NSLog(@"%@", lastPeople);
        
        NSString *name = @"";
        NSString *emotion = @"";
        int order = -1;
        Person *person;
        NSArray *entry;
        int i=0;
        while (order != 0 || [lastPeople containsObject:name]) {
            entry = [priorities objectAtIndex:i];
            person = [entry objectAtIndex:1];
            name = person.name;
            order = [[entry objectAtIndex:2] integerValue];
            emotion = [entry objectAtIndex:3];
            i++;
            if (i >= [priorities count]) break;
        }
        
        if ([mutableLastPeople count] == 2) {
            [mutableLastPeople removeObjectAtIndex:0];
        }
        
        if (entry && order == 0) {
            //NSLog(@"%@ %@ %d", name, emotion, order);
            [self actOn:person forEmotion:emotion];
            [mutableLastPeople addObject:name];
        }
        
        //NSLog(@"%@", mutableLastPeople);
        [defaults setObject:[mutableLastPeople copy] forKey:@"lastPeople"];
        [defaults synchronize];
    }
}

- (void)actOn:(Person *)person forEmotion:(NSString *)emotion {
    
    NSLog(@"acting on %@ for %@", person.name, emotion);
    
    if (!person.fbActions) {
        [person setFbActions:[[NSMutableDictionary alloc] init]];
        for (id e in self.emotionsArray) {
            [person.fbActions setObject:[[NSMutableArray alloc] init] forKey:e];
        }
    }
    // logic for different consequences here
    NSString* a;
    NSMutableArray *actions_arr = [person.fbActions valueForKey:emotion];
    
    if ([emotion isEqualToString:@"Excited"]) {
        [[FBHandler data] requestPost:person withMessage:@"oooh you excite me!"]; // pend
        a = @"post";
    } else if ([emotion isEqualToString:@"Aroused"]) {
        if (![actions_arr containsObject:@"poke"]) {
            [[FBHandler data] requestPoke:person];
            a = @"poke";
        } else {
            [[FBHandler data] requestInviteToEvent:person];
            a = @"invite";
            [actions_arr removeObject:@"poke"];
        }
    } else if ([emotion isEqualToString:@"Calm"]) {
        [[FBHandler data] requestInviteToEvent:person];
        a = @"invite";
    } else if ([emotion isEqualToString:@"Angry"]) {
        if (![actions_arr containsObject:@"post"]) {
            [[FBHandler data] requestPost:person withMessage:@"you make me seethe with anger"]; // pend
            a = @"post";
        } else if (![actions_arr containsObject:@"block"]) {
            [[FBHandler data] requestBlock:person];
            a = @"block";
        } else if (![actions_arr containsObject:@"unfriend"]) {
            [[FBHandler data] requestUnfriend:person];
            a = @"unfriend";
        }
    } else if ([emotion isEqualToString:@"Scared"]) {
        if (![actions_arr containsObject:@"post"]) {
            [[FBHandler data] requestPost:person withMessage:@"you scare me, please stay away!"]; // pend
            a = @"post";
        } else if (![actions_arr containsObject:@"block"]) {
            [[FBHandler data] requestBlock:person];
            a = @"block";
        }
    } else if ([emotion isEqualToString:@"Anxious"]) {
        if (![actions_arr containsObject:@"post"]) {
            [[FBHandler data] requestPost:person withMessage:@"you make me feel anxious"]; // pend
            a = @"post";
        } else if (![actions_arr containsObject:@"block"]) {
            [[FBHandler data] requestBlock:person];
            a = @"block";
        }
    } else if ([emotion isEqualToString:@"Bored"]) {
        // do nothing
    }
    
    if (a) [actions_arr addObject:a];
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Error deleting - error:%@",error);
    }
}

// returns dictionary {emotion:array of people} sorted most to least
- (NSMutableDictionary *)getRankedPeople {
    [self calculateGlobalAverages];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (id e in _emotionsArray) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
        
        NSString *predString = [NSString stringWithFormat:@"%@N > %@", [e lowercaseString], [NSNumber numberWithInteger:0]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
        [request setPredicate:predicate];
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:[NSString stringWithFormat:@"%@", [e lowercaseString]] ascending:NO]; // default to most first
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
        if ([results count] > 0) {
            [dict setObject:results forKey:e];
        }
    }
    return dict;
}

- (void)purgeOldRecords {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:_managedObjectContext]];
	
	NSDate *pastDate = [NSDate dateWithTimeIntervalSinceNow:-5184000]; // Negative 60 days, in seconds (-60*60*24*60)
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date < %@", pastDate];
	[request setPredicate:predicate];
	
	NSError *error;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];

    for (NSManagedObject *managedObject in results) {
    	[_managedObjectContext deleteObject:managedObject];
    	//NSLog(@"report deleted");
    }
    if (![_managedObjectContext save:&error]) {
    	NSLog(@"Error deleting - error:%@",error);
    }
}

@end

