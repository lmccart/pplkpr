//
//  PKLeftOverallViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKInteractionData.h"

@interface PKLeftOverallViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) PKInteractionData *data;

- (IBAction)submit:(id)sender;

@end
