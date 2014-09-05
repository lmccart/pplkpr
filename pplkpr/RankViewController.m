//
//  RankViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/22/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "RankViewController.h"
#import "Constants.h"
#import "InteractionData.h"
#import "Person.h"

@interface RankViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (retain, nonatomic) IBOutlet UITextView *descriptorView;
@property BOOL order; // 0-more-desc, 1-less-asc

@property (retain, nonatomic) NSDictionary *rankData;
@property (retain, nonatomic) IBOutlet UITableView *rankView;

@end

@implementation RankViewController

float imgSize = 50.0;

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

	[self.emotionPicker setDelegate:self];
	[self.emotionPicker setDataSource:self];
    self.emotion = [[[InteractionData data] emotionsArray] objectAtIndex:0];
    
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor blackColor].CGColor];
    [mask setFrame: CGRectMake(0, imgSize*1.1, self.emotionPicker.bounds.size.width, imgSize*1.04)];
    [self.emotionPicker.layer setMask: mask];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [self.descriptorView addGestureRecognizer:gr];
    
	self.rankData = [[NSDictionary alloc] init];
	[self.rankView setDelegate:self];
	[self.rankView setDataSource:self];
	
    [self updateView];
	
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
	if ([[InteractionData data] jumpToPerson]) {
		[self performSegueWithIdentifier:@"personSegue" sender:self];
	} else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        if ([[InteractionData data] jumpToEmotion]) {
            _emotion = [[InteractionData data] jumpToEmotion];
            NSLog(@"emotion in view will appear %@", _emotion);
            int d = [[[InteractionData data] emotionsArray] indexOfObject:_emotion];
            [_emotionPicker selectRow:d inComponent:0 animated:NO];
            [[InteractionData data] setJumpToEmotion:nil];
        }
        _order = [[InteractionData data] jumpToOrder];
        [[InteractionData data] setJumpToOrder:NO];
        
    }
	_rankData = [[InteractionData data] getRankedPeople];
    
	[self updateView];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"return\n");
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//[_descriptionField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}


#pragma mark - UIPickerView DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[[InteractionData data] emotionsArray] count];
}


#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return imgSize;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//	if (pickerView == _emotionPicker) {
//		return [[[InteractionData data] emotionsArray] objectAtIndex:row];
//	} else {
//		return [_orderArray objectAtIndex:row];
//	}
//}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    NSString *text = [[[InteractionData data] emotionsArray] objectAtIndex:row];
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgSize, imgSize)];
    
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [text lowercaseString]]];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(0, 0, imgSize, imgSize);
    //imgView.center = imgView.superview.center;
    [newView addSubview:imgView];
    
    return newView;
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    NSLog(@"Chosen item: %@", [[[InteractionData data] emotionsArray] objectAtIndex:row]);
    _emotion = [[[InteractionData data] emotionsArray] objectAtIndex:row];
	NSLog(@"order %d emotion %@", _order, _emotion);
	[self updateView];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([_rankData objectForKey:_emotion]) {
		return 1;
	}
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"ppl";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_rankData objectForKey:_emotion]) {
		return [[_rankData objectForKey:_emotion] count];
	}
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rankCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	if ([_rankData objectForKey:_emotion]) {
		// walk from bottom or top based on order
		int ind = (_order) ? [[_rankData objectForKey:_emotion] count] - indexPath.row - 1 : indexPath.row;
		Person *p = [[_rankData objectForKey:_emotion] objectAtIndex:ind];
        NSNumber *val = [p valueForKey:[_emotion lowercaseString]];
        
		cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@", [p valueForKey:@"name"], val];
	}
    else cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int ind = (_order) ? [[_rankData objectForKey:_emotion] count] - indexPath.row - 1 : indexPath.row;
    NSLog(@"select ind %d", ind);
    Person *p = [[_rankData objectForKey:_emotion] objectAtIndex:ind];
    NSLog(@"select name %@", p.name);
	[[InteractionData data] setJumpToPerson:p];
	[self performSegueWithIdentifier:@"personSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)updateView {
	//NSLog(@"updating for key %@ order %d", _emotion, _order);
	//NSLog(@"%d", [[_rankData objectForKey:_emotion] count]);
	//NSLog(@"%@", [_rankData objectForKey:_emotion]);
	
	[self.rankView reloadData];
    [self updateDescriptor];
}

- (void)updateDescriptor {
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[GlobalMethods globalFont]
                                                                forKey:NSFontAttributeName];
    NSString *chosen = self.order ? @"less" : @"more";
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", chosen, [self.emotion lowercaseString]] attributes:attrsDictionary];
    
    [attributedString addAttribute:@"orderTag" value:@"" range:NSMakeRange(0,[chosen length])];
    [attributedString addAttribute:NSFontAttributeName value:[GlobalMethods globalBoldFont] range:NSMakeRange(0,[chosen length])];
    
    [self.descriptorView setAttributedText:attributedString];
}



- (void)textTapped:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"tap");
    UITextView *textView = (UITextView *)recognizer.view;
    
    // Location of the tap in text-container coordinates
    
    NSLayoutManager *layoutManager = [textView layoutManager];
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    
    // Find the character that's been tapped on
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        
        NSRange range;
        id value = [textView.attributedText attribute:@"orderTag" atIndex:characterIndex effectiveRange:&range];
        //NSLog(@"%@, %d, %d", value, range.location, range.length);
        
        if (value) {
            [self setOrder:!self.order];
            [self updateView];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	_emotionPicker = nil;
	_emotion = nil;
	_rankData = nil;
}

@end
