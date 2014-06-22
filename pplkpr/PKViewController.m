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
#import "Person.h"

@interface PKViewController() {
	
	NSMutableData *receivedData;
}


@property (retain, nonatomic) NSMutableArray *priorityData;
@property (retain, nonatomic) IBOutlet UIView *priorityView;

@end


@implementation PKViewController

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
    
	//_priorityData = [[PKInteractionData data] getRankedPeople];
   // NSLog(@"%@", [[PKInteractionData data] getPriorities]);
    
    _priorityData = [[PKInteractionData data] getPriorities];
    NSArray *sortedArray = [_priorityData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 objectAtIndex:0] floatValue] > [[obj2 objectAtIndex:0] floatValue])
            return NSOrderedDescending;
        else if ([[obj1 objectAtIndex:0] floatValue] < [[obj2 objectAtIndex:0] floatValue])
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
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
        
        
        UITextView *tv = [[UITextView alloc] init];
        tv.frame = CGRectMake(0, 50*i, 100, 100);
        [tv setAttributedText:attributedString];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        [tv addGestureRecognizer:gr];
        
        [_priorityView addSubview:tv];
        [tv sizeToFit];
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
	[[PKInteractionData data] setJumpToName:name];
	[self.tabBarController setSelectedIndex:1];
}



- (void)pushRankViewController:(NSString *)emotion withOrder:(BOOL)order
{
    NSLog(@"jump to rank %d %@", order, emotion);
	[[PKInteractionData data] setJumpToEmotion:emotion];
	[[PKInteractionData data] setJumpToOrder:order];
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
        NSLog(@"%@, %d, %d", value, range.location, range.length);
        
        if (value) {
            [self pushPersonViewController:value];
        }
        
        value = [textView.attributedText attribute:@"emotionTag" atIndex:characterIndex effectiveRange:&range];
        id order = [textView.attributedText attribute:@"orderTag" atIndex:characterIndex effectiveRange:&range];
        NSLog(@"%@, %d, %d, %d", value, [order boolValue], range.location, range.length);
        
        if (value) {
            [self pushRankViewController:value withOrder:[order boolValue]];
        }
        
    }
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
