//
//  PKReportViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKReportViewController.h"
#import "PKInteractionData.h"

@interface PKReportViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	NSMutableData *receivedData;
}

@property int mode;

@property (strong, nonatomic) IBOutlet UIView *whoView;
@property (strong, nonatomic) IBOutlet UITextField *whoTextField;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;

@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UILabel *emotionLabel;
@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UISlider *timeSlider;

@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;



- (void)fillTextBoxAndDismiss:(NSString *)text;

@end

@implementation PKReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"initing\n");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		NSLog(@"init\n");
    }
	_mode = -1;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	 
	[_timeSlider setThumbImage:[UIImage imageNamed:@"rect.png"] forState:UIControlStateNormal];
	
    if (_friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
		_friendPickerController = [[FBFriendPickerViewController alloc] init];
        _friendPickerController.title = @"Pick Friend";
        _friendPickerController.delegate = self;
		_friendPickerController.allowsMultipleSelection = NO;
    }
	
	[_whoTextField setDelegate:self];
    [_whoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
    [_emotionPicker setDelegate:self];
    [_emotionPicker setDataSource:self];
	_emotion = [[NSString alloc] init];
	
}

- (void)viewWillAppear:(BOOL)animated {
	_emotion = [[[PKInteractionData data] emotionsArray] objectAtIndex:0];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	[self toggleFormView];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_whoTextField resignFirstResponder];
	[self toggleFormView];
	[super touchesBegan:touches withEvent:event];
}

- (void)toggleFormView {
	if (_mode != -1) {
		[_formView setHidden:[_whoTextField.text length] == 0];
	}
}



#pragma mark - UIPickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[PKInteractionData data] emotionsArray] count];
}


#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[PKInteractionData data] emotionsArray] objectAtIndex:row];
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    NSLog(@"Chosen item: %@", [[[PKInteractionData data] emotionsArray] objectAtIndex:row]);
	_emotion = [[[PKInteractionData data] emotionsArray] objectAtIndex:row];
}




#pragma mark UI handlers

- (IBAction)pickAction:(id)sender {
	_mode = ((UIButton*)sender).tag;
	if (_mode) { // 1-left
		[_emotionLabel setText:@"I was feeling"];
		[_timeLabel setText:@"from"];
	} else { // 0-meet
		[_emotionLabel setText:@"I am feeling"];
		[_timeLabel setText:@"for"];
	}
	[_whoView setHidden:false];
}

- (IBAction)pickFriendsButtonTouch:(id)sender {
	NSLog(@"fb fp pick\n");
	
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
    
    for (id<FBGraphUser> user in _friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @""];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
	[self toggleFormView];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    _whoTextField.text = text;
	[self toggleFormView];
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)submit:(id)sender {
	
	[[PKInteractionData data] addReport:_whoTextField.text withEmotion:_emotion withRating:[NSNumber numberWithFloat:[_intensitySlider value]]];
	[self resetForm];
	// go to person view
	[[PKInteractionData data] setJumpToName:_whoTextField.text];
	[self.tabBarController setSelectedIndex:1];
}


- (void)resetForm {
	_mode = -1;
	_whoTextField.text = @"";
	[_whoView setHidden:true];
	_emotion = @"";
	[_emotionPicker reloadAllComponents];
	[_emotionPicker selectRow:0 inComponent:0 animated:NO];
	[_intensitySlider setValue:0.5];
	[_formView setHidden:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
