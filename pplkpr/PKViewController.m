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

@interface PKViewController() <UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}


@property (retain, nonatomic) NSMutableDictionary *priorityData;
@property (retain, nonatomic) IBOutlet UITableView *priorityView;

@end


@implementation PKViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	devicesArray = [[NSMutableArray alloc] init];
	
	_priorityData = [[PKInteractionData data] getRankedPeople];
	[_priorityView setDelegate:self];
    [_priorityView setDataSource:self];
    [_priorityView reloadData];
    
    int i = 0;
    for (UIView *v in self.view.subviews) {
        if ([v class] == [UIView class]) {
        
            if (i < [[_priorityData allKeys] count]) {

                NSString *emotion = [[_priorityData allKeys] objectAtIndex:i];
                NSArray *emo_arr = (NSArray *)[_priorityData objectForKey:emotion];
                Person *person = [emo_arr objectAtIndex:0];
                NSLog(@"%d %@", i, person.name);

//                UIButton *b0 = (UIButton *)[v viewWithTag:0];
//                [b0 setTitle:person.name forState:UIControlStateNormal];
//                [b0 sizeToFit];
//                
//                UIButton *b1 = (UIButton *)[v viewWithTag:1];
//                [b1 setTitle:emotion forState:UIControlStateNormal];
//                [b1 sizeToFit];
//                i++;
                
                NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@"a clickable word" attributes:@{ @"myCustomTag" : @(YES) }];
                [attributedString addAttribute:@"myCustomTag" value:@(YES) range:NSMakeRange(0,5)];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,5)];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(5,6)];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(11,5)];
                
                NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:@"hi hi hi hi"];
                [s appendAttributedString:attributedString];
            
                UITextView *tv = (UITextView *)[v viewWithTag:1];
                [tv setAttributedText:attributedString];
                
                UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
                //[gr setNumberOfTapsRequired:1];
                [tv addGestureRecognizer:gr];
                i++;
            }
        }
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	_priorityData = [[PKInteractionData data] getRankedPeople];
	[_priorityView reloadData];
    
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
		if (_priorityData && [_priorityData count] > 0) {
			return 1;
		}
		else return 0;
	} else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"NOTIFICATIONS";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == _priorityView) {
		if (_priorityData) {
			return [[_priorityData allKeys] count];
		} else return 0;
	} else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *cellIdentifier = @"cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	
	if (tableView == _priorityView) {
        
        NSString *emotion = [[_priorityData allKeys] objectAtIndex:indexPath.row];
        NSArray *emo_arr = (NSArray *)[_priorityData objectForKey:emotion];
        Person *person = [emo_arr objectAtIndex:0];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ makes you most %@", person.name, emotion];
    }
	
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == _priorityView) {
		//[self pushPersonViewController:[[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0]];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == _priorityView) {
        
//        Person *person = [_priorityData objectAtIndex:indexPath.row];
//		NSString *text = [NSString stringWithFormat:@"%@ makes you most %@", person.name, @"MAD"];
            NSString *text = @"temp";
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
		
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
												   options:NSStringDrawingUsesLineFragmentOrigin
												   context:nil];
		return rect.size.height+25;
//	} else if (tableView == _reportsView) {
//		NSString *text = [[_fetchedPeopleArray objectAtIndex:indexPath.row] name];
//		
//		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
//		
//		CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
//												   options:NSStringDrawingUsesLineFragmentOrigin
//												   context:nil];
//		return rect.size.height+25;
	}
	else return 0;
}



- (void)updateView {
	[_priorityView reloadData];
}


- (void)pushPersonViewController:(NSString *)name
{
	[[PKInteractionData data] setJumpToName:name];
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
    
    NSLog(@"%d, %f, %f", characterIndex, location.x, location.y);
    if (characterIndex < textView.textStorage.length) {
        
        NSRange range;
        id value = [textView.attributedText attribute:@"myCustomTag" atIndex:characterIndex effectiveRange:&range];
        
        // Handle as required...
        
        NSLog(@"%@, %d, %d", value, range.location, range.length);
        
        value = [textView.attributedText attribute:NSForegroundColorAttributeName atIndex:characterIndex effectiveRange:&range];
        
        // Handle as required...
        
        NSLog(@"%@, %d, %d", value, range.location, range.length);
        
    }
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

@end
