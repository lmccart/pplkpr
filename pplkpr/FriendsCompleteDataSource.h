//
//  FriendsCompleteDataSource.h
//  PPLKPR
//
//  Created by Lauren McCarthy on 8/26/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompleteTextFieldDataSource.h"

@interface FriendsCompleteDataSource : NSObject <MLPAutoCompleteTextFieldDataSource>


//Set this to true to return an array of autocomplete objects to the autocomplete textfield instead of strings.
//The objects returned respond to the MLPAutoCompletionObject protocol.
@property (assign) BOOL testWithAutoCompleteObjectsInsteadOfStrings;


//Set this to true to prevent auto complete terms from returning instantly.
@property (assign) BOOL simulateLatency;

- (void) updateFriends;

@end
