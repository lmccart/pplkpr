//
//  FBHandler.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/3/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "FBHandler.h"
#import "AppDelegate.h"

@interface FBHandler()

@end


@implementation FBHandler

+ (id)data {
    static FBHandler *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}

- (id)init {
	
    if (self = [super init]) {
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
        
        if (!FBSession.activeSession.isOpen) {
            // if the session is closed, then we open it here, and establish a handler for state changes
            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
	}
    return self;
}



- (void)requestProfile:(NSString *)fbid
            completion:(void (^)(NSDictionary *result))completionBlock {
	
    NSString *reqString = [NSString stringWithFormat:@"%@/?fields=picture", fbid];
    NSLog(@"%@", reqString);
    FBRequest* profileRequest = [FBRequest requestForGraphPath:reqString];
    [profileRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        else {
            completionBlock(result);
        }
    }];
}

- (void) requestFriendsWithCompletion:(void (^)(NSArray *))completionBlock {
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            completionBlock([result objectForKey:@"data"]);
        }
    }];
}

@end