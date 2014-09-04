//
//  LeftViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)submit:(id)sender;

@end

