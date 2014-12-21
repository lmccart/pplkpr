//
//  ViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate> {
}

- (IBAction)logoutFB:(id)sender;
- (IBAction)report:(id)sender;
- (void)updateMonitorStatus:(float)status;
- (void)updateMonitorBatteryLevel:(float)level;

@end