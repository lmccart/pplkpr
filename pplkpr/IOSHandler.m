//
//  IOSHandler.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/23/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "IOSHandler.h"
#import "AppDelegate.h"

@interface IOSHandler()
//
//@property NSString *fakebookURL;
//@property int gender;
//@property NSString *firstName;
//@property NSString *fullName;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

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
        _managedObjectContext = appDelegate.managedObjectContext;
        
        RHAddressBook *ab = [[RHAddressBook alloc] init];
        if ([RHAddressBook authorizationStatus] == RHAuthorizationStatusNotDetermined){
            
            //request authorization
            [ab requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
                //[abViewController setAddressBook:ab];
                NSLog(@"authorized");
                NSArray *allKyles = [ab peopleWithName:@"Kyle"];
                NSLog(@"all kyles %@", allKyles);
            }];
        } else {
            NSArray *allKyles = [ab peopleWithName:@"Kyle"];
            NSLog(@"all kyles %@", allKyles);
        }
    }
    return self;
}
@end

