//
//  PKInteractionData.m
//  pplkpr
//
//  Created by Lauren McCarthy on 8/20/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKInteractionData.h"
#import "Report.h"
#import "Person.h"
#import "PKAppDelegate.h"

@interface PKInteractionData()


@end

@implementation PKInteractionData


@synthesize managedObjectContext = _managedObjectContext;

+ (id)data {
    static PKInteractionData *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}


-(id)init {
	
    if (self = [super init]) {
		_emotionsArray = [[NSArray alloc] initWithObjects:@"Excited",@"Aroused",@"Angry",@"Scared", @"Anxious", @"Bored", @"Calm", nil];
		_locationsArray = [[NSMutableArray alloc] init];
		_summary = [[NSDictionary alloc] init];
		
		_jumpToName = nil;
    }
	
	PKAppDelegate* appDelegate = (PKAppDelegate*)[UIApplication sharedApplication].delegate;
	self.managedObjectContext = appDelegate.managedObjectContext;
	
    return self;
}



- (NSArray*)getRankedReports {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Report"
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError* error;
	NSArray *fetchedReports = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	return fetchedReports;
}

- (NSArray*)getAllPeople {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person"
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError* error;
	NSArray *fetchedPeople = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	return fetchedPeople;
}


- (NSArray*)getAllReports {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"JOHN"];
	[request setEntity:[NSEntityDescription entityForName:@"Report" inManagedObjectContext:self.managedObjectContext]];
	[request setPredicate:predicate];
	NSError* error;
	NSArray *fetchedReports = [self.managedObjectContext executeFetchRequest:request error:&error];
	return fetchedReports;
}


- (void)addReport:(NSString *)name withEmotion:(NSString *)emotion withRating:(NSNumber *)rating {
	
	NSLog(@"ADDING REPORT %@ %@ %@", name, rating, emotion);
	
	// create new report
	Report * newReport = [NSEntityDescription insertNewObjectForEntityForName:@"Report"
													   inManagedObjectContext:self.managedObjectContext];
	newReport.name = name;
	newReport.emotion = emotion;
	newReport.rating = rating;
	newReport.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
	
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
	[request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext]];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	if (result == nil) {
		NSLog(@"fetch result = nil");
        // Handle the error here
	} else {
		if([result count] > 0) {
			NSLog(@"fetch saved person");
			Person *person = (Person *)[result objectAtIndex:0];
			newReport.person = person;

		} else {
			NSLog(@"create new person");
			Person * newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
															   inManagedObjectContext:self.managedObjectContext];
			newPerson.name = name;
			for (id e in _emotionsArray) {
				SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:", e]);
				[newPerson performSelector:sel withObject:[NSNumber numberWithFloat:0]];
			}
			newPerson.reports = [NSSet setWithObjects:newReport, nil];
		}
		
	}

	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
}


// calc average reports for each category for one person
- (void)averagePerson:(Person *)person {
	
	// init dicts
	NSMutableDictionary *valsDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *totalsDict = [[NSMutableDictionary alloc] init];
	for (id e in _emotionsArray) {
		[valsDict setObject:[NSNumber numberWithFloat:0] forKey:e];
		[totalsDict setObject:[NSNumber numberWithFloat:0] forKey:e];
	}
	
	// add up vals and tots
	for (Report *r in person.reports) {
		NSNumber *val = [valsDict objectForKey:r.emotion];
		val = [NSNumber numberWithFloat:[val floatValue] + [r.rating floatValue]];
		[valsDict setObject:val forKey:r.emotion];
		
		NSNumber *tot = [totalsDict objectForKey:r.emotion];
		tot = [NSNumber numberWithInteger:[tot intValue] + 1];
		[totalsDict setObject:tot forKey:r.emotion];
	}
	
	// divide
	NSLog(@"averaging %@", person.name);
	for (id e in _emotionsArray) {
		NSNumber *val = [valsDict objectForKey:e];
		NSNumber *tot = [totalsDict objectForKey:e];
		if ([tot intValue] > 0) {
			SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:", e]);
			[person performSelector:sel withObject:[NSNumber numberWithFloat:[val floatValue]/[tot floatValue]]];
			NSLog(@"%@ %@", e, [NSNumber numberWithFloat:[val floatValue]/[tot floatValue]]);
		}
	}
	// save context
	NSError* error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
}

// calc average category values across all people
- (void)calculateGlobalAverages {
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person"
											  inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	NSError* error;
	NSArray *people = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	for (Person *p in people) {
		[self averagePerson:p];
	}
}

// determine "true val" of category by mixing their avg vals
// with global avgs. more reports make the mix biased toward
// their own avg.
- (void)revaluePerson {
	
}



- (void)dealloc {
	[_locationsArray release];
	[_emotionsArray release];
	[_summary release];
	[_jumpToName release];
	[super dealloc];
}

@end

