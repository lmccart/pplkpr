//
//  FBHandler.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/3/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "FBHandler.h"
#import "AppDelegate.h"
#import "IOSHandler.h"

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
        
        // load credentials for fakebook
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.useFakebook = [defaults boolForKey:@"useFakebook"];
        
        if (self.useFakebook) {
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
        } else {
            self.loggedIn = FBSession.activeSession.isOpen;
            // PEND IS THIS OK?
//            if (!self.loggedIn) {
//                if ([defaults boolForKey:@"okFaceLogin"]) {
//                    [self login];
//                }
//                
//            }
        }
	}
    return self;
}


/**
 * LEGIT FACEBOOK METHODS
 */


- (void)login {
    [self loginWithCompletion:^(BOOL status) {}];
}

- (void)loginWithCompletion:(void (^)(BOOL status))completionBlock {
    //[FBSession.activeSession closeAndClearTokenInformation];
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                completionBlock(false);
            } else {
                NSLog(@"facebook session opened");
                [self requestOwnProfile:^(NSDictionary *result) {
                    NSString *firstName = [result objectForKey:@"first_name"];
                    [self setFirstName:firstName];
                    NSString *fullName = [[result objectForKey:@"name"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                    [self setFullName:fullName];
                    
                    self.loggedIn = true;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:true forKey:@"okFaceLogin"];
                    [defaults synchronize];
                    
                    completionBlock(true);
                }];
            }
        }];
    } else {
        self.loggedIn = true;
        completionBlock(true);
    }
}

- (void)logout {
    NSLog(@"logging out of facebook!");
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)handleActivate {
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void)closeSession {
    [FBSession.activeSession close];
}


- (void)requestFriendsWithCompletion:(void (^)(NSArray *))completionBlock {
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error) {
            //NSLog(@"error: %@", error);
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
            //NSLog(@"error: %@", error);
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
    FBRequest* profileRequest = [FBRequest requestForGraphPath:reqString];
    [profileRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error) {
            //NSLog(@"error: %@", error);
        }
        else {
            completionBlock(result);
        }
    }];
}
//
//- (void)requestPost:(NSString *)fbid {
//
//    NSLog(@"request post");
//    // create the connection object
//    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
//    
//    // create a handler block to handle the results of the request for fbid's profile
//    FBRequestHandler handler =
//    ^(FBRequestConnection *connection, id result, NSError *error) {
//        // output the results of the request
//        NSLog(@"handled");
//        NSLog(@"%@", error);
//    };
//    
//    // create the request object, using the fbid as the graph path
//    // as an alternative the request* static methods of the FBRequest class could
//    // be used to fetch common requests, such as /me and /me/friends
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
//                          @"test post", @"message",
//                          fbid, @"tags",
//                          @"514572205349403", @"place",
//                          nil];
//    
//    FBRequest *request=[[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/feed" parameters:data HTTPMethod:@"POST"];
//    
//    // add the request to the connection object, if more than one request is added
//    // the connection object will compose the requests as a batch request; whether or
//    // not the request is a batch or a singleton, the handler behavior is the same,
//    // allowing the application to be dynamic in regards to whether a single or multiple
//    // requests are occuring
//    [newConnection addRequest:request completionHandler:handler];
////    
////    // if there's an outstanding connection, just cancel
////    [self.requestConnection cancel];
//    
//    // keep track of our connection, and start it
//    //self.requestConnection = newConnection;
//    [newConnection start];
//}

/**
 * FAKEBOOK METHODS
 */

- (void)requestSendWarning:(Person *)person withEmotion:(NSString *)emotion {
    if (self.useFakebook) {
        [self createFakebookRequest:person withType:@"post" withMessage:[NSString stringWithFormat:@"I am on my way to meet you and I am feeling %@", [emotion lowercaseString]] withEmotion:nil];
    }
}

- (void)requestLogin:(NSString *)email withPass:(NSString *)pass withCompletion:(void (^)(NSDictionary *results))completionBlock {
    if (self.useFakebook) {
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
}

- (void)createFakebookRequest:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion {
    
    if (self.useFakebook) {
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
                //NSLog(@"adding ticket(id:emo) %@ for action %@", ticket, type);
            
                // save context
                NSError* error;
                if (![_managedObjectContext save:&error]) {
                    //NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
            }
        }];
    }
}

- (void)checkTicket:(NSString *)ticket withCompletion:(void (^)(int status))completionBlock {
    
    if (self.useFakebook) {
        NSString *endpoint = [NSString stringWithFormat:@"status/%@", ticket];
        
        [self requestUrl:endpoint withRequest:@"" withType:@"GET" withCompletion:^(NSData *data) {
            //NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"SUCCEEDED TICKET CHECK: %@",returnString);
            
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            int status = [[results objectForKey:@"status"] integerValue];
            completionBlock(status);
        }];
    }
}

- (void)requestUrl:(NSString *)endpoint withRequest:(NSString *)requestString withType:(NSString *)type withCompletion:(void (^)(NSData *))completionBlock {
    
    if (self.useFakebook) {
    
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
                                       //NSLog(@"error: %@", error);
                                   } else {
                                       completionBlock(data);
                                   }
                               }];
    }
}


- (void)logData:(NSString *)data withTag:(NSString *)tag withCompletion:(void (^)(NSData *))completionBlock {
    if (self.useFakebook) {
        NSString *request = [NSString stringWithFormat:@"id=%@&type=%@&data=%@",
                               self.fullName,
                               tag,
                               data];
        [self requestUrl:@"device_log" withRequest:request withType:@"POST" withCompletion:^(NSData *data) {
            //NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"LOGGED %@", tag);
            if (completionBlock) {
                completionBlock(data);
            }
        }];
    }
}

@end

