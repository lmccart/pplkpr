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

		_emotionsArray = [[NSArray alloc] initWithObjects:@"Excited",@"Aroused",@"Angry",@"Scared", @"Anxious", @"Bored", @"Calm", nil];
		_locationsArray = [[NSMutableArray alloc] init];
		_summary = [[NSDictionary alloc] init];
		
		_jumpToPerson = nil;
        
        
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
        
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
	NSArray *fetchedPeople = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
	return fetchedPeople;
}


- (NSArray*)getAllReports {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"JOHN"];
	[request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:_managedObjectContext]];
	[request setPredicate:predicate];
	NSError* error;
	NSArray *fetchedReports = [_managedObjectContext executeFetchRequest:request error:&error];
	return fetchedReports;
}


- (Person *)addReport:(NSString *)name withFbid:(NSString *)fbid withEmotion:(NSString *)emotion withRating:(NSNumber *)rating {
	
	NSLog(@"ADDING REPORT %@ %@ %@ %@", name, fbid, rating, emotion);
	
	// create new report
	Report * newReport = [NSEntityDescription insertNewObjectForEntityForName:@"Report"
													   inManagedObjectContext:_managedObjectContext];
    
    NSString *emotionKey = [emotion lowercaseString];
    [newReport setValue:emotion forKey:@"emotion"];
    [newReport setValue:rating forKey:@"rating"];
    [newReport setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
	
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbid == %@", fbid];
	[request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
	
    Person *person;
    
	if (result == nil) {
		NSLog(@"fetch result = nil");
        // Handle the error here
	} else {
		if([result count] > 0) {
			//NSLog(@"fetch saved person");
			person = (Person *)[result objectAtIndex:0];
			newReport.person = person;
            
            
            NSNumber *tot = [person valueForKey:[NSString stringWithFormat:@"%@N", emotion]];
            
			tot = [NSNumber numberWithInteger:[tot intValue] + 1];
			
            [person setValue:tot
                      forKey:[NSString stringWithFormat:@"%@N", emotionKey]];
			NSLog(@"reports n for %@ %@ %@ now at %@", person.name, person.fbid, newReport.emotion, tot);
		} else {
			NSLog(@"create new person");
			person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                              inManagedObjectContext:_managedObjectContext];
			[person setValue:name forKey:@"name"];
            [person setValue:fbid forKey:@"fbid"];
            [person setValue:[NSNumber numberWithInt:1]
                         forKey:[NSString stringWithFormat:@"%@N", emotionKey]];
			person.reports = [NSSet setWithObjects:newReport, nil];
            newReport.person = person;
		}
		
	}

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
            NSArray *mostEntry = [[NSArray alloc] initWithObjects: abs, [mostPerson valueForKey:@"name"], [NSNumber numberWithInt:0], e, nil];
            [results addObject:mostEntry];
            
            // add least person
            Person *leastPerson = [people_arr objectAtIndex:[people_arr count]-1];
            NSArray *leastEntry = [[NSArray alloc] initWithObjects: [leastPerson valueForKey:eKey], [leastPerson valueForKey:@"name"], [NSNumber numberWithInt:1], e, nil];
            [results addObject:leastEntry];
        }
    }
    
	return results;
}



- (void)purgeOldRecords {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:_managedObjectContext]];
	
	NSNumber *pastDate = [NSNumber numberWithDouble:[[NSDate dateWithTimeIntervalSinceNow:-5184000] timeIntervalSince1970]]; // Negative 60 days, in seconds (-60*60*24*60)
	NSString *predString = [NSString stringWithFormat:@"timestamp < %@", pastDate];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
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

