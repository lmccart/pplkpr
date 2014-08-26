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
        
        NSString *name = [entry objectAtIndex:1];
        NSString *order = [[entry objectAtIndex:2] intValue] == 0 ? [NSString stringWithFormat:@"%@", @"most"] : [NSString stringWithFormat:@"%@", @"least"];
        NSString *emotion = [entry objectAtIndex:3];
        
        
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ makes you %@ %@", name, order, [emotion lowercaseString]]];
        
        [attributedString addAttribute:@"personTag" value:name range:NSMakeRange(0,[name length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[name length])];
        
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



- (void)pushPersonViewController:(NSString *)name
{
    NSLog(@"jump to person %@", name);
	[[InteractionData data] setJumpToName:name];
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

- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
