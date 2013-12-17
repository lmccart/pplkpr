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
#import "PKAppDelegate.h"
#import "Report.h"

@interface PKViewController() <UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}


@property (retain, nonatomic) NSArray *priorityData;
@property (retain, nonatomic) IBOutlet UITableView *priorityView;

@property (nonatomic,strong) NSArray* fetchedReportsArray;
@property (retain, nonatomic) IBOutlet UITableView *reportsView;

@end


@implementation PKViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	devicesArray = [[NSMutableArray alloc] init];
	
	_priorityData = [[NSArray alloc] init];
	[_priorityView setDelegate:self];
    [_priorityView setDataSource:self];
	
	_fetchedReportsArray = [[PKInteractionData data] getAllReports];
	[_reportsView setDelegate:self];
    [_reportsView setDataSource:self];
	[_reportsView reloadData];
	
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
	_fetchedReportsArray = [[PKInteractionData data] getAllReports];
	[_reportsView reloadData];
}

#pragma textfield handling

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
}


#pragma table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == _priorityView) {
		if (_priorityData) {
			return 1;
		}
		else return 0;
	} else if (tableView == _reportsView && [_fetchedReportsArray count] > 0) {
		return 1;
	} else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"NOTIFICATIONS";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == _priorityView) {
		if (_priorityData) {
			return [_priorityData count];
		} else return 0;
	} else if (tableView == _reportsView) {
		return [_fetchedReportsArray count];
	} else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *cellIdentifier = @"cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	
	if (tableView == _priorityView) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ makes you most %@", [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0], [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:1]];
	} else if (tableView == _reportsView) {
		Report * report = [self.fetchedReportsArray objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@",report.name, report.emotion, report.rating];
	}
	
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == _priorityView) {
		[self pushPersonViewController:[[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0]];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == _priorityView) {
		NSString *text = [NSString stringWithFormat:@"%@ makes you most %@", [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0], [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:1]];

		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
		
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
												   options:NSStringDrawingUsesLineFragmentOrigin
												   context:nil];
		return rect.size.height+25;
	} else if (tableView == _reportsView) {
		NSString *text = [[_fetchedReportsArray objectAtIndex:indexPath.row] name];
		
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
		
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
												   options:NSStringDrawingUsesLineFragmentOrigin
												   context:nil];
		return rect.size.height+25;
	}
	else return 0;
}



#pragma data / view handling

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
	[[PKInteractionData data] setJumpToName:name];
	[self.tabBarController setSelectedIndex:1];
}



- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

@end
