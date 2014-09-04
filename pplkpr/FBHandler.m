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


- (void)requestProfile:(NSString *)fbid
            withCompletion:(void (^)(NSDictionary *result))completionBlock {
	
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


- (void)requestPost:(Person *)person withMessage:(NSString *)message {
    
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@&message=%@&id=%@",
                                 self.email,
                                 self.pass,
                                 message,
                                 person.fbid];
    [self createFakebookRequest:person withType:@"post" withRequest:requestString];
    
}

- (void)requestPoke:(Person *)person {
    
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@&id=%@",
                                 self.email,
                                 self.pass,
                                 person.fbid];
    [self createFakebookRequest:person withType:@"poke" withRequest:requestString];

}

- (void)createFakebookRequest:(Person *)person withType:(NSString *)type withRequest:(NSString *)requestString {
    NSString *urlString = [NSString stringWithFormat:@"https://server.pplkpr.com:3000/%@", type];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"error: %@", error);
                               }
                               else {
                                   //NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //NSLog(@"SUCCEEDED: %@",returnString);
                                   
                                   NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   NSString *ticket = [results objectForKey:@"ticket"];
                                   [person.fb_tickets addObject:ticket];
                                   
                                   // save context
                                   NSError* error;
                                   if (![_managedObjectContext save:&error]) {
                                       NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                                   }
                               }
                           }];
}

@end