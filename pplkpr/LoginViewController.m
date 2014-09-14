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

@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UITextField *passField;

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
	
}

- (void)viewWillAppear:(BOOL)animated {
    
//	if ([[InteractionData data] jumpToPerson]) {
//        self.curPerson = [[InteractionData data] jumpToPerson];
//        NSLog(@"%@", self.curPerson.fb_tickets);
//        [_personLabel setText:self.curPerson.name];
//        [[InteractionData data] setJumpToPerson:nil];
//        
//        [[FBHandler data] requestProfile:self.curPerson.fbid withCompletion:^(NSDictionary * result){
//            NSDictionary *pic = [result objectForKey:@"picture"];
//            NSDictionary *data = [pic objectForKey:@"data"];
//            NSString *url = [data objectForKey:@"url"];
//            
//            [self.personPhoto sd_setImageWithURL:[NSURL URLWithString:url]];
//        }];
//        
//	} else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passField becomeFirstResponder];
    } else if (textField == self.passField) {
        [textField resignFirstResponder];
        if (![self.passField.text isEqualToString:@""] && ![self.passField.text isEqualToString:@""]) {
            [self login:nil];
        }
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailField resignFirstResponder];
    [self.passField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)login:(id)sender {
    
    if ([self.passField.text isEqualToString:@""] || [self.passField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Please enter a username and password."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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

- (void)checkLoginStatus:(NSString *)ticket {
    [[FBHandler data] checkTicket:ticket withCompletion:^(int status) {
        if (status == 1) {
            NSLog(@"login successful");
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else if (status == 0) {
            NSLog(@"login processing");
            [self checkLoginStatus:ticket];
        } else if (status == -1) {
            NSLog(@"login failed, try again");
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

@end
