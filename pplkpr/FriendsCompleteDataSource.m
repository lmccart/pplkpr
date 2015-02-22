//
//  FriendsCompleteDataSource.m
//  PPLKPR
//
//  Created by Lauren McCarthy on 8/26/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "FriendsCompleteDataSource.h"
#import "FriendsCustomAutoCompleteObject.h"
#import "InteractionData.h"
#import "IOSHandler.h"

@interface FriendsCompleteDataSource()

@property (strong, nonatomic) NSArray *friendObjects;

@end


@implementation FriendsCompleteDataSource


- (void)updateFriends {
    
    NSMutableArray *mutableFriends = [NSMutableArray new];

    NSLog(@"updating friends");
    NSArray *result = [[IOSHandler data] getContacts];
    NSString *last;
    for (RHPerson* friend in result) {
        NSString *num = ([friend.phoneNumbers count] > 0) ? [friend.phoneNumbers valueAtIndex:0] : @"0";
        
        // take care of holdover
        if (last && ![friend.name isEqualToString:last]) {
            FriendsCustomAutoCompleteObject *friendObj = [[FriendsCustomAutoCompleteObject alloc] initWithName:last withNumber:@"0"];
            [mutableFriends addObject:friendObj];
            NSLog(@"%@ %@", last, @"0");
        }
        
        if ([num isEqualToString:@"0"]) {
            last = friend.name; // if no num, save in case duplicates
        } else {
            last = nil;
            if (friend.name && num) {
                FriendsCustomAutoCompleteObject *friendObj = [[FriendsCustomAutoCompleteObject alloc] initWithName:friend.name withNumber:num];
                [mutableFriends addObject:friendObj];
                NSLog(@"%@ %@", friend.name, num);
            }
        }
        
    }
    [self setFriendObjects: [NSArray arrayWithArray:mutableFriends]];
    
}

#pragma mark - MLPAutoCompleteTextField DataSource


//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        if(self.simulateLatency){
            CGFloat seconds = arc4random_uniform(4)+arc4random_uniform(4); //normal distribution
            sleep(seconds);
        }
        NSArray *completions;
        if ([string isEqualToString:@""]) {
            completions = [self getRecentFriendsComplete];
        } else {
            completions = _friendObjects;
        }
        handler(completions);
    });
}

- (NSMutableArray *)getRecentFriendsComplete {
    NSArray *recents = [[InteractionData data] getRecentPeople];
    
    NSMutableArray *mutableRecents = [NSMutableArray new];
    
    for (Person *p in recents) {
        FriendsCustomAutoCompleteObject *friendObj = [[FriendsCustomAutoCompleteObject alloc] initWithName:p.name withNumber:p.number];
        [mutableRecents addObject:friendObj];
    }
    return mutableRecents;
}


@end
