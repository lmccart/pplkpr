//
//  MeetViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "MeetViewController.h"
#import "InteractionData.h"
#import "TempHRV.h"
#import "FBHandler.h"
#import "MLPAutoCompleteTextField.h"
#import "CustomAutoCompleteCell.h"
#import "FriendsCompleteDataSource.h"
#import "FriendsCustomAutoCompleteObject.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface MeetViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	NSMutableData *receivedData;
}


@property (strong, nonatomic) IBOutlet FriendsCompleteDataSource *autocompleteDataSource;
@property (weak) IBOutlet MLPAutoCompleteTextField *whoTextField;
@property (strong) NSString *whoName;
@property (strong) NSString *whoFbid;
@property (strong, nonatomic) IBOutlet UIView *whoRecentView;

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (strong) NSString *emotion;

@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;


@end

@implementation MeetViewController

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
	
	[self.whoTextField setDelegate:self];
    [self.whoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [(FriendsCompleteDataSource *) self.whoTextField.autoCompleteDataSource updateFriends];
    
    [self.whoTextField registerAutoCompleteCellClass:[CustomAutoCompleteCell class]
                                       forCellReuseIdentifier:@"CustomCellId"];
	
    [self.emotionPicker setDelegate:self];
    [self.emotionPicker setDataSource:self];
	self.emotion = [[NSString alloc] init];
    
    NSArray *recents = [[InteractionData data] getRecentPeople];
    NSArray *subviews = [self.whoRecentView subviews];
    
    int i=0;
    for (Person *p in recents) {
        if (i<5) {
            
            [[FBHandler data] requestProfile:p.fbid withCompletion:^(NSDictionary * result){
                NSDictionary *pic = [result objectForKey:@"picture"];
                NSDictionary *data = [pic objectForKey:@"data"];
                NSString *url = [data objectForKey:@"url"];
                
                [subviews[i] sd_setImageWithURL:[NSURL URLWithString:url]];
            }];
            i++;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSMutableDictionary *event = [[TempHRV data] getHRVEvent];
	self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:0];
    [self.intensitySlider setValue:[[event objectForKey:@"intensity"] floatValue]];
    

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.whoTextField resignFirstResponder];
    if ([self.whoTextField.text length] == 0) {
        [self setWhoName:@""];
        [self setWhoFbid:@""];
    } else {
        [self.whoTextField setText:self.whoName];
    }
	[super touchesBegan:touches withEvent:event];
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

//- (void)fillTextBoxAndDismiss:(NSString *)text {
//    //self.whoTextField.text = text;
//	[self toggleFormView];
//    [self dismissViewControllerAnimated:NO completion:nil];
//}


- (IBAction)submit:(id)sender {
	
	Person *p = [[InteractionData data] addReport:self.whoName withFbid:self.whoFbid withEmotion:self.emotion withRating:[NSNumber numberWithFloat:[self.intensitySlider value]]];
    
	// go to person view
	[[InteractionData data] setJumpToPerson:p];
	[self.tabBarController setSelectedIndex:1];
    
    // reset form
	[self resetForm];
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
        [self setWhoFbid:fObj.fbid];
        
    }
}

@end
