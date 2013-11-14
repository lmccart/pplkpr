//
//  PKLeftOverallViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKLeftOverallViewController.h"
#import "PKInteractionData.h"


@interface PKLeftOverallViewController () {
	
	NSMutableData *receivedData;
}
	

@property (retain, nonatomic) IBOutlet UILabel *personNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *overallField;
@property (retain, nonatomic) IBOutlet UISlider *overallSlider;

@end



@implementation PKLeftOverallViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[_personNameLabel setText:[[PKInteractionData data] personName]];
	
	[_overallField setDelegate:self];
	[_overallField setClearButtonMode:UITextFieldViewModeWhileEditing];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {

	
	NSArray *keys = [NSArray arrayWithObjects:@"func", @"user", @"name", @"emotion", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"interaction", @"lauren", [[PKInteractionData data] personName], [[PKInteractionData data] emotion], nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];

	
	NSLog(@"emotion is %@", [[PKInteractionData data] emotion]);
	
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

	connection = nil;
    receivedData = nil;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"return\n");
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_overallField resignFirstResponder];
	[super touchesBegan:touches withEvent:event];
}


- (void)viewDidUnload {
	_personNameLabel = nil;
	_overallField = nil;
	_overallSlider = nil;
	[super viewDidUnload];
}

- (void)dealloc {
	[_personNameLabel release];
	[_overallField release];
	[_overallSlider release];
	[super dealloc];
}

@end
