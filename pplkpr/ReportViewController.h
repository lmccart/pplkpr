//
//  ReportViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextFieldDelegate.h"
#import "PersonViewController.h"

@interface ReportViewController : UIViewController <UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate>


- (IBAction)pickAction:(id)sender;
- (IBAction)pickFriendsButtonTouch:(id)sender;
- (IBAction)submit:(id)sender;



@end

