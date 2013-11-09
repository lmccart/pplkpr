//
//  PKLeftViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKLeftViewController.h"
#import "PKLeftOverallViewController.h"
#import "PKInteractionData.h"

@interface PKLeftViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *personNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *descriptionField;
@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

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
	[_personNameLabel setText:[[PKInteractionData data] personName]];
	
    [_emotionPicker setDelegate:self];
    [_emotionPicker setDataSource:self];
	[_descriptionField setDelegate:self];
	[_descriptionField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
	_emotion = [[[PKInteractionData data] emotionsArray] objectAtIndex:0];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"return\n");
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_descriptionField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[[[PKInteractionData data] momentsArray] addObject:_emotion];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[_personNameLabel release];
	[_descriptionField release];
	[_emotionPicker release];
	[super dealloc];
}
@end
