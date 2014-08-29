//
//  FriendsCustomAutoCompleteObject.h
//  MLPAutoCompleteDemo
//
//  Created by Lauren McCarthy on 8/29/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompletionObject.h"

@interface FriendsCustomAutoCompleteObject : NSObject <MLPAutoCompletionObject>

- (id)initWithName:(NSString *)name;

@end
