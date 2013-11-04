//
//  PKLeftOverallViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKLeftOverallViewController.h"


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
	
	if ([_data personName]) {
		[_personNameLabel setText:[_data personName]];
	}
	[_overallField setDelegate:self];
	[_overallField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://lauren-mccarthy.com/pplkpr-server/submit.php?type=interaction&user=lauren&name=friend&moments=none&rating=%f", [_overallSlider value]]];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:URL
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		//[self reset];
		NSLog(@"success");
	} else {
		// Inform the user that the connection failed.
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
