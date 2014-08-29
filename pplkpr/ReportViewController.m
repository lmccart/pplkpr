//
//  ReportViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "ReportViewController.h"
#import "InteractionData.h"
#import "TempHRV.h"
#import "MLPAutoCompleteTextField.h"
#import "CustomAutoCompleteCell.h"
#import "FriendsCompleteDataSource.h"
#import "FriendsCustomAutoCompleteObject.h"

@interface ReportViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	NSMutableData *receivedData;
}

@property int mode;

@property (strong, nonatomic) IBOutlet UIButton *meetButton;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;

@property (strong, nonatomic) IBOutlet UIView *whoView;
@property (strong, nonatomic) IBOutlet UILabel *whoLabel;
@property (strong, nonatomic) IBOutlet FriendsCompleteDataSource *autocompleteDataSource;
@property (weak) IBOutlet MLPAutoCompleteTextField *whoTextField;
@property (strong) NSString *whoName;
@property (strong) NSString *whoFbid;

@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UILabel *emotionLabel;
@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (strong) NSString *emotion;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UISlider *timeSlider;

@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;




- (void)fillTextBoxAndDismiss:(NSString *)text;

@end

@implementation ReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"initing\n");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		NSLog(@"init\n");
        self.mode = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	 
	[self.timeSlider setThumbImage:[UIImage imageNamed:@"rect.png"] forState:UIControlStateNormal];
	
	[self.whoTextField setDelegate:self];
    [self.whoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [(FriendsCompleteDataSource *) self.whoTextField.autoCompleteDataSource updateFriends];
    
    [self.whoTextField registerAutoCompleteCellClass:[CustomAutoCompleteCell class]
                                       forCellReuseIdentifier:@"CustomCellId"];
	
    [self.emotionPicker setDelegate:self];
    [self.emotionPicker setDataSource:self];
	self.emotion = [[NSString alloc] init];
    

}

- (void)viewWillAppear:(BOOL)animated {
    NSMutableDictionary *event = [[TempHRV data] getHRVEvent];
	self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:0];
    [self.intensitySlider setValue:[[event objectForKey:@"intensity"] floatValue]];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	[self toggleFormView];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.whoTextField resignFirstResponder];
	[self toggleFormView];
	[super touchesBegan:touches withEvent:event];
}

- (void)toggleFormView {
	if (self.mode != -1) {
		[self.formView setHidden:[self.whoTextField.text length] == 0];
	}
}



#pragma mark - UIPickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[InteractionData data] emotionsArray] count];
}


#pragma mark - UIPickerView Delegate

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 30)];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"TeluguSangamMN" size:17];
    label.text = [[[InteractionData data] emotionsArray] objectAtIndex:row];
    return label;
}


//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    NSLog(@"Chosen item: %@", [[[InteractionData data] emotionsArray] objectAtIndex:row]);
	self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:row];
}






#pragma mark UI handlers

- (IBAction)pickAction:(id)sender {
    
	[self resetForm];
    
	self.mode = ((UIButton*)sender).tag;
    
	if (self.mode) { // 1-left
		[self.whoLabel setText:@"I was just with"];
		[self.timeLabel setText:@"from"];
		[self.emotionLabel setText:@"I was feeling?"];
        [self.leftButton setAlpha:1.0];
        [self.meetButton setAlpha:0.25];
	} else { // 0-meet
		[self.whoLabel setText:@"I am about to meet"];
		[self.timeLabel setText:@"for"];
		[self.emotionLabel setText:@"I am feeling?"];
        [self.leftButton setAlpha:0.25];
        [self.meetButton setAlpha:1.0];
	}
	[self.whoView setHidden:false];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    self.whoTextField.text = text;
	[self toggleFormView];
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)submit:(id)sender {
	
	[[InteractionData data] addReport:self.whoName withFbid:self.whoFbid withEmotion:self.emotion withRating:[NSNumber numberWithFloat:[self.intensitySlider value]]];
    
	// go to person view
	[[InteractionData data] setJumpToName:self.whoTextField.text];
	[self.tabBarController setSelectedIndex:1];
    
    // reset form
	[self resetForm];
}


- (void)resetForm {
    
    [self.leftButton setAlpha:1.0];
    [self.meetButton setAlpha:1.0];
    
    [self setMode:-1];
    [self.whoTextField setText:@""];
	[self.whoView setHidden:true];
    [self setWhoName:@""];
    [self setWhoFbid:@""];
    
	[self.emotionPicker reloadAllComponents];
	[self.emotionPicker selectRow:0 inComponent:0 animated:NO];
    [self setEmotion: [[[InteractionData data] emotionsArray] objectAtIndex:0]];
	[self.intensitySlider setValue:0.5];
	[self.formView setHidden:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	
    self.whoTextField = nil;
	[super viewDidUnload];
}


#pragma mark - MLPAutoCompleteTextField Delegate

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedObject) {
        FriendsCustomAutoCompleteObject *fObj = (FriendsCustomAutoCompleteObject *)selectedObject;
        [self setWhoName:fObj.name];
        [self setWhoFbid:fObj.fbid];
        
    }
    [self toggleFormView];
}

@end
