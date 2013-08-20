//
//  PKLeftOverallViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKLeftOverallViewController : UIViewController {
	IBOutlet UISlider *ratingSlider;
	
}

@property (strong, nonatomic) UISlider *ratingSlider;
- (IBAction)submit:(id)sender;

@end
