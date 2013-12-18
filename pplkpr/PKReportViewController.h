//
//  PKReportViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PKPersonSummaryViewController.h"

@interface PKReportViewController : UIViewController <UITextFieldDelegate, FBFriendPickerDelegate>


- (IBAction)pickAction:(id)sender;
- (IBAction)pickFriendsButtonTouch:(id)sender;
- (IBAction)submit:(id)sender;

@end

