//
//  ViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "ViewController.h"
#import "MeetViewController.h"
#import "LeftViewController.h"
#import "InteractionData.h"
#import "HeartRateMonitor.h"
#import "AppDelegate.h"

@interface ViewController() {
	
	NSMutableData *receivedData;
}


@property (retain, nonatomic) NSMutableArray *priorityData;
@property (retain, nonatomic) IBOutlet UIView *priorityView;
@property (retain, nonatomic) IBOutlet UILabel *monitorStatusLabel;
@property (retain, nonatomic) NSMutableData *receivedData;
@property (retain, nonatomic) NSURLConnection *connection;

@end


@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	devicesArray = [[NSMutableArray alloc] init];
    
    [self updatePriority];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	[self updatePriority];
    
}

- (void)updatePriority
{
    
	//_priorityData = [[InteractionData data] getRankedPeople];
   // NSLog(@"%@", [[InteractionData data] getPriorities]);
    
    _priorityData = [[InteractionData data] getPriorities];
    NSArray *sortedArray = [_priorityData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectAtIndex:0] floatValue] > [[obj2 objectAtIndex:0] floatValue])
            return NSOrderedDescending;
        else if ([[obj1 objectAtIndex:0] floatValue] < [[obj2 objectAtIndex:0] floatValue])
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    float y = 0;
    for (int i=0; i < MIN(3, [sortedArray count]); i++) {
        
        // abs value, name, asc, emotion
        NSArray *entry = [sortedArray objectAtIndex:i];
        
        Person *p = [entry objectAtIndex:1];
        NSString *order = [[entry objectAtIndex:2] intValue] == 0 ? [NSString stringWithFormat:@"%@", @"most"] : [NSString stringWithFormat:@"%@", @"least"];
        NSString *emotion = [entry objectAtIndex:3];
        
        
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ makes you %@ %@", p.name, order, [emotion lowercaseString]]];
        
        [attributedString addAttribute:@"personTag" value:p range:NSMakeRange(0,[p.name length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[p.name length])];
        
        int l = [emotion length] + [order length] + 1;
        [attributedString addAttribute:@"emotionTag" value:emotion range:NSMakeRange([attributedString length]-l, l)];
        [attributedString addAttribute:@"orderTag" value:[entry objectAtIndex:2] range:NSMakeRange([attributedString length]-l, l)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange([attributedString length]-l, l)];
        
        
        UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, y, _priorityView.frame.size.width, 10)];
        [tv setAttributedText:attributedString];
        [tv setFont: [UIFont fontWithName:@"Telugu Sangam MN" size:17.0]];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        [tv addGestureRecognizer:gr];
        
        [_priorityView addSubview:tv];
        [self.view layoutIfNeeded];
        CGRect frame = tv.frame;
        frame.size.height = tv.contentSize.height;
        tv.frame = frame;
        [tv sizeToFit];
        
        y += frame.size.height + 20;
    }
    [self.view layoutIfNeeded];
}

#pragma textfield handling

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
}



- (void)pushPersonViewController:(Person *)p
{
    NSLog(@"jump to person %@", p.name);
	[[InteractionData data] setJumpToPerson:p];
	[self.tabBarController setSelectedIndex:1];
}



- (void)pushRankViewController:(NSString *)emotion withOrder:(BOOL)order
{
    NSLog(@"jump to rank %d %@", order, emotion);
	[[InteractionData data] setJumpToEmotion:emotion];
	[[InteractionData data] setJumpToOrder:order];
	[self.tabBarController setSelectedIndex:1];
}


- (void)textTapped:(UITapGestureRecognizer *)recognizer
{
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
        id value = [textView.attributedText attribute:@"personTag" atIndex:characterIndex effectiveRange:&range];
        //NSLog(@"%@, %d, %d", value, range.location, range.length);
        
        if (value) {
            [self pushPersonViewController:value];
        }
        
        value = [textView.attributedText attribute:@"emotionTag" atIndex:characterIndex effectiveRange:&range];
        id order = [textView.attributedText attribute:@"orderTag" atIndex:characterIndex effectiveRange:&range];
        //NSLog(@"%@, %d, %d, %d", value, [order boolValue], range.location, range.length);
        
        if (value) {
            [self pushRankViewController:value withOrder:[order boolValue]];
        }
        
    }
}

- (void)updateMonitorStatus:(NSString *)status {
    [_monitorStatusLabel setText:status];
    if ([status isEqual: @"connecting"]) {
        [_monitorStatusLabel setTextColor:[UIColor orangeColor]];
    } else if ([status isEqual:@"connected"]) {
        [_monitorStatusLabel setTextColor:[UIColor greenColor]];
    } else {
        [_monitorStatusLabel setTextColor:[UIColor redColor]];
    }
}

- (IBAction)testRequest:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"https://server.pplkpr.com:3000/post"];
    NSString *myRequestString = [NSString stringWithFormat:@"email=%@&password=%@&message=%@&id=%@",
                         @"laurmccarthy@gmail.com",
                         @"xxxx",
                         @"this_is_a_test_6",
                         @"lmccart"];

    NSURL *url = [NSURL URLWithString:urlString];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
//                                                       timeoutInterval:10];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[myRequestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.receivedData = [NSMutableData dataWithCapacity: 0];
    self.connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!self.connection) {
        // Release the receivedData object.
        self.receivedData = nil;
        
        // Inform the user that the connection failed.
        NSLog(@"connection failed");
    }

//    
//    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"RETURNED:%@",returnString);

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    self.connection = nil;
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a property elsewhere
    NSLog(@"Succeeded! Received %d bytes of data", [self.receivedData length]);
    NSString *returnString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"RETURNED:%@",returnString);
    
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    self.connection = nil;
    self.receivedData = nil;
}

@end
