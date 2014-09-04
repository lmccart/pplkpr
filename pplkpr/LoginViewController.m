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
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailField resignFirstResponder];
    [self.passField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)login:(id)sender {
    [self.emailField resignFirstResponder];
    [self.passField resignFirstResponder];
    
    NSString *email = [self.emailField text];
    NSString *pass = [self.passField text];
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:email forKey:@"email"];
    [defaults setObject:pass forKey:@"pass"];
    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
