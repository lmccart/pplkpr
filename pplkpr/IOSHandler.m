//
//  IOSHandler.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/23/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "IOSHandler.h"
#import "AppDelegate.h"
#import "ViewController.h"

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

- (NSArray *)getContacts {
    return [self.addressBook peopleOrderedByFirstName];
}

- (RHPerson *)getContact:(NSString *)name {
    NSArray *matches = [self.addressBook peopleWithName:name];
    NSLog(@"%@ %@", name, matches);
    if ([matches count] > 0) {
        return [matches objectAtIndex:0]; // duplicate names? hell just pick the first sucker :)
    }
    else return nil;
    
}


- (UIImage *)getContactPic:(Person *)person {
    RHPerson *p = [self getContact:person.name];
    if (p) {
        if (!p.hasImage) {
            return nil;
        } else {
            return p.originalImage;
        }
    }
    return nil;
}

- (void)removeContact:(NSString *)name {
    RHPerson *p = [self getContact:name];
    if (p) {
        [self.addressBook removePerson:p];
        [self.addressBook save];
    }
}

- (void)sendText:(Person *)person withMessage:(NSString *)msg fromController:(UIViewController *)controller {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    if (self.messageComposeController) {
        self.messageComposeController = nil;
    }
    
    self.messageComposeController = [[MFMessageComposeViewController alloc] init];
    self.messageComposeController.messageComposeDelegate = controller;
    [self.messageComposeController setBody:msg];
    
    
    RHPerson *p = [self getContact:person.name];
    
    bool send = false;
    if (p && [p.phoneNumbers count] > 0) {

        NSString *str = [p.phoneNumbers valueAtIndex:0];
        NSArray *recipents = @[str];
        
        [self.messageComposeController setRecipients:recipents];
        send = true;
    }
    
    if (![controller isKindOfClass:[ViewController class]]) {
        send = true;
    }
    
    // Present message view controller on screen
    if (send) { // don't send from home screen with no recipient!
        [controller presentViewController:self.messageComposeController animated:YES completion:nil];
    }
    
}

- (void)performAction:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion fromController:(UIViewController *)controller {
    
    NSLog(@"type %@", type);
    if ([type isEqualToString:@"poke"]) {
        NSUInteger randomInd = arc4random() % [self.pokeMessages count];
        NSString *msg = [self.pokeMessages objectAtIndex:randomInd];
        [self sendText:person withMessage:msg fromController:controller];
    }
    else if ([type isEqualToString:@"post"]) {
        [self sendText:person withMessage:message fromController:controller];
    }
    else if ([type isEqualToString:@"join_event"]) {
        NSUInteger randomInd = arc4random() % [self.inviteMessages count];
        NSString *msg = [self.inviteMessages objectAtIndex:randomInd];
        [self sendText:person withMessage:msg fromController:controller];
    }
    else if ([type isEqualToString:@"block"]) {
        [self removeContact:person.name];
    }
    else if ([type isEqualToString:@"unfriend"]) {
        [self removeContact:person.name];
    }
}

- (void)performAction:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion {
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self performAction:person withType:type withMessage:message withEmotion:emotion fromController:appDelegate.homeController];
}

@end

