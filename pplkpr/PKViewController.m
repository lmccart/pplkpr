//
//  PKViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKViewController.h"
#import "PKMeetViewController.h"


@interface PKViewController ()

@end

@implementation PKViewController


@synthesize whoTextField;
@synthesize whoString;

- (void)viewDidLoad
{
	// When the user starts typing, show the clear button in the text field.
	whoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)reset {
	whoTextField.text = @"";
	self.whoString = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == whoTextField) {
		[whoTextField resignFirstResponder];
	}
	return YES;
}


- (IBAction)submitMeet:(id)sender {
	
}


- (IBAction)submitLeft:(id)sender {
	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[whoTextField resignFirstResponder];
	whoTextField.text = self.whoString;
	[super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ( [segue.identifier isEqualToString:@"MeetSegue"] ) {
		PKMeetViewController *mvc = (PKMeetViewController*)segue.destinationViewController;
		NSLog(@"HI\n");
		
	}
	
}

- (void)dealloc {
	[whoTextField release];
	[whoString release];
	[super dealloc];
}

@end
