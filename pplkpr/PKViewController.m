//
//  PKViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKViewController.h"
#import "PKMeetViewController.h"
#import "PKLeftViewController.h"
#import "PKInteractionData.h"

@interface PKViewController() <UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}


@property (retain, nonatomic) NSArray *priorityData;
@property (retain, nonatomic) IBOutlet UITableView *priorityView;


@end




@implementation PKViewController



- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_priorityData = [[NSArray alloc] init];
	[_priorityView setDelegate:self];
    [_priorityView setDataSource:self];
	
	[self requestData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (_priorityData) {
		return 1;
	}
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"NOTIFICATIONS";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_priorityData) {
		return [_priorityData count];
	} else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"priority_cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ makes you most %@", [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0], [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:1]];
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	NSLog(@"%d %@", indexPath.row, [_priorityData objectAtIndex:indexPath.row]);
	
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
	
	
	[self pushPersonViewController:[_priorityData objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [NSString stringWithFormat:@"%@ makes you most %@", [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0], [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:1]];

	NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
	
	CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
											   options:NSStringDrawingUsesLineFragmentOrigin
											   context:nil];
    return rect.size.height+25;

}


- (void)requestData {
	
	NSArray *keys = [NSArray arrayWithObjects:@"func", @"user", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"priority", @"lauren", nil];
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
	
	NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
	_priorityData = [(NSArray *)jsonObject retain];
	NSLog(@"%@ %d",_priorityData, [_priorityData count]);
	
	connection = nil;
    receivedData = nil;
	
	[self updateView];
	
}

- (void)updateView {
	[_priorityView reloadData];
}


- (void)pushPersonViewController:(NSString *)name
{
	[[PKInteractionData data] setJumpToName:[[PKInteractionData data] name]];
	[self.tabBarController setSelectedIndex:1];
}



- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

@end
