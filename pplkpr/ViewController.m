//
//  ViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "InteractionData.h"
#import "HeartRateMonitor.h"
#import "FBHandler.h"
#import "ReportViewController.h"

@interface ViewController()

@property (retain, nonatomic) NSArray *priorityData;
@property (retain, nonatomic) IBOutlet UIView *priorityView;
@property (retain, nonatomic) IBOutlet UIImageView *monitorStatusIcon;

@end


@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    [self updatePriority];
    [[InteractionData data] checkTickets];
    //[[InteractionData data] takeAction];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:@"email"];
    NSString *pass = [defaults objectForKey:@"pass"];
    
    
    if (!email || !pass) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    } else {
        [[FBHandler data] setEmail:email];
        [[FBHandler data] setPass:pass];
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
    for (int i=0; i < MIN(3, [self.priorityData count]); i++) {
        
        // abs value, name, asc, emotion
        NSArray *entry = [self.priorityData objectAtIndex:i];
        
        Person *p = [entry objectAtIndex:1];
        NSString *order = [[entry objectAtIndex:2] intValue] == 0 ? @"most" : @"least";
        NSString *emotion = [entry objectAtIndex:3];
        
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ makes me %@ %@.", p.name, order, [emotion lowercaseString]] attributes:[GlobalMethods attrsDict]];
        
        [attributedString addAttribute:@"personTag" value:p range:NSMakeRange(0,[p.name length])];
        [attributedString addAttribute:NSFontAttributeName value:[GlobalMethods globalBoldFont] range:NSMakeRange(0,[p.name length])];
        
        int l = [emotion length] + [order length] + 2;
        [attributedString addAttribute:@"emotionTag" value:emotion range:NSMakeRange([attributedString length]-l, l-1)];
        [attributedString addAttribute:@"orderTag" value:[entry objectAtIndex:2] range:NSMakeRange([attributedString length]-l, l-1)];
        [attributedString addAttribute:NSFontAttributeName value:[GlobalMethods globalBoldFont] range:NSMakeRange([attributedString length]-l, l)];
        
        
        UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, y, self.priorityView.frame.size.width, 50)];
        [tv setAttributedText:attributedString];
        [tv setBackgroundColor:[GlobalMethods globalYellowColor]];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        [tv addGestureRecognizer:gr];
        
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



- (void)pushPersonViewController:(Person *)p {
    NSLog(@"jump to person %@", p.name);
	[[InteractionData data] setJumpToPerson:p];
	[self.tabBarController setSelectedIndex:1];
}


- (void)pushRankViewController:(NSString *)emotion withOrder:(BOOL)order {
    NSLog(@"jump to rank %d %@", order, emotion);
	[[InteractionData data] setJumpToEmotion:emotion];
	[[InteractionData data] setJumpToOrder:order];
	[self.tabBarController setSelectedIndex:1];
}

- (IBAction)report:(id)sender {
    [self.tabBarController setSelectedIndex:2];
    UINavigationController *nc = self.tabBarController.viewControllers[2];
    ReportViewController *rvc = (ReportViewController *)nc.viewControllers[0];
    [rvc setSide:((UIButton *)sender).tag];
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

- (void)updateMonitorStatus:(float)status {
    NSLog(@"updated ");
    [self.monitorStatusIcon setHidden:!status];
}

- (void)updateMonitorBatteryLevel:(float)level {
    NSLog(@"updated ");
    [self.monitorStatusIcon setAlpha:level];
}

- (IBAction)logoutFB:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"email"];
    [defaults removeObjectForKey:@"pass"];
    [defaults synchronize];
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

@end
