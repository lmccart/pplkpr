//
//  FBHandler.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/3/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "FBHandler.h"
#import "AppDelegate.h"

@interface FBHandler() {
    NSMutableData * _responseData;
}

@property NSString *fakebook_url;

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
        
        // load credentials for fakebook
        NSString* path = [[NSBundle mainBundle] pathForResource:@"credentials"
                                                         ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        if (content) {
            NSArray *toks = [content componentsSeparatedByString:@":"];
            self.fakebook_url = [NSString stringWithFormat:@"https://%@:%@@server.pplkpr.com:3000/", toks[0], toks[1]];
        } else {
            NSLog(@"problem loading credentials.txt");
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
    [self createFakebookRequest:person withType:@"post" withMessage:message];
    
}

- (void)requestPoke:(Person *)person {
    [self createFakebookRequest:person withType:@"post" withMessage:@""];
}


- (void)requestBlock:(Person *)person {
    [self createFakebookRequest:person withType:@"block" withMessage:@""];
}

- (void)requestUnblock:(Person *)person {
    [self createFakebookRequest:person withType:@"unblock" withMessage:@""];
}


- (void)requestFriend:(Person *)person {
    [self createFakebookRequest:person withType:@"friend" withMessage:@""];
}


- (void)requestUnfriend:(Person *)person {
    [self createFakebookRequest:person withType:@"unfriend" withMessage:@""];
}

// pend
- (void)requestInviteToEvent:(Person *)person {
    [self createFakebookRequest:person withType:@"join_event" withMessage:@""];
}

- (void)requestLogin:(NSString *)email withPass:(NSString *)pass {
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@",
                               self.email,
                               self.pass];
    
    [self requestUrl:@"login" withRequest:requestString withCompletion:^(NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"SUCCEEDED LOGIN: %@",returnString);
        
        //NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //NSString *ticket = [results objectForKey:@"ticket"];
    }];
}

- (void)createFakebookRequest:(Person *)person withType:(NSString *)type withMessage:(NSString *)message {
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@&message=%@&id=%@",
                               self.email,
                               self.pass,
                               message,
                               person.fbid];
    
    [self requestUrl:type withRequest:requestString withCompletion:^(NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"SUCCEEDED: %@",returnString);
    
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *ticket = [results objectForKey:@"ticket"];
        [person.fb_tickets addObject:ticket];
    
        // save context
        NSError* error;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];



}

- (void)checkTicket:(NSString *)ticket {
    
}

- (void)requestUrl:(NSString *)endpoint withRequest:(NSString *)requestString withCompletion:(void (^)(NSData *))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.fakebook_url, endpoint];
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
                               } else {
                                   completionBlock(data);
                               }
                           }];
}

@end

