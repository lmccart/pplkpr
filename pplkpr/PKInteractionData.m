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
	
	
	Report * newReport = [NSEntityDescription insertNewObjectForEntityForName:@"Report"
													   inManagedObjectContext:self.managedObjectContext];
	newReport.name = name;
	newReport.emotion = emotion;
	newReport.rating = rating;
	newReport.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
	
	
	Person * newPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
													   inManagedObjectContext:self.managedObjectContext];
	newPerson.name = name;
	newPerson.reports = [NSSet setWithObjects:newReport, nil];
	
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
}



- (void)dealloc {
	[_locationsArray release];
	[_emotionsArray release];
	[_summary release];
	[_jumpToName release];
	[super dealloc];
}

@end

