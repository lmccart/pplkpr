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
#import "IOSHandler.h"

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
        
        //@property (nonatomic, strong) NSDictionary *possibleActionsDict; // emotion -> array [order of actions]
        //@property (nonatomic, strong) NSDictionary *descriptiveActionsDict; // action -> array [command, past]
        //@property (nonatomic, strong) NSDictionary *messageDict; // emotion -> array [possible msgs for given emotion]

        NSArray *excitedActions = [[NSArray alloc] initWithObjects:@"post", @"join_event", nil];
        NSArray *arousedActions = [[NSArray alloc] initWithObjects:@"poke", @"join_event", nil];
        NSArray *angryActions = [[NSArray alloc] initWithObjects:@"post", @"block", @"unfriend", nil];
        NSArray *scaredActions = [[NSArray alloc] initWithObjects:@"post", @"block", @"unfriend", nil];
        NSArray *anxiousActions = [[NSArray alloc] initWithObjects:@"post", @"block", nil];
        NSArray *boredActions = [[NSArray alloc] initWithObjects:@"block", nil];
        NSArray *calmActions = [[NSArray alloc] initWithObjects:@"join_event", nil];
        self.possibleActionsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    excitedActions, @"Excited",
                                    arousedActions, @"Aroused",
                                    angryActions, @"Angry",
                                    scaredActions, @"Scared",
                                    anxiousActions, @"Anxious",
                                    boredActions, @"Bored",
                                    calmActions, @"Calm", nil];
        
        NSArray *excitedMsgs = [[NSArray alloc] initWithObjects:@"you excite me", @"wooo!", @"so psyched!", @"i'm beyond excited", @"i'm so excited!", @"you got me all excited", @"wooo yeahh!!", @"weeeeeee!", @"soo excited by yooou", nil];
        NSArray *arousedMsgs = [[NSArray alloc] initWithObjects:@"hey babe", @"how are you doing?", @"what's up hottie", @"you got me going...", @"ooh la la", @"heart", @"oh hiii", nil];
        NSArray *angryMsgs = [[NSArray alloc] initWithObjects:@"sometimes you make me really mad", @"what's your issue?", @" you're really bugging me.", @"i'm angry...", @"what's your problem?", @"you're pissing me off", @"just leave me alone", nil];
        NSArray *scaredMsgs = [[NSArray alloc] initWithObjects:@"you scare me sometimes", @"you're kind of scaring me...", @"i'm a bit frightened...", @"i feel scared around you", @"you terrify me", nil];
        NSArray *anxiousMsgs = [[NSArray alloc] initWithObjects:@"i feel so anxious around you", @"you make me feel really nervous", @"you stress me out", @"being around you makes my blood pressure rise", @"you're disrupting my chilll", nil];
        NSArray *boredMsgs = [[NSArray alloc] initWithObjects:@"you're sooo boring!", @"so bored.", @"sometimes you leave me completely uninterested.", @"bleh whatever", nil];
        NSArray *calmMsgs = [[NSArray alloc] initWithObjects:@"ahhh so peaceful", @"so calm right now", @"mm i feel so relaxed", @"you really relax me", @"you're so chill", @"ommmmmmm", nil];
        self.messageDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    excitedMsgs, @"Excited",
                                    arousedMsgs, @"Aroused",
                                    angryMsgs, @"Angry",
                                    scaredMsgs, @"Scared",
                                    anxiousMsgs, @"Anxious",
                                    boredMsgs, @"Bored",
                                    calmMsgs, @"Calm", nil];
        
        if ([[FBHandler data] useFakebook]) {
        
            self.descriptiveActionsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
               [[NSArray alloc] initWithObjects:@"Let them know?", @"I let them know.", nil], @"post",
               [[NSArray alloc] initWithObjects:@"Poke them?", @"I poked them.", nil], @"poke",
               [[NSArray alloc] initWithObjects:@"Invite them to hang out?", @"I invited them to hang out.", nil], @"join_event",
               [[NSArray alloc] initWithObjects:@"Unblock them?", @"I unblocked them.", nil], @"unblock",
               [[NSArray alloc] initWithObjects:@"Block them?", @"I blocked them.", nil], @"block",
               [[NSArray alloc] initWithObjects:@"Unfriend them?", @"I unfriended them.", nil], @"unfriend",
               [[NSArray alloc] initWithObjects:@"Friend them?", @"I friended them.", nil], @"friend", nil];

        } else {
            
            self.descriptiveActionsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
               [[NSArray alloc] initWithObjects:@"Poke them?", @"I poked them.", nil], @"post",
               [[NSArray alloc] initWithObjects:@"Let them know?", @"I let them know.", nil], @"poke",
               [[NSArray alloc] initWithObjects:@"Invite them to hang out?", @"I invited them to hang out.", nil], @"join_event",
               [[NSArray alloc] initWithObjects:@"Unblock them?", @"I unblocked them.", nil], @"unblock",
               [[NSArray alloc] initWithObjects:@"Delete their number?", @"I deleted their number.", nil], @"block",
               [[NSArray alloc] initWithObjects:@"Delete their number?", @"I deleted their number.", nil], @"unfriend",
               [[NSArray alloc] initWithObjects:@"Friend them?", @"I friended them.", nil], @"friend", nil];
        }
        
		self.locationsArray = [[NSMutableArray alloc] init];
		self.summary = [[NSDictionary alloc] init];
		
		self.jumpToPerson = nil;
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        //[self purgeOldRecords];
        
    }
	
    return self;
}


