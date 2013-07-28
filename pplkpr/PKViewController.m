//
//  PKViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKViewController.h"
#import "PKMeetViewController.h"

@interface PKViewController()


@property (strong, nonatomic) UITextField *whoTextField;
@property (copy, nonatomic) NSString *whoString;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;

- (void)fillTextBoxAndDismiss:(NSString *)text;

@end




@implementation PKViewController


@synthesize whoString = _whoString;
@synthesize whoTextField = _whoTextField;
@synthesize friendPickerController = _friendPickerController;

- (void)viewDidLoad
{
	// When the user starts typing, show the clear button in the text field.
	self.whoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
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
//
//- (void)reset {
//	self.whoTextField.text = @"";
//	self.whoString = @"";
//}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	if (theTextField == self.whoTextField) {
		NSLog(@"resign\n");
		[self.whoTextField resignFirstResponder];
	}
	else NSLog(@"not who field\n");
	return YES;
}



#pragma mark UI handlers

- (IBAction)pickFriendsButtonTouch:(id)sender {
	NSLog(@"fb fp pick\n");
	
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
														  FBSessionState state,
														  NSError *error) {
										  if (error) {
											  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																								  message:error.localizedDescription
																								 delegate:nil
																						cancelButtonTitle:@"OK"
																						otherButtonTitles:nil];
											  [alertView show];
										  } else if (session.isOpen) {
											  [self pickFriendsButtonTouch:sender];
										  }
									  }];
        return;
    }
	
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
	
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
	
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    self.whoTextField.text = text;
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark -


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.whoTextField resignFirstResponder];
	self.whoTextField.text = self.whoString;
	[super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ( [segue.identifier isEqualToString:@"MeetSegue"] ) {
		PKMeetViewController *mvc = (PKMeetViewController*)segue.destinationViewController;
		NSLog(@"HI\n");
		
	}
	
}

- (void)viewDidUnload {
	self.whoString = nil;
    self.whoTextField = nil;
	self.friendPickerController = nil;
	[super viewDidUnload];
}

@end
