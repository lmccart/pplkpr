//
//  LoginViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/4/13.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController()

@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIImageView *personImage;


@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // rearrange things if iphone5
    if (self.view.frame.size.height >= 568) {
        CGRect frame = self.loginButton.frame;
        [self.loginButton setFrame:CGRectMake(frame.origin.x, 449, frame.size.width, frame.size.height)];
        [self.personImage setHidden:false];
    } else {
        [self.personImage setHidden:true];
    }
}


- (IBAction)login:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
