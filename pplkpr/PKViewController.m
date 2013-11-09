//
//  PKViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKViewController.h"
#import "PKMeetViewController.h"
#import "PKLeftViewController.h"
#import "PKInteractionData.h"

@interface PKViewController()


@property (strong, nonatomic) UITextField *whoTextField;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;

- (void)fillTextBoxAndDismiss:(NSString *)text;

@end




@implementation PKViewController



- (void)viewDidLoad
{
	// When the user starts typing, show the clear button in the text field.
	[_whoTextField setDelegate:self];
    [_whoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
	
    if (_friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
		_friendPickerController = [[FBFriendPickerViewController alloc] init];
        _friendPickerController.title = @"Pick Friend";
        _friendPickerController.delegate = self;
		_friendPickerController.allowsMultipleSelection = NO;
    }
	
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

#pragma mark UI handlers

- (IBAction)pickFriendsButtonTouch:(id)sender {
	NSLog(@"fb fp pick\n");
	
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
			if (error) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
			} else if (session.isOpen) {
				[self pickFriendsButtonTouch:sender];
			}
		}];
        return;
    }
	
    [_friendPickerController loadData];
    [_friendPickerController clearSelection];
	
    [self presentViewController:_friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in _friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    _whoTextField.text = text;
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_whoTextField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ( [segue.identifier isEqualToString:@"MeetSegue"] ){
		//PKMeetViewController *mvc = (PKMeetViewController*)segue.destinationViewController;
	}
	else if ([segue.identifier isEqualToString:@"LeftSegue"]){
		[[PKInteractionData data] setPersonName:_whoTextField.text];
	}
}

- (void)viewDidUnload {
    _whoTextField = nil;
	_friendPickerController = nil;
	[super viewDidUnload];
}

- (void)dealloc {
	[_whoTextField release];
	[_friendPickerController release];
	[super dealloc];
}

@end
