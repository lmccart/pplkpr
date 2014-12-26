//
//  IOSHandler.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/23/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "IOSHandler.h"
#import "AppDelegate.h"
#import "FBHandler.h";

@interface IOSHandler()
//
//@property NSString *fakebookURL;
//@property int gender;
//@property NSString *firstName;
//@property NSString *fullName;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) RHAddressBook *addressBook;
@property (nonatomic, retain) MFMessageComposeViewController *messageComposeController;
@property (nonatomic, strong) NSArray *pokeMessages;
@property (nonatomic, strong) NSArray *inviteMessages;

@end


@implementation IOSHandler

+ (id)data {
    static IOSHandler *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}

- (id)init {
	
    if (self = [super init]) {
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        self.addressBook = [[RHAddressBook alloc] init];
        if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined){
            
            //request authorization
            [self.addressBook requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
                //NSLog(@"authorized");
            }];
        }
        
        self.pokeMessages = [[NSArray alloc] initWithObjects:@"hi there", @"hi!", @"yo", @"sup", @"hey", @":)", @";)", @"xo", nil];
        self.inviteMessages = [[NSArray alloc] initWithObjects:@"want to hang out?", @"what are you up to?", @"want to meet up?", @"let's do something soon!", @"what are you doing later?", @"can we hang out?", @"let's do something", nil];
    }
    return self;
}

- (RHPerson *)getContact:(NSString *)name {
    NSArray *matches = [self.addressBook peopleWithName:name];
    NSLog(@"%@ %@", name, matches);
    if ([matches count] > 0) {
        return [matches objectAtIndex:0]; // duplicate names? hell just pick the first sucker :)
    }
    else return nil;
    
}
- (void)removeContact:(NSString *)name {
    RHPerson *p = [self getContact:name];
    if (p) {
        [self.addressBook removePerson:p];
        [self.addressBook save];
    }
}

- (void)sendText:(Person *)person withMessage:(NSString *)msg fromController:(UIViewController *)controller {
    RHPerson *p = [self getContact:person.name];
    NSLog(@"%@", p.phoneNumbers);
    if (p && [p.phoneNumbers count] > 0) {
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        if (self.messageComposeController) {
            self.messageComposeController = nil;
        }
        self.messageComposeController = [[MFMessageComposeViewController alloc]init];
        
        NSString *str = [p.phoneNumbers valueAtIndex:0];
        NSArray *recipents = @[str];
        
        self.messageComposeController.messageComposeDelegate = controller;
        [self.messageComposeController setRecipients:recipents];
        [self.messageComposeController setBody:msg];
        
        // Present message view controller on screen
        [controller presentViewController:self.messageComposeController animated:YES completion:nil];
    } else {
        // [[FBHandler data] requestPost:person.fbid];
    }
    
}

- (void)performAction:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if ([type isEqualToString:@"poke"]) {
        NSUInteger randomInd = arc4random() % [self.pokeMessages count];
        NSString *msg = [self.pokeMessages objectAtIndex:randomInd];
        [self sendText:person withMessage:msg fromController:appDelegate.homeController];
    }
    else if ([type isEqualToString:@"post"]) {
        [self sendText:person withMessage:message fromController:appDelegate.homeController];
    }
    else if ([type isEqualToString:@"join_event"]) {
        NSUInteger randomInd = arc4random() % [self.inviteMessages count];
        NSString *msg = [self.inviteMessages objectAtIndex:randomInd];
        [self sendText:person withMessage:msg fromController:appDelegate.homeController];
    }
    else if ([type isEqualToString:@"block"]) {
        [self removeContact:person.name];
    }
    else if ([type isEqualToString:@"unfriend"]) {
        [self removeContact:person.name];
    }
}


@end

