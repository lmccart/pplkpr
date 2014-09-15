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

@property NSString *fakebookURL;
@property int gender;
@property NSString *firstName;
@property NSString *fullName;

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
                } else {
                    NSLog(@"facebook session opened");
                    [self requestOwnProfile:^(NSDictionary *result) {
                        //NSLog(@"%@", result);
                        
                        NSString *gender = [result objectForKey:@"gender"];
                        if (gender) {
                            if ([gender isEqualToString:@"female"]) {
                                [self setGender:1];
                            } else {
                                [self setGender:-1];
                            }
                        } else {
                            [self setGender:0];
                        }
                        
                        NSString *firstName = [result objectForKey:@"first_name"];
                        [self setFirstName:firstName];
                        NSString *fullName = [[result objectForKey:@"name"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                        NSLog(@"%@ %@", result, fullName);
                        [self setFullName:fullName];
                    }];
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
            self.fakebookURL = [NSString stringWithFormat:@"https://%@:%@@server.pplkpr.com:3000/", toks[0], toks[1]];
        } else {
            NSLog(@"problem loading credentials.txt");
        }
        
	}
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void) handleActivate {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void) closeSession {
    [FBSession.activeSession close];
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

- (void)requestOwnProfile:(void (^)(NSDictionary *result))completionBlock {
    
    FBRequest* profileRequest = [FBRequest requestForGraphPath:@"me"];
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

// type square, small, normal, large
- (void)requestProfilePic:(NSString *)fbid withType:(NSString *)type
            withCompletion:(void (^)(NSDictionary *result))completionBlock {
    
    NSString *extra = [type isEqualToString:@"square"] ? @"type(square)" : @"height(200).width(200)";
	
    NSString *reqString = [NSString stringWithFormat:@"%@/?fields=picture.%@", fbid, extra];
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


- (void)requestSendWarning:(Person *)person withEmotion:(NSString *)emotion {
    NSString *pronoun = @"their";
    if (self.gender) {
        pronoun = self.gender == -1 ? @"his" : @"her";
    }
    [self createFakebookRequest:person withType:@"post" withMessage:[NSString stringWithFormat:@"%@ is on %@ way to meet you and is very %@", self.firstName, pronoun, [emotion lowercaseString]] withEmotion:nil];
}


- (void)requestLogin:(NSString *)email withPass:(NSString *)pass withCompletion:(void (^)(NSDictionary *results))completionBlock {
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@",
                               email,
                               pass];
    //NSLog(@"request string %@", requestString);
    
    [self requestUrl:@"login" withRequest:requestString withType:@"POST" withCompletion:^(NSData *data) {
        //NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"SUCCEEDED LOGIN: %@",returnString);
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completionBlock(results);
    }];
}


- (void)createFakebookRequest:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion {
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@&message=%@&id=%@",
                               self.email,
                               self.pass,
                               message,
                               person.fbid];
    
    [self requestUrl:type withRequest:requestString withType:@"POST" withCompletion:^(NSData *data) {
        //NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"SUCCEEDED: %@",returnString);
    
        if (emotion) { // warning posts won't have emotion and don't need to be saved
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *ticket = [NSString stringWithFormat:@"%@:%@", [results objectForKey:@"ticket"], emotion];
            [person.fbTickets setObject:type forKey:ticket];
            NSLog(@"adding ticket(id:emo) %@ for action %@", ticket, type);
        
            // save context
            NSError* error;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }];
}

- (void)checkTicket:(NSString *)ticket withCompletion:(void (^)(int status))completionBlock {
    
    NSString *endpoint = [NSString stringWithFormat:@"status/%@", ticket];
    
    [self requestUrl:endpoint withRequest:@"" withType:@"GET" withCompletion:^(NSData *data) {
        //NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"SUCCEEDED TICKET CHECK: %@",returnString);
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        int status = [[results objectForKey:@"status"] integerValue];
        completionBlock(status);
    }];
}

- (void)requestUrl:(NSString *)endpoint withRequest:(NSString *)requestString withType:(NSString *)type withCompletion:(void (^)(NSData *))completionBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.fakebookURL, endpoint];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:type];
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

- (void)logReport:(NSString *)reportData withRRData:(NSString *)rrData withHRVData:(NSString *)hrvData {
    
    NSString *rrRequest = [NSString stringWithFormat:@"id=%@&type=%@&data=%@",
                               self.fullName,
                               @"rr",
                               rrData];
    
    [self requestUrl:@"device_log" withRequest:rrRequest withType:@"POST" withCompletion:^(NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"LOGGING: %@",returnString);
    }];
    
    NSString *hrvRequest = [NSString stringWithFormat:@"id=%@&type=%@&data=%@",
                                  self.fullName,
                                  @"hrv",
                                  hrvData];
    
    [self requestUrl:@"device_log" withRequest:hrvRequest withType:@"POST" withCompletion:^(NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"LOGGING: %@",returnString);
    }];
    
    
    NSString *reportRequest = [NSString stringWithFormat:@"id=%@&type=%@&data=%@",
                                  self.fullName,
                                  @"report",
                                  reportData];
    
    [self requestUrl:@"device_log" withRequest:reportRequest withType:@"POST" withCompletion:^(NSData *data) {
        NSLog(@"logged report %@", data);
    }];
}


- (void)logAction:(NSString *)actionData {
    
    NSString *request = [NSString stringWithFormat:@"id=%@&type=%@&data=%@",
                           self.fullName,
                           @"action",
                           actionData];
    
    [self requestUrl:@"device_log" withRequest:request withType:@"POST" withCompletion:^(NSData *data) {
        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"LOGGING: %@",returnString);
    }];
    
}

@end

