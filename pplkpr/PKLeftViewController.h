//
//  PKLeftViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PKPersonSummaryViewController.h"

@interface PKLeftViewController : UIViewController <UITextFieldDelegate, FBFriendPickerDelegate>


- (IBAction)pickFriendsButtonTouch:(id)sender;
- (IBAction)submit:(id)sender;

@end

