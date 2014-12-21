//
//  IOSHandler.h
//  pplkpr
//
//  Created by Lauren McCarthy on 11/23/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RHAddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "Person.h"

@interface IOSHandler : UIViewController <NSURLConnectionDelegate>

+(id)data;
-(id)init;
-(void)sendText:(NSString *)name withMessage:(NSString *)msg fromController:(UIViewController *)controller;
- (void)performAction:(Person *)person withType:(NSString *)type withMessage:(NSString *)message withEmotion:(NSString *)emotion;

@end


