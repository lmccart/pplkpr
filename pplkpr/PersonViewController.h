//
//  PersonViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/ABAddressBook.h>
#import "InteractionData.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PersonViewController : UIViewController <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

-(IBAction) showMore:(id)sender;
-(IBAction) sendInAppSMS:(id)sender;

@end
