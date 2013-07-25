//
//  PKViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKViewController : UIViewController <UITextFieldDelegate> {
	
	IBOutlet UITextField *whoTextField;
	NSString *whoString;
}

@property (nonatomic, retain) UITextField *whoTextField;
@property (nonatomic, copy) NSString *whoString;

- (void)reset;

@end