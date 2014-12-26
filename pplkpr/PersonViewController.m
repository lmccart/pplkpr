//
//  PersonViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PersonViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSDate+DateTools.h"
#import "FBHandler.h"
#import "IOSHandler.h"
#import "Constants.h"
#import "InteractionData.h"
#import "Report.h"
#import "Person.h"

@interface PersonViewController () {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UILabel *personLabel;
@property (strong, nonatomic) IBOutlet UIImageView *personPhoto;
@property (strong, nonatomic) IBOutlet UITextView *personTickets;
@property (retain, nonatomic) IBOutlet UIView *priorityView;
@property (retain, nonatomic) NSArray *priorityData;

@property (retain, nonatomic) Person *curPerson;


@end

@implementation PersonViewController

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
    
    [[InteractionData data] checkTickets];
    
	for(id key in [[InteractionData data] summary]) {
		[[[InteractionData data] summary] objectForKey:key];
		//NSLog(@"%@ %@", value, key);
	}
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if ([[InteractionData data] jumpToPerson]) {
        self.curPerson = [[InteractionData data] jumpToPerson];
        //NSLog(@"%@", self.curPerson.fbTickets);
        [self.personLabel setText:self.curPerson.name];
        [[InteractionData data] setJumpToPerson:nil];
        
        [[FBHandler data] requestProfilePic:self.curPerson.fbid withType:@"large" withCompletion:^(NSDictionary * result){
            NSDictionary *pic = [result objectForKey:@"picture"];
            NSDictionary *data = [pic objectForKey:@"data"];
            NSString *url = [data objectForKey:@"url"];
            
            [self.personPhoto sd_setImageWithURL:[NSURL URLWithString:url]];
        }];
        
        [self updatePriority];
        
        // pend test this
        //[[FBHandler data] requestInviteToEvent:self.curPerson];
        //[[FBHandler data] createFakebookRequest:self.curPerson withType:@"post" withMessage:@"hi there" withEmotion:@"Excited"];
        
	} else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)clearPriority {
    NSArray *viewsToRemove = [self.priorityView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)updatePriority {
    
    [self clearPriority];
    
    float margin = 10.0;
    
    //_priorityData = [[InteractionData data] getRankedPeople];
    // NSLog(@"%@", [[InteractionData data] getPriorities]);
    
    self.priorityData = [[InteractionData data] getSortedPriorities];
    
    
    float y = 0;
    int n = 0;
    for (int i=0; i < [self.priorityData count]; i++) {
        
        if (n == 3) break;
        
        // abs value, name, asc, emotion
        NSArray *entry = [self.priorityData objectAtIndex:i];
        
        Person *p = [entry objectAtIndex:1];
        
        if (p == self.curPerson) {
            NSString *order = [[entry objectAtIndex:2] intValue] == 0 ? @"most" : @"least";
            NSString *emotion = [entry objectAtIndex:3];
            
            NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Makes me %@ %@.\n", order, [emotion lowercaseString]] attributes:[GlobalMethods attrsDict]];
            
            NSMutableAttributedString* actionAttributedStr;
            BOOL tap = NO;
            if (p.fbActions && [order isEqualToString:@"most"]) { // only check for most
                NSArray *actions = [p.fbActions objectForKey:emotion];
                if ([actions count] > 0) {
                    NSString *actionStr = [[InteractionData data] getPastDescriptiveAction:[[p.fbActions objectForKey:emotion] lastObject]];
                    
                    actionAttributedStr = [[NSMutableAttributedString alloc] initWithString:actionStr attributes:[GlobalMethods attrsDict]];
                } else {
                    tap = YES;
                    NSString *actionStr = [[InteractionData data] getFutureDescriptiveAction:emotion];
                    actionAttributedStr = [[NSMutableAttributedString alloc] initWithString:actionStr attributes:[GlobalMethods attrsBoldDict]];
                }
            } else {
                actionAttributedStr = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[GlobalMethods attrsDict]];
            }
            
            [attributedString appendAttributedString:actionAttributedStr];
            
            UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, y, self.priorityView.frame.size.width, 50)];
            [tv setDelegate:self];
            if (tap) {
                [tv setBackgroundColor:[GlobalMethods globalYellowColor]];
                UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
                [tv addGestureRecognizer:gr];
                [attributedString addAttribute:@"emotionTag" value:emotion range:NSMakeRange(0, [attributedString length])];
                NSString *action = [[InteractionData data] getFutureAction:emotion forIndex:0];
                [attributedString addAttribute:@"actionTag" value:action range:NSMakeRange(0, [attributedString length])];
            } else {
                [tv.layer setBorderColor:[[GlobalMethods globalYellowColor] CGColor]];
                [tv.layer setBorderWidth:1];
            }
            
            [tv setAttributedText:attributedString];
            
            [self.priorityView addSubview:tv];
            [self.view layoutIfNeeded];
            CGRect frame = tv.frame;
            tv.textContainerInset = UIEdgeInsetsMake(10,55,8,10);
            [tv layoutIfNeeded];
            frame.size.height = tv.contentSize.height;
            frame.size.width = self.priorityView.frame.size.width;
            tv.frame = frame;
            
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [emotion lowercaseString]]];
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            [iv setFrame:CGRectMake(10, (frame.size.height-40)/2, 40, 40)];
            [tv addSubview:iv];
            //[tv sizeToFit];
            
            y += tv.frame.size.height + margin;
            n++;
        }
    }
    
    // filler info
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, y, self.priorityView.frame.size.width, 50)];
    [self.priorityView addSubview:tv];
    
    Report *recent_r;
    for (Report *r in self.curPerson.reports) {
        if (recent_r == nil || [r.date isLaterThan:recent_r.date]) {
            recent_r = r;
        }
    }
    if (recent_r != nil) {
        
        [tv setText:[NSString stringWithFormat:@"Made me feel %@ %@.", [recent_r.emotion lowercaseString], [[recent_r.date timeAgoSinceNow] lowercaseString]]];
        [tv setFont:[GlobalMethods globalFont]];
    }
    
    
    
    [self.view layoutIfNeeded];
}


