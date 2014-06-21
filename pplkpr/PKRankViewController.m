//
//  PKRankViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/22/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKRankViewController.h"
#import "PKInteractionData.h"
#import "Person.h"

@interface PKRankViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (nonatomic, strong) NSArray *valenceArray;
@property (retain, nonatomic) IBOutlet UIPickerView *valencePicker;
@property BOOL valence; // 0-more-desc, 1-less-asc

@property (retain, nonatomic) NSDictionary *rankData;
@property (retain, nonatomic) IBOutlet UITableView *rankView;

@end

@implementation PKRankViewController

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

	[_emotionPicker setDelegate:self];
	[_emotionPicker setDataSource:self];
    _emotion = [[[PKInteractionData data] emotionsArray] objectAtIndex:0];
	
	[_valencePicker setDelegate:self];
	[_valencePicker setDataSource:self];
	_valenceArray = [[NSArray alloc] initWithObjects:@"more",@"less", nil];
	_valence = NO;
	
	_rankData = [[NSDictionary alloc] init];
	[_rankView setDelegate:self];
	[_rankView setDataSource:self];
	[_rankView reloadData];
	
	
}

- (void) viewWillAppear:(BOOL)animated {
	
	if ([[PKInteractionData data] jumpToName]) {
		[self performSegueWithIdentifier:@"personSegue" sender:self];
	} else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        if ([[PKInteractionData data] jumpToEmotion]) {
            _emotion = [[PKInteractionData data] jumpToEmotion];
            int d = [[[PKInteractionData data] emotionsArray] indexOfObject:_emotion];
            [_emotionPicker selectRow:d inComponent:0 animated:NO];
            [[PKInteractionData data] setJumpToEmotion:nil];
        }
        if ([[PKInteractionData data] jumpToValence]) {
            _valence = [[PKInteractionData data] jumpToValence];
            [_valencePicker selectRow:_valence inComponent:0 animated:NO];
            [[PKInteractionData data] setJumpToValence:0];
        }
    }
	_rankData = [[PKInteractionData data] getRankedPeople];
    
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
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (pickerView == _emotionPicker) {
		return [[[PKInteractionData data] emotionsArray] count];
	} else {
		return [_valenceArray count];
	}
}


#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (pickerView == _emotionPicker) {
		return [[[PKInteractionData data] emotionsArray] objectAtIndex:row];
	} else {
		return [_valenceArray objectAtIndex:row];
	}
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == _emotionPicker) {
		//Let's print in the console what the user had chosen;
		NSLog(@"Chosen item: %@", [[[PKInteractionData data] emotionsArray] objectAtIndex:row]);
		_emotion = [[[PKInteractionData data] emotionsArray] objectAtIndex:row];
	} else {
		NSLog(@"Chosen item: %@", [_valenceArray objectAtIndex:row]);
		_valence = (BOOL)row;
	}
	NSLog(@"order %d emotion %@", _valence, _emotion);
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if ([_rankData objectForKey:_emotion]) {
		// walk from bottom or top based on valence
		int ind = (_valence) ? [[_rankData objectForKey:_emotion] count] - indexPath.row - 1 : indexPath.row;
		Person *p = [[_rankData objectForKey:_emotion] objectAtIndex:ind];
		
		SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@", [_emotion lowercaseString]]);
		NSNumber *val = [p performSelector:sel];
		cell.textLabel.text = [NSString stringWithFormat:@"%@ ~ %@", p.name, val];
	}
    else cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int ind = (_valence) ? [[_rankData objectForKey:_emotion] count] - indexPath.row - 1 : indexPath.row;
	[[PKInteractionData data] setJumpToName:[[_rankData objectForKey:_emotion] objectAtIndex:ind]];
	[self performSegueWithIdentifier:@"personSegue" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)updateView {
	NSLog(@"updating for key %@ order %d", _emotion, _valence);
	
	//NSLog(@"%d", [[_rankData objectForKey:_emotion] count]);
	//NSLog(@"%@", [_rankData objectForKey:_emotion]);
	
	[_rankView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	_emotionPicker = nil;
	_emotion = nil;
	_rankData = nil;
}

- (void)dealloc {
	[_emotionPicker release];
	[_emotion release];
	[_rankData release];
	[super dealloc];
}
@end
