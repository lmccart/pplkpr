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


@property (retain, nonatomic) NSMutableDictionary *priorityData;
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
	_priorityData = [[PKInteractionData data] getRankedPeople];
    for (int i=0; i < MIN(3, [[_priorityData allKeys] count]); i++) {
        
        NSString *emotion = [[_priorityData allKeys] objectAtIndex:i];
        NSArray *emo_arr = (NSArray *)[_priorityData objectForKey:emotion];
        Person *person = [emo_arr objectAtIndex:0];
        NSLog(@"%d %@", i, person.name);
        
        
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ makes you most %@", person.name, emotion]];
        
        [attributedString addAttribute:@"personTag" value:person.name range:NSMakeRange(0,[person.name length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[person.name length])];
        
        [attributedString addAttribute:@"emotionTag" value:emotion range:NSMakeRange([attributedString length] - [emotion length]-1,[emotion length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange([attributedString length] - [emotion length],[emotion length])];
        
        
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



- (void)pushRankViewController:(NSString *)emotion
{
    NSLog(@"jump to rank %@", emotion);
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
        NSLog(@"%@, %d, %d", value, range.location, range.length);
        
        if (value) {
            [self pushRankViewController:value];
        }
        
    }
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

@end
