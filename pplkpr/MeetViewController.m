//
//  MeetViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "MeetViewController.h"
#import "InteractionData.h"
#import "HeartRateAnalyzer.h"
#import "FBHandler.h"
#import "MLPAutoCompleteTextField.h"
#import "CustomAutoCompleteCell.h"
#import "FriendsCompleteDataSource.h"
#import "FriendsCustomAutoCompleteObject.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Constants.h"

@interface MeetViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet FriendsCompleteDataSource *autoCompleteDataSource;
@property (weak) IBOutlet MLPAutoCompleteTextField *whoTextField;
@property (retain) NSString *whoName;
@property (retain) NSString *whoFbid;

@property (strong, nonatomic) IBOutlet UITextView *emotionTextView;
@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;

@property (retain, nonatomic) IBOutlet UIButton *submitButton;

@property float imgSize;
@property BOOL needsReset;

@end

@implementation MeetViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.needsReset = false;
        self.whoName = @"";
        self.whoFbid = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imgSize = 50.0;
    
    [self.whoTextField setDelegate:self];
    [self.whoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.whoTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.whoTextField setLeftView:spacerView];
    [(FriendsCompleteDataSource *) self.whoTextField.autoCompleteDataSource updateFriends];
    
    [self.whoTextField registerAutoCompleteCellClass:[CustomAutoCompleteCell class]
                              forCellReuseIdentifier:@"CustomCellId"];
    
    [self.emotionPicker setDelegate:self];
    [self.emotionPicker setDataSource:self];
    [self.view bringSubviewToFront:self.emotionPicker];
    self.emotion = [[NSString alloc] init];
    [self.emotionTextView setTextAlignment:NSTextAlignmentRight];
    [self.emotionTextView.textContainer setLineFragmentPadding:0];
    
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor blackColor].CGColor];
    [mask setFrame: CGRectMake(0, self.imgSize*1.1, self.emotionPicker.bounds.size.width, self.imgSize*1.04)];
    [self.emotionPicker.layer setMask: mask];
    
    // make a yellow rect for slider thumb img
    CGSize size = CGSizeMake(self.intensitySlider.bounds.size.height, self.intensitySlider.bounds.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), YES, 0.0);
    [[GlobalMethods globalYellowColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *fImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.intensitySlider setThumbImage:fImg forState:UIControlStateNormal];
    [self.intensitySlider setMinimumTrackImage:fImg forState:UIControlStateNormal];
    [self.intensitySlider setMaximumTrackTintColor:[GlobalMethods globalLightGrayColor]];
    
    // slider masking
    float wPad = 10;
    float hPad = 5;
    [self.intensitySlider setFrame:CGRectMake(self.intensitySlider.frame.origin.x, self.intensitySlider.frame.origin.y, self.intensitySlider.frame.size.width, self.whoTextField.frame.size.height+2*hPad)];
    
    CALayer* sliderMask = [[CALayer alloc] init];
    [sliderMask setBackgroundColor: [UIColor blackColor].CGColor];
    [sliderMask setFrame:CGRectMake(wPad, hPad, self.intensitySlider.bounds.size.width-2*wPad, self.intensitySlider.bounds.size.height-2*hPad)];
    [self.intensitySlider.layer setMask:sliderMask];
    
    // move submit button down if iphone5
    if (self.view.frame.size.height == 568) {
        CGRect frame = self.submitButton.frame;
        [self.submitButton setFrame:CGRectMake(frame.origin.x, 449, frame.size.width, frame.size.height)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needsReset) {
        [self resetForm];
        self.needsReset = false;
        // previous report filed should return to reportview screen
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

    NSMutableDictionary *event = [[HeartRateAnalyzer data] getStressEvent];
    self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:0];
    float intensity = [[event objectForKey:@"intensity"] floatValue];
    [self.intensitySlider setValue:intensity];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self updateWho];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self updateWho];
}

- (void)updateWho {
    [self.whoTextField resignFirstResponder];
    if ([self.whoTextField.text length] == 0) {
        [self setWhoName:@""];
        [self setWhoFbid:@""];
    } else {
        [self.whoTextField setText:self.whoName];
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
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.imgSize;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    NSString *text = [[[InteractionData data] emotionsArray] objectAtIndex:row];
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.imgSize, self.imgSize)];
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [text lowercaseString]]];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(0, 0, self.imgSize, self.imgSize);
    //imgView.center = imgView.superview.center;
    [newView addSubview:imgView];
    
    return newView;
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    //NSLog(@"Chosen item: %@", [[[InteractionData data] emotionsArray] objectAtIndex:row]);
    self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:row];
    
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[GlobalMethods globalFont]
                                                                forKey:NSFontAttributeName];
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[self.emotion lowercaseString] attributes:attrsDictionary];
    
    [self.emotionTextView setAttributedText:attributedString];
    [self.emotionTextView setTextAlignment:NSTextAlignmentRight];
    [self.emotionTextView.textContainer setLineFragmentPadding:0];
}

#pragma mark UI handlers

- (IBAction)submit:(id)sender {
    
    if ([self.whoName isEqualToString:@""] || [self.whoName isEqual:[NSNull null]] || !self.whoName) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Please enter a name in the yellow box."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        Person *p = [[InteractionData data] getPerson:self.whoName withFbid:self.whoFbid save:true];
        
        float val = [self.intensitySlider value];
        if (val > 0.75) {
            [[FBHandler data] requestSendWarning:p withEmotion:self.emotion];
        }
        
        // save last report date
        [[InteractionData data] saveLastReportDate:[NSDate date]];
        
        // reset form
        [self setNeedsReset:true];
        
        // go to home view
        [self.tabBarController setSelectedIndex:0];
        
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)resetForm {
    
    [self.whoTextField setText:@""];
    [self setWhoName:@""];
    [self setWhoFbid:@""];
    
    [self.emotionPicker reloadAllComponents];
    [self.emotionPicker selectRow:0 inComponent:0 animated:NO];
    [self setEmotion: [[[InteractionData data] emotionsArray] objectAtIndex:0]];
    [self.intensitySlider setValue:0.5];
    
}


#pragma mark - MLPAutoCompleteTextField Delegate

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedObject) {
        FriendsCustomAutoCompleteObject *fObj = (FriendsCustomAutoCompleteObject *)selectedObject;
        [self setWhoName:fObj.name];
        [self setWhoFbid:fObj.fbid];
        
    }
}


#pragma mark - Slider

- (IBAction)sliderValueChanged:(UISlider *)sender {
//    if (sender.value < 0.1) {
//        [sender setValue:0.1];
//    }
    if (sender.value > 0.92) {
        [sender setValue:0.92];
    }
    //NSLog(@"slider value %f", sender.value);
}

@end
