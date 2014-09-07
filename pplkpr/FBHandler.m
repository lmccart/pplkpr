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
    [self createFakebookRequest:person withType:@"post" withMessage:message];
    
}

- (void)requestPoke:(Person *)person {
    [self createFakebookRequest:person withType:@"post" withMessage:@""];
}

- (void)createFakebookRequest:(Person *)person withType:(NSString *)type withMessage:(NSString *)message {
    NSString *requestString = [NSString stringWithFormat:@"email=%@&password=%@&message=%@&id=%@",
                               self.email,
                               self.pass,
                               message,
                               person.fbid];
    
    NSString *urlString = [NSString stringWithFormat:@"https://server.pplkpr.com:3000/%@", type];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:person.fbid forHTTPHeaderField:@"fbid"];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *returnString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"SUCCEEDED: %@",returnString);

    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:nil];
    NSString *ticket = [results objectForKey:@"ticket"];
    
    if (ticket != nil) {
        
        NSString *fbid = @"522346222"; // PEND
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbid == %@", fbid];
        [request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:_managedObjectContext]];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
        if (result != nil) {
            if ([result count] > 0) {
                Person *p = [result objectAtIndex:0];
                [p.fb_tickets addObject:ticket];
                NSLog(@"saved ticket %@", ticket);
            }
        }

        // save context
        NSError* saveError;
        if (![_managedObjectContext save:&saveError]) {
           NSLog(@"Whoops, couldn't save: %@", [saveError localizedDescription]);
        }
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    NSLog(@"connection failed with error %@", error);
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"hi0");

    NSLog(@"hi2");
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"admin"
                                                                    password:@""
                                                                 persistence:NSURLCredentialPersistenceForSession];
        
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        
        // inform the user that the user name and password
        // in the preferences are incorrect
        
        NSLog (@"failed authentication");
        
        // ...error will be handled by connection didFailWithError
    }
}

@end