- (void)textTapped:(UITapGestureRecognizer *)recognizer {
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
        id action = [textView.attributedText attribute:@"actionTag" atIndex:characterIndex effectiveRange:&range];
        id emotion = [textView.attributedText attribute:@"emotionTag" atIndex:characterIndex effectiveRange:&range];
        
        if (action) {
            
            if ([[FBHandler data] useFakebook]) {
                NSString *msg = [[InteractionData data] getMessage:emotion];
                [[FBHandler data] createFakebookRequest:self.curPerson withType:action withMessage:msg withEmotion:emotion];
            } else {
                NSString *msg = [NSString stringWithFormat:@"You make me feel very %@.", [emotion lowercaseString]];
                [[IOSHandler data] sendText:self.curPerson withMessage:msg fromController:self];
            }
            
            [textView.layer setBorderColor:[[GlobalMethods globalYellowColor] CGColor]];
            [textView.layer setBorderWidth:1];
            [textView setBackgroundColor:[UIColor whiteColor]];
            
            NSString *newStr = [NSString stringWithFormat:@"%@\nI let them know.", [textView.attributedText.string componentsSeparatedByString:@"\n"][0]];
            NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:newStr attributes:[GlobalMethods attrsDict]];
            [textView setAttributedText:attributedString];
            
            [textView removeGestureRecognizer:textView.gestureRecognizers[0]];
        }
        
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

- (void)pushRankViewController:(NSString *)emotion withOrder:(BOOL)order
{
    //NSLog(@"jump to rank %d %@", order, emotion);
    [[InteractionData data] setJumpToEmotion:emotion];
    [[InteractionData data] setJumpToOrder:order];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
	
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	_personLabel = nil;
	[super viewDidUnload];
}

@end
