//
//  RankViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/22/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "RankViewController.h"
#import "InteractionData.h"
#import "Person.h"

@interface RankViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (nonatomic, strong) NSArray *orderArray;
@property (retain, nonatomic) IBOutlet UIPickerView *orderPicker;
@property BOOL order; // 0-more-desc, 1-less-asc

@property (retain, nonatomic) NSDictionary *rankData;
@property (retain, nonatomic) IBOutlet UITableView *rankView;

@end

@implementation RankViewController

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
    _emotion = [[[InteractionData data] emotionsArray] objectAtIndex:0];
	
	[_orderPicker setDelegate:self];
	[_orderPicker setDataSource:self];
	_orderArray = [[NSArray alloc] initWithObjects:@"more",@"less", nil];
	_order = NO;
	
	_rankData = [[NSDictionary alloc] init];
	[_rankView setDelegate:self];
	[_rankView setDataSource:self];
	[_rankView reloadData];
	
	
}

- (void) viewDidAppear:(BOOL)animated {
	
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
        [_orderPicker selectRow:_order inComponent:0 animated:NO];
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
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (pickerView == _emotionPicker) {
		return [[[InteractionData data] emotionsArray] count];
	} else {
		return [_orderArray count];
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
		return [[[InteractionData data] emotionsArray] objectAtIndex:row];
	} else {
		return [_orderArray objectAtIndex:row];
	}
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == _emotionPicker) {
		//Let's print in the console what the user had chosen;
		NSLog(@"Chosen item: %@", [[[InteractionData data] emotionsArray] objectAtIndex:row]);
		_emotion = [[[InteractionData data] emotionsArray] objectAtIndex:row];
	} else {
		NSLog(@"Chosen item: %@", [_orderArray objectAtIndex:row]);
		_order = (BOOL)row;
	}
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
	
	[_rankView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	_emotionPicker = nil;
	_emotion = nil;
	_rankData = nil;
}

@end
