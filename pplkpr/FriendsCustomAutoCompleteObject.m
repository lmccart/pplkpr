//
//  FriendsCustomAutoCompleteObject.m
//  MLPAutoCompleteDemo
//
//  Created by Lauren McCarthy on 8/29/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "FriendsCustomAutoCompleteObject.h"

@interface FriendsCustomAutoCompleteObject ()
@end

@implementation FriendsCustomAutoCompleteObject


- (id)initWithName:(NSString *)name withNumber:(NSString *)number {
    self = [super init];
    if (self) {
        [self setName:name];
        [self setNumber:number];
    }
    return self;
}

#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString {
    return self.name;
}

@end
