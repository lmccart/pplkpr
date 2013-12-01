//
//  PKInteractionData.m
//  pplkpr
//
//  Created by Lauren McCarthy on 8/20/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKInteractionData.h"

@interface PKInteractionData()


@end

@implementation PKInteractionData

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
		_dataArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat: 0.2], [NSNumber numberWithFloat: 0.8], [NSNumber numberWithFloat: 0.6], nil];
		_summary = [[NSDictionary alloc] init];
		_jumpToName = nil;
    }
	
    return self;
}

- (void)dealloc {
	[_personName release];
	[_emotionsArray release];
	[_dataArray release];
	[_summary release];
	[_jumpToName release];
	[super dealloc];
}

@end

