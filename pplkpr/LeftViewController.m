//
//  LeftViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "LeftViewController.h"
#import "InteractionData.h"
#import "Report.h"
#import "HeartRateAnalyzer.h"
#import "MLPAutoCompleteTextField.h"
#import "CustomAutoCompleteCell.h"
#import "FriendsCompleteDataSource.h"
#import "FriendsCustomAutoCompleteObject.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Constants.h"

@interface LeftViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet FriendsCompleteDataSource *autoCompleteDataSource;
@property (weak) IBOutlet MLPAutoCompleteTextField *whoTextField;
@property (retain) NSString *whoName;
@property (retain) NSString *whoNumber;

@property (strong, nonatomic) IBOutlet UITextView *emotionTextView;
@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;
@property (retain, nonatomic) IBOutlet UIImageView *upArrow;
@property (retain, nonatomic) IBOutlet UIImageView *downArrow;

@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;
@property float imgSize;

@property UIImage *halfImg;
@property UIImage *yellowImg;
@property UIImage *grayImg;

@property BOOL needsReset;

@property (retain, nonatomic) IBOutlet UISlider *timeSlider;
@property (retain, nonatomic) NSDate *rangeStart;
@property (retain, nonatomic) NSDate *rangeEnd;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@property (retain, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation LeftViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.needsReset = false;
        self.whoName = @"";
        self.whoNumber = @"";
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
    
    // make a yellow rect for slider imgs
    float thumbSize = self.intensitySlider.bounds.size.height;
    CGSize size = CGSizeMake(thumbSize, thumbSize);
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [[GlobalMethods globalLightGrayColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    [[GlobalMethods globalYellowColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width / 2, size.height));
    self.halfImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [[GlobalMethods globalYellowColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    self.yellowImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [[GlobalMethods globalLightGrayColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    self.grayImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // style time slider
    [self.timeSlider setThumbImage:self.halfImg forState:UIControlStateNormal];
    [self.timeSlider setMinimumTrackImage:self.yellowImg forState:UIControlStateNormal];
    [self.timeSlider setMaximumTrackImage:self.grayImg forState:UIControlStateNormal];
    
    // style intensity slider
    [self.intensitySlider setThumbImage:self.halfImg forState:UIControlStateNormal];
    [self.intensitySlider setMinimumTrackImage:self.yellowImg forState:UIControlStateNormal];
    [self.intensitySlider setMaximumTrackImage:self.grayImg forState:UIControlStateNormal];
    
    // slider masking
    float wPad = 2;
    float hPad = 0;
    float h = self.whoTextField.frame.size.height;
    
    [self.intensitySlider setFrame:CGRectMake(self.intensitySlider.frame.origin.x, self.intensitySlider.frame.origin.y, self.intensitySlider.frame.size.width, h+2*hPad)];
    CALayer* iSliderMask = [[CALayer alloc] init];
    [iSliderMask setBackgroundColor: [UIColor blackColor].CGColor];
    [iSliderMask setFrame:CGRectMake(wPad, hPad, self.intensitySlider.bounds.size.width-2*wPad, self.intensitySlider.bounds.size.height-2*hPad)];
    [self.intensitySlider.layer setMask:iSliderMask];
    
    [self.timeSlider setFrame:CGRectMake(self.timeSlider.frame.origin.x, self.timeSlider.frame.origin.y, self.timeSlider.frame.size.width, h+2*hPad)];
    CALayer* tSliderMask = [[CALayer alloc] init];
    [tSliderMask setBackgroundColor: [UIColor blackColor].CGColor];
    [tSliderMask setFrame:CGRectMake(wPad, hPad, self.timeSlider.bounds.size.width-2*wPad, self.timeSlider.bounds.size.height-2*hPad)];
    [self.timeSlider.layer setMask:tSliderMask];
    
    // move submit button down if iphone5
    if (self.view.frame.size.height >= 568) {
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

    [self.timeSlider setValue:-30]; // set 30 mins ago
    self.rangeEnd = [NSDate date];
    self.rangeStart = [self.rangeEnd dateByAddingTimeInterval:-2*60*60];
    [self updateTimeSlider];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"%@", self.whoTextField.text);
    [textField resignFirstResponder];
    [self updateWho:true];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
    [self updateWho:true];
}

- (void)updateWho:(BOOL)manual {
    [self.whoTextField resignFirstResponder];
    if ([self.whoTextField.text length] == 0) {
        [self setWhoName:@""];
        [self setWhoNumber:@""];
    } else {
        if (manual) {
            [self setWhoName:self.whoTextField.text];
        } else {
            [self.whoTextField setText:self.whoName];
        }
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
    
    if (row == 0) {
        [self.upArrow setHidden:true];
    } else {
        [self.upArrow setHidden:false];
    }
    
    if (row == [[[InteractionData data] emotionsArray] count]-1) {
        [self.downArrow setHidden:true];
    } else {
        [self.downArrow setHidden:false];
    }
    
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

//- (void)fillTextBoxAndDismiss:(NSString *)text {
//    //self.whoTextField.text = text;
//	[self toggleFormView];
//    [self dismissViewControllerAnimated:NO completion:nil];
//}


- (IBAction)submit:(id)sender {
	
    if ([self.whoName isEqualToString:@""] || [self.whoName isEqual:[NSNull null]] || !self.whoName) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Please enter a name in the yellow box."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        float val = [self.intensitySlider value];
        float timeVal = [self.timeSlider value];
        NSDate *date = [self.rangeEnd dateByAddingTimeInterval:timeVal*60];
        Report *r = [[InteractionData data] addReport:self.whoName
                                             withNumber:self.whoNumber
                                          withEmotion:self.emotion
                                           withRating:[NSNumber numberWithFloat:val]
                                             withDate:date];
        
        //[[FBHandler data] logData:[r toString] withTag:@"report" withCompletion:nil];
        [self sendReport:self.whoName withNumber:self.whoNumber withEmotion:self.emotion withValue:val];
        
        // save last report date
        [[InteractionData data] saveLastReportDate:[NSDate date]];
        
        // reset form
        [self setNeedsReset:true];
        
        // go to person view
        [[InteractionData data] setJumpToPerson:r.person];
        [self.tabBarController setSelectedIndex:1];
    }
}


- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)resetForm {
    
    [self.whoTextField setText:@""];
    [self setWhoName:@""];
    [self setWhoNumber:@""];
    
	[self.emotionPicker reloadAllComponents];
	[self.emotionPicker selectRow:0 inComponent:0 animated:NO];
    [self setEmotion: [[[InteractionData data] emotionsArray] objectAtIndex:0]];
	[self.intensitySlider setValue:0.5];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	
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
        [self setWhoNumber:fObj.number];
        
    }
}

#pragma mark - Slider

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if(sender.value == sender.maximumValue) {
        [sender setThumbImage:self.yellowImg forState:UIControlStateNormal];
    } else if(sender.value == sender.minimumValue) {
        [sender setThumbImage:self.grayImg forState:UIControlStateNormal];
    } else {
        [sender setThumbImage:self.halfImg forState:UIControlStateNormal];
    }
    if ([sender isEqual:self.timeSlider]) {
        [self updateTimeSlider];
    }
}

- (void)updateTimeSlider {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH:mm"];
    }
    float timeVal = [self.timeSlider value];
    NSDate *date = [self.rangeEnd dateByAddingTimeInterval:timeVal*60];
    [self.timeLabel setText:[self.dateFormatter stringFromDate:date]];
}


- (void)sendReport:(NSString *)name withNumber:(NSString *)number withEmotion:(NSString *)emotion withValue:(float)value {
    
    CLLocation *location = [[InteractionData data] lastLoc];
    float lat = location ? location.coordinate.latitude : 0;
    float lon = location ? location.coordinate.longitude : 0;
    
    NSString *urlString = [NSString stringWithFormat:@"https://pplkpr-node-server.herokuapp.com/add_report?name=%@&number=%@&emotion=%@&value=%f&lat=%f&lon=%f", name, number, emotion, value, lat, lon];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"URL %@", urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) { NSLog(@"error: %@", error); }
                           }];
}



@end
