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

@interface FBHandler : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *pass;


+(id)data;
-(id)init;

- (void)requestFriendsWithCompletion:(void (^)(NSArray *result))completionBlock;
- (void)requestProfile:(NSString *)fbid withCompletion:(void (^)(NSDictionary *results))completionBlock;


- (void)requestLogin:(NSString *)email withPass:(NSString *)pass withCompletion:(void (^)(NSDictionary *results))completionBlock;
- (void)requestPoke:(Person *)person;
- (void)requestPost:(Person *)person withMessage:(NSString *)message;
- (void)requestBlock:(Person *)person;
- (void)requestUnblock:(Person *)person;
- (void)requestFriend:(Person *)person;
- (void)requestUnfriend:(Person *)person;
- (void)requestInviteToEvent:(Person *)person;

- (void)checkTicket:(NSString *)ticket  withCompletion:(void (^)(int status))completionBlock;

@end


