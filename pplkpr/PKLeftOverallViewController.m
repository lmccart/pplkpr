//
//  PKLeftOverallViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKLeftOverallViewController.h"
#import "PKInteractionData.h"


@interface PKLeftOverallViewController ()
	

@property (retain, nonatomic) IBOutlet UILabel *personNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *overallField;
@property (retain, nonatomic) IBOutlet UISlider *overallSlider;

@end



@implementation PKLeftOverallViewController


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
	
	[_personNameLabel setText:[[PKInteractionData data] personName]];
	
	[_overallField setDelegate:self];
	[_overallField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
	
	NSString *bodyData = [NSString stringWithFormat:@"type=interaction&user=lauren&name=%@&moments=none&rating=%f", [[PKInteractionData data] personName], [_overallSlider value]];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://lauren-mccarthy.com/pplkpr-server/submit.php?"]];
	[postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
	
	NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
	if (connection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		//[self reset];
		NSLog(@"success");
	} else {
		NSLog(@"fail");
	}
	

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"return\n");
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_overallField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}


- (void)viewDidUnload {
	_personNameLabel = nil;
	_overallField = nil;
	_overallSlider = nil;
	[super viewDidUnload];
}

- (void)dealloc {
	[_personNameLabel release];
	[_overallField release];
	[_overallSlider release];
	[super dealloc];
}

@end
