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
@property (retain, nonatomic) IBOutlet UIView *whoRecentView;
@property (retain, nonatomic) NSArray *recentPeople;

@property (strong, nonatomic) IBOutlet UITextView *emotionTextView;
@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;
@property float imgSize;

@property BOOL needsReset;

@end

@implementation MeetViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"initing\n");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"init\n");
        self.needsReset = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imgSize = 50.0;
    
    [self.whoTextField setDelegate:self];
    [self.whoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
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
 
    NSArray *subviews = [self.whoRecentView subviews];
    
    for (int i=0; i<[subviews count]; i++) {
        [((UIImageView *)subviews[i]).layer setBorderColor: [[UIColor blackColor] CGColor]];
        [((UIImageView *)subviews[i]).layer setBorderWidth: 1.0];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbTapped:)];
        [subviews[i] addGestureRecognizer:gr];
        [subviews[i] setTag:i];
    }
    
    // Build a triangular path
    float w = self.intensitySlider.frame.size.width;
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:(CGPoint){0.25*w, 43}];
    [path addLineToPoint:(CGPoint){0.75*w, 43}];
    [path addLineToPoint:(CGPoint){0.75*w, 7}];
    [path addLineToPoint:(CGPoint){0.25*w, 43}];
    
    // Create a CAShapeLayer with this triangular path
    // Same size as the original imageView
    CAShapeLayer *sliderMask = [CAShapeLayer new];
    sliderMask.frame = self.intensitySlider.bounds;
    sliderMask.path = path.CGPath;
    
    // Mask the imageView's layer with this shape
    [self.intensitySlider.layer setMask:sliderMask];
    [self.intensitySlider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    [self.intensitySlider setMinimumTrackTintColor:[GlobalMethods globalYellowColor]];
    [self.intensitySlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.intensitySlider setFrame:CGRectMake(self.intensitySlider.frame.origin.x, self.intensitySlider.frame.origin.y, w, 50)];
    
    float h = self.intensitySlider.frame.size.height;
    float x = self.intensitySlider.frame.origin.x;
    float y = self.intensitySlider.frame.origin.y;
    
    UIBezierPath *sliderPath = [UIBezierPath bezierPath];
    [sliderPath moveToPoint:CGPointMake(x+0.25*w, y+h-7)];
    [sliderPath addLineToPoint:CGPointMake(x+0.75*w, y+h-7)];
    [sliderPath addLineToPoint:CGPointMake(x+0.75*w, y+h-43)];
    [sliderPath addLineToPoint:CGPointMake(x+0.25*w, y+h-7)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [sliderPath CGPath];
    shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.needsReset) {
        [self resetForm];
        self.needsReset = false;
        // previous report filed should return to reportview screen
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    // shortcut thumbs
    self.recentPeople = [[InteractionData data] getRecentPeople];
    NSArray *subviews = [self.whoRecentView subviews];
    
    for (int i=0; i<[subviews count]; i++) {
        if (i<[self.recentPeople count]) {
            
            Person *p = self.recentPeople[i];
            
            [[FBHandler data] requestProfilePic:p.fbid  withType:@"square" withCompletion:^(NSDictionary * result){
                NSDictionary *pic = [result objectForKey:@"picture"];
                NSDictionary *data = [pic objectForKey:@"data"];
                NSString *url = [data objectForKey:@"url"];
                [subviews[i] sd_setImageWithURL:[NSURL URLWithString:url]];
            }];
            
            [subviews[i] setHidden:NO];
        } else {
            [subviews[i] setHidden:YES];
        }
    }
    
    
    NSMutableDictionary *event = [[HeartRateAnalyzer data] getHRVEvent];
    self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:0];
    [self.intensitySlider setValue:[[event objectForKey:@"intensity"] floatValue]];
    
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
        [self.whoRecentView setHidden:false];
    } else {
        [self.whoTextField setText:self.whoName];
        [self.whoRecentView setHidden:true];
    }
}

- (void)thumbTapped:(UITapGestureRecognizer *)recognizer {
    UIImageView *iv = (UIImageView *)recognizer.view;
    if (iv.tag < [self.recentPeople count]) {
        Person *p = [self.recentPeople objectAtIndex:iv.tag];
        [self setWhoName:p.name];
        [self setWhoFbid:p.fbid];
        [self.whoTextField setText:p.name];
        [self.whoRecentView setHidden:true];
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
    NSLog(@"Chosen item: %@", [[[InteractionData data] emotionsArray] objectAtIndex:row]);
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
    
    if ([self.whoName isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                        message:@"Please enter a name in the yellow box."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        Person *p = [[InteractionData data] getPerson:self.whoName withFbid:self.whoFbid save:true];
        [[FBHandler data] requestSendWarning:p withEmotion:self.emotion];
        
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
    [self.whoRecentView setHidden:false];
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
        [self.whoRecentView setHidden:true];
        
    }
}

#pragma mark - Slider Delegate

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (sender.value < 0.25) {
        [sender setValue:0.25];
    } else if (sender.value > 0.75) {
        [sender setValue:0.75];
    }
}

@end