- (NSString *)getFutureAction:(NSString *)emotion forIndex:(int)ind {
    return [[self.possibleActionsDict objectForKey:emotion] objectAtIndex:ind];
}

- (NSString *)getFutureDescriptiveAction:(NSString *)emotion {
    NSString *action = [self getFutureAction:emotion forIndex:0];
    return [[self.descriptiveActionsDict objectForKey:action] objectAtIndex:0];
}

- (NSString *)getPastDescriptiveAction:(NSString *)action {
    return [[self.descriptiveActionsDict objectForKey:action] objectAtIndex:1];
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


// returns existing person or makes new one
- (Person *)getPerson:(NSString *)name withFbid:(NSString *)fbid save:(BOOL)save {
    //NSLog(@"GETTING PERSON %@", fbid);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbid == %@", fbid];
    [request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
    
    Person *person;
    
    
    if (result == nil) {
        //NSLog(@"fetch result = nil");
    } else {
        if([result count] > 0) {
            person = (Person *)[result objectAtIndex:0];
        } else {
            
            person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                   inManagedObjectContext:_managedObjectContext];
            [person setName:name];
            [person setFbid:fbid];
            [person setDate:[NSDate date]]; // update for recency
            
            NSMutableDictionary *tickets_dict = [[NSMutableDictionary alloc] init];
            [person setFbTickets:tickets_dict];
            
            if (save) {
                NSError *error;
                if (![_managedObjectContext save:&error]) {
                    //NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
            }
        }
    }
    
    return person;
}

- (Report *)addReport:(NSString *)name
             withFbid:(NSString *)fbid
          withEmotion:(NSString *)emotion
           withRating:(NSNumber *)rating
             withDate:(NSDate *)date; {
	
	//NSLog(@"ADDING REPORT %@ %@ %@ %@ %@", name, fbid, rating, emotion, date);
	
	// create new report
	Report *newReport = [NSEntityDescription insertNewObjectForEntityForName:@"Report"
													   inManagedObjectContext:_managedObjectContext];
    
    NSString *emotionKey = [emotion lowercaseString];
    [newReport setEmotion:emotion];
    [newReport setRating:rating];
    [newReport setDate:date];
    
    // add report to person
    Person *person = [self getPerson:name withFbid:fbid save:false];
    newReport.person = person;
    
    // update totals
    NSNumber *tot = [person valueForKey:[NSString stringWithFormat:@"%@N", emotion]];
    tot = [NSNumber numberWithInteger:[tot intValue] + 1];
	[person setValue:tot
              forKey:[NSString stringWithFormat:@"%@N", emotionKey]];
    //NSLog(@"reports n for %@ %@ %@ now at %@", person.name, person.fbid, newReport.emotion, tot);
    [person setDate:[NSDate date]]; // update for recency


    NSError *error;
	if (![_managedObjectContext save:&error]) {
		//NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
    
    return newReport;
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
		//NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
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
            Person *leastPerson = [people_arr lastObject];
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

- (void)saveLastReportDate:(NSDate *)date {
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:@"lastReportDate"];
    [defaults synchronize];
}

- (NSTimeInterval)getTimeSinceLastReport {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [defaults objectForKey:@"lastReportDate"];
    
    if (lastDate) {
        return [[NSDate date] timeIntervalSinceDate:lastDate];
    } else {
        return 0;
    }
}


+ (NSDate *)getTodayDate {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    return today;
}

- (void)checkTakeAction {
    if ([[FBHandler data] useFakebook]) {
        [self checkTickets];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [defaults objectForKey:@"lastActionDate"];
    NSDate *date = [NSDate date];
    
    if (true) {
    //if (!lastDate || [date timeIntervalSinceDate:lastDate] > 2*60*60) { // every 2 hours
        [defaults setObject:date forKey:@"lastActionDate"];
        [defaults synchronize];
        [self takeAction];
    }
}

- (void)takeAction {
    NSLog(@"take action");
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
        while (order != 0){// || [lastPeople containsObject:name]) {
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
    
    //NSLog(@"acting on %@ for %@", person.name, emotion);
    
    if (!person.fbActions) {
        [person setFbActions:[[NSMutableDictionary alloc] init]];
        for (id e in self.emotionsArray) {
            [person.fbActions setObject:[[NSMutableArray alloc] init] forKey:e];
        }
    }
    // logic for different consequences here
    NSMutableArray *actions_arr = [person.fbActions valueForKey:emotion];
    NSArray *possible_actions_arr = [self.possibleActionsDict objectForKey:emotion];
    NSString *last_act = [actions_arr lastObject];
    int ind = 0;
    if (last_act) {
        ind = ([possible_actions_arr indexOfObject:last_act] + 1) % [possible_actions_arr count];
        //NSLog(@"last act %@ ind %d i %d count %d", last_act, ind, [possible_actions_arr indexOfObject:last_act], [possible_actions_arr count]);
    }

    NSString *action = [possible_actions_arr objectAtIndex:ind];
    
    NSString *msg = [self getMessage:emotion];
    
    if ([[FBHandler data] useFakebook]) {
        [[FBHandler data] createFakebookRequest:person withType:action withMessage:msg withEmotion:emotion];
    } else {
        [[IOSHandler data] performAction:person withType:action withMessage:msg withEmotion:emotion];
    }
    
    // log action
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *actionData = [NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\n", date, person.name, person.fbid, emotion, action, msg];
    [[FBHandler data] logData:actionData withTag:@"action" withCompletion:nil];
}

- (NSString *)getMessage:(NSString *)emotion {
    
    NSArray *possible_messages_arr = [self.messageDict objectForKey:emotion];
    NSUInteger randomInd = arc4random() % [possible_messages_arr count];
    NSString *msg = [possible_messages_arr objectAtIndex:randomInd];
    //NSLog(@"arr %@ ind %d msg %@", possible_messages_arr, randomInd, msg);
    return msg;
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

- (void)checkTickets {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
    
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
    for (Person *p in results) {
        if (!p.fbActions) {
            [p setFbActions:[[NSMutableDictionary alloc] init]];
            for (id e in self.emotionsArray) {
                [p.fbActions setObject:[[NSMutableArray alloc] init] forKey:e];
            }
        }
        for (NSString *tick in p.fbTickets) {
            NSArray *arr = [tick componentsSeparatedByString:@":"];
            NSString *tick_id = arr[0];
            NSString *emotion = arr[1];
            [[FBHandler data] checkTicket:tick_id withCompletion:^(int status) {
                NSString *action = [p.fbTickets objectForKey:tick];
                if (status == 1) {
                    //NSLog(@"ticket successful %@ %@", tick, action);
                    [p.fbTickets removeObjectForKey:tick];
                    if (action) {
                        NSMutableArray *emo_actions = [p.fbActions valueForKey:emotion];
                        [emo_actions addObject:action];
                        //NSLog(@"tickets %@", p.fbTickets);
                        //NSLog(@"actions %@", p.fbActions);
                    }
                } else if (status == 0) {
                    //NSLog(@"ticket processing %@", tick);
                } else if (status == -1) {
                    //NSLog(@"ticket failed %@", tick);
                    [p.fbTickets removeObjectForKey:tick];
                }
            }];
            
        }
    }
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        //NSLog(@"Error deleting - error:%@",error);
    }
}

//- (void)purgeOldRecords {
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:_managedObjectContext]];
//    
//    NSDate *pastDate = [NSDate dateWithTimeIntervalSinceNow:-5184000]; // Negative 60 days, in seconds (-60*60*24*60)
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date < %@", pastDate];
//    [request setPredicate:predicate];
//    
//    NSError *error;
//    NSArray *results = [_managedObjectContext executeFetchRequest:request error:nil];
//
//    for (NSManagedObject *managedObject in results) {
//        [_managedObjectContext deleteObject:managedObject];
//        //NSLog(@"report deleted");
//    }
//    if (![_managedObjectContext save:&error]) {
//        NSLog(@"Error deleting - error:%@",error);
//    }
//}

@end

