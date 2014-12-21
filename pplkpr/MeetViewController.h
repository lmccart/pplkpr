//
//  MeetViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MLPAutoCompleteTextFieldDelegate.h"
#import "PersonViewController.h"

@interface MeetViewController : UIViewController <UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate, MFMessageComposeViewControllerDelegate>

- (IBAction)submit:(id)sender;
- (IBAction)back:(id)sender;


@end

