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


-(id)initWithName:(NSString *)aPersonName {
	
	self = [super init];
	
    if (self) {
        _personName = aPersonName;
		_emotionsArray = [[NSArray alloc] initWithObjects:@"Excited",@"Aroused",@"Angry",@"Scared", @"Anxious", @"Bored", @"Calm", nil];
    }
	
    return self;
}

- (void)dealloc {
	[_personName release];
	[super dealloc];
}

@end

