//
//  FriendsCompleteDataSource.m
//  PPLKPR
//
//  Created by Lauren McCarthy on 8/26/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "FriendsCompleteDataSource.h"
#import "FriendsCustomAutoCompleteObject.h"
#import "FBHandler.h"
#import "InteractionData.h"

@interface FriendsCompleteDataSource()

@property (strong, nonatomic) NSArray *friendObjects;

@end


@implementation FriendsCompleteDataSource


- (void)updateFriends {
    
    NSMutableArray *mutableFriends = [NSMutableArray new];

    [[FBHandler data] requestFriendsWithCompletion:^(NSArray *result) {
        for (NSDictionary<FBGraphUser>* friend in result) {
            FriendsCustomAutoCompleteObject *friendObj = [[FriendsCustomAutoCompleteObject alloc] initWithName:friend.name withFbid:friend.id];
            [mutableFriends addObject:friendObj];
        }
        [self setFriendObjects: [NSArray arrayWithArray:mutableFriends]];
    }];
    
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
        FriendsCustomAutoCompleteObject *friendObj = [[FriendsCustomAutoCompleteObject alloc] initWithName:p.name withFbid:p.fbid];
        [mutableRecents addObject:friendObj];
    }
    return mutableRecents;
}


@end
