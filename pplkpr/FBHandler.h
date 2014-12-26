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
@property BOOL useFakebook;

@property BOOL loggedIn;



+ (id)data;
- (id)init;
- (void)loginWithCompletion:(void (^)(BOOL status))completionBlock;
- (void)logout;

- (void)closeSession;
- (void)handleActivate;
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

- (void)requestFriendsWithCompletion:(void (^)(NSArray *result))completionBlock;
- (void)requestOwnProfile:(void (^)(NSDictionary *results))completionBlock;
- (void)requestProfilePic:(NSString *)fbid  withType:(NSString *)type withCompletion:(void (^)(NSDictionary *results))completionBlock;
//- (void)requestPost:(NSString *)fbid;
- (void)requestSendWarning:(Person *)person withEmotion:(NSString *)emotion;
- (void)requestLogin:(NSString *)email withPass:(NSString *)pass withCompletion:(void (^)(NSDictionary *results))completionBlock;
- (void)createFakebookRequest:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion;

- (void)checkTicket:(NSString *)ticket  withCompletion:(void (^)(int status))completionBlock;
- (void)logData:(NSString *)data withTag:(NSString *)tag withCompletion:(void (^)(NSData *))completionBlock;

@end


