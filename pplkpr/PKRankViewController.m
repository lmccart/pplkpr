//
//  PKRankViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 11/22/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKRankViewController.h"
#import "PKInteractionData.h"

@interface PKRankViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;

@property (nonatomic, strong) NSArray *valenceArray;
@property (retain, nonatomic) IBOutlet UIPickerView *valencePicker;
@property (retain) NSString *valence;

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
	[_emotion initWithString: [[[PKInteractionData data] emotionsArray] objectAtIndex:0]];
	NSLog(@"%@", _emotion);
	
	
	[_valencePicker setDelegate:self];
	[_valencePicker setDataSource:self];
	_valenceArray = [[NSArray alloc] initWithObjects:@"more",@"less", nil];
	[_valence initWithString: [_valenceArray objectAtIndex:0]];
	
	_rankData = [[NSDictionary alloc] init];
	[_rankView setDelegate:self];
	[_rankView setDataSource:self];
	
	[self requestData];
	
}

- (void) viewWillAppear:(BOOL)animated {
	
	if ([[PKInteractionData data] jumpToName]) {
		[self performSegueWithIdentifier:@"personSegue" sender:self];
	}
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
		_valence = [_valenceArray objectAtIndex:row];
	}
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
    static NSString *CellIdentifier = @"CountryCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if ([_rankData objectForKey:_emotion]) {
		cell.textLabel.text = [[_rankData objectForKey:_emotion] objectAtIndex:indexPath.row];
	}
    else cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *continent = [self tableView:tableView titleForHeaderInSection:indexPath.section];
//    NSString *country = [[self.countries valueForKey:continent] objectAtIndex:indexPath.row];
//	
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"You selected %@!", country] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}


- (void)requestData {
	
	
	NSArray *keys = [NSArray arrayWithObjects:@"func", @"user", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"rank", @"lauren", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	
	
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
	
	NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
	_rankData = [(NSDictionary *)jsonObject retain];
	NSLog(@"%@",_rankData);
	
	connection = nil;
    receivedData = nil;
	
	[self updateView];
	
}

- (void)updateView {
	NSLog(@"updating for key %@", _emotion);
	
	NSLog(@"%d", [[_rankData objectForKey:_emotion] count]);
	//for(id key in _rankData) {
		NSLog(@"%@", [_rankData objectForKey:_emotion]);
	//}
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
