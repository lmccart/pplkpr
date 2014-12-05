//
//  LoginViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/4/13.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "LoginViewController.h"
#import "FBHandler.h"

@interface LoginViewController()

@property (retain, nonatomic) IBOutlet UIView *faceLoginView;
@property (retain, nonatomic) IBOutlet UIView *fakeLoginView;

@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UITextField *passField;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [FBHandler data];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    [self.passField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)]];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useFakebook = [defaults boolForKey:@"useFakebook"];
    if (useFakebook) {
        [self.faceLoginView setHidden:true];
        [self.fakeLoginView setHidden:false];
    } else {
        [[FBHandler data] logout];
        [self.faceLoginView setHidden:false];
        [self.fakeLoginView setHidden:true];
    }
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passField becomeFirstResponder];
    } else if (textField == self.passField) {
        [textField resignFirstResponder];
        if (![self.passField.text isEqualToString:@""] && ![self.passField.text isEqualToString:@""]) {
            [self fakeLogin:nil];
        }
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailField resignFirstResponder];
    [self.passField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)fakeLogin:(id)sender {
    
    if ([self.passField.text isEqualToString:@""] || [self.passField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Please enter a username and password."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self startRotatingAnim];
    
    [self.emailField resignFirstResponder];
    [self.passField resignFirstResponder];
    
    NSString *email = [self.emailField text];
    NSString *pass = [self.passField text];
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:email forKey:@"email"];
    [defaults setObject:pass forKey:@"pass"];
    [defaults synchronize];
    
    [[FBHandler data] requestLogin:email withPass:pass withCompletion:^(NSDictionary *results) {
        NSString *ticket = [results objectForKey:@"ticket"];
        [self checkLoginStatus:ticket];
    }];
}

- (IBAction)faceLogin {
    [[FBHandler data] loginWithCompletion:^(BOOL status) {
        if (status) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } {
            [self stopRotatingAnim];
        }
    }];
}

- (void)checkLoginStatus:(NSString *)ticket {
    [[FBHandler data] checkTicket:ticket withCompletion:^(int status) {
        if (status == 1) {
            [self stopRotatingAnim];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else if (status == 0) {
            [self checkLoginStatus:ticket];
        } else if (status == -1) {
            [self stopRotatingAnim];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                            message:@"Incorrect username or password."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)startRotatingAnim {
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        self.loginButton.transform = transform;
    } completion:NULL];
}

- (void)stopRotatingAnim {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * 0.05);
        self.loginButton.transform = transform;
    } completion:NULL];
}

@end
