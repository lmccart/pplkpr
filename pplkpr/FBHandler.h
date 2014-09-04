//
//  FBHandler.h
//  pplkpr
//
//  Created by Lauren McCarthy on 9/3/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Person.h"

@interface FBHandler : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


+(id)data;
-(id)init;

- (void)requestFriendsWithCompletion:(void (^)(NSArray *result))completionBlock;

- (void)requestProfile:(Person *)person withCompletion:(void (^)(NSDictionary *result))completionBlock;

- (void)requestPoke:(Person *)person;
- (void)requestPost:(Person *)person withMessage:(NSString *)message;

@end


