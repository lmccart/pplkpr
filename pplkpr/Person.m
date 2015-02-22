//
//  Person.m
//  pplkpr
//
//  Created by Lauren McCarthy on 12/18/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "Person.h"
#import "Report.h"


@implementation Person

@dynamic name;
@dynamic number;
@dynamic date;

@dynamic fbTickets;
@dynamic fbActions;

@dynamic calm;
@dynamic excited;
@dynamic aroused;
@dynamic angry;
@dynamic scared;
@dynamic anxious;
@dynamic bored;

@dynamic angryN;
@dynamic anxiousN;
@dynamic excitedN;
@dynamic boredN;
@dynamic calmN;
@dynamic arousedN;
@dynamic scaredN;
@dynamic reports;


- (void)updateRecentActions {
    // check all tickets
    // throw out any failed
    // add any succeeded as recent_actions
}

@end
