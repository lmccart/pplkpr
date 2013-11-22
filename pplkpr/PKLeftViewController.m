//
//  PKLeftViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKLeftViewController.h"
#import "PKInteractionData.h"

@interface PKLeftViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;

@property (strong, nonatomic) IBOutlet UITextField *whoTextField;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;

- (void)fillTextBoxAndDismiss:(NSString *)text;

@end

@implementation PKLeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"initing\n");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		NSLog(@"init\n");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
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
	[[PKInteractionData data] setEmotion:[[[PKInteractionData data] emotionsArray] objectAtIndex:0]];
	
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"return\n");
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_whoTextField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
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
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @""];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    _whoTextField.text = text;
    
    [self dismissViewControllerAnimated:NO completion:nil];
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
	[[PKInteractionData data] setEmotion:[[[PKInteractionData data] emotionsArray] objectAtIndex:row]];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)pushOverallViewController
{
	[self performSegueWithIdentifier:@"overallSegue" sender:self];
}


- (IBAction)submit:(id)sender {
	
	[[PKInteractionData data] setPersonName:_whoTextField.text];
	NSLog(@"%@ %@", [[PKInteractionData data] emotion] , [[PKInteractionData data] personName]);
	
	NSArray *keys = [NSArray arrayWithObjects:@"func", @"user", @"name", @"emotion",@"intensity", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"interaction", @"lauren", [[PKInteractionData data] personName], [[PKInteractionData data] emotion], [NSNumber numberWithFloat:[_intensitySlider value]], nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	
	
	NSLog(@"emotion is %@", [[PKInteractionData data] emotion]);
	
	NSURL *url = [NSURL URLWithString:@"http://lauren-mccarthy.com/pplkpr-server/submit.php"];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:jsonData];
	
	
	receivedData = [[NSMutableData alloc] init];
	
	NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
	if (!connection) {
		receivedData = nil;
		NSLog(@"connection failed");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Succeeded! Received %d bytes of data", [receivedData length]);
	//	NSString *responeString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
	NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
	NSLog(@"%@",jsonDictionary);
	
	[[PKInteractionData data] setSummary:jsonDictionary];
	
	connection = nil;
    receivedData = nil;
	
	[self pushOverallViewController];
	
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	
    _whoTextField = nil;
	_friendPickerController = nil;
	_emotionPicker = nil;
	_intensitySlider = nil;
	[super viewDidUnload];
}

- (void)dealloc {
	[_whoTextField release];
	[_friendPickerController release];
	[_emotionPicker release];
	[_intensitySlider release];
	[super dealloc];
}
@end
