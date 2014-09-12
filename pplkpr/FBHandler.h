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

@property (strong, nonatomic) FBSession *session;


+(id)data;
-(id)init;

- (void)closeSession;
- (void)handleActivate;
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)requestFriendsWithCompletion:(void (^)(NSArray *result))completionBlock;
- (void)requestOwnProfile:(void (^)(NSDictionary *results))completionBlock;
- (void)requestProfilePic:(NSString *)fbid withCompletion:(void (^)(NSDictionary *results))completionBlock;

- (void)requestSendWarning:(Person *)person withEmotion:(NSString *)emotion;
- (void)requestPost:(Person *)person withMessage:(NSString *)message;
- (void)requestPoke:(Person *)person;
- (void)requestBlock:(Person *)person;
- (void)requestUnblock:(Person *)person;
- (void)requestFriend:(Person *)person;
- (void)requestUnfriend:(Person *)person;
- (void)requestInviteToEvent:(Person *)person;
- (void)requestLogin:(NSString *)email withPass:(NSString *)pass withCompletion:(void (^)(NSDictionary *results))completionBlock;

- (void)checkTicket:(NSString *)ticket  withCompletion:(void (^)(int status))completionBlock;
- (void)logReport:(NSString *)reportData withRRData:(NSString *) rrData withHRVData:(NSString *)hrvData;

@end


