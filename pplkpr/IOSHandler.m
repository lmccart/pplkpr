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
@property RHAddressBook *addressBook;

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
        } else {
            [self removeContact:@"nika and austin airbnb"];
        }
    }
    return self;
}

- (void)removeContact:(NSString *)name {
    NSArray *matches = [self.addressBook peopleWithName:name];
    if ([matches count] > 0) {
        RHPerson *p = [matches objectAtIndex:0]; // duplicate names? hell just pick the first sucker :)
        BOOL success = [self.addressBook removePerson:p];
        [self.addressBook save];
    }
}
@end

