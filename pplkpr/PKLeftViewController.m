//
//  PKLeftViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKLeftViewController.h"
#import "PKInteractionData.h"

@interface PKLeftViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (retain) NSString *emotion;
@property (retain, nonatomic) IBOutlet UISlider *intensitySlider;


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
	
    [_emotionPicker setDelegate:self];
    [_emotionPicker setDataSource:self];
	_emotion = [[NSString alloc] init];
	
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)pushOverallViewController
{
	[[PKInteractionData data] setJumpToName:[[PKInteractionData data] personName]];
	[self.tabBarController setSelectedIndex:1];
}


- (IBAction)submit:(id)sender {
	
	NSLog(@"%@ %@", [[PKInteractionData data] emotion] , [[PKInteractionData data] personName]);
	
	NSArray *keys = [NSArray arrayWithObjects:@"func", @"user", @"name", @"emotion",@"intensity", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"interaction", @"lauren", [[PKInteractionData data] personName], _emotion, [NSNumber numberWithFloat:[_intensitySlider value]], nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	
	
	NSLog(@"emotion is %@", _emotion);
	
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
	//	NSString *responeString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
	NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
	NSLog(@"%@",jsonDictionary);
	
	[[PKInteractionData data] setSummary:jsonDictionary];
	
	connection = nil;
    receivedData = nil;
	
	[self pushOverallViewController];
	
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	
	_emotionPicker = nil;
	_emotion = nil;
	_intensitySlider = nil;
	[super viewDidUnload];
}

- (void)dealloc {
	[_emotionPicker release];
	[_emotion release];
	[_intensitySlider release];
	[super dealloc];
}
@end
