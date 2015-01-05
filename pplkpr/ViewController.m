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
#import "HeartRateAnalyzer.h"
#import "FBHandler.h"
#import "ReportViewController.h"

@interface ViewController()

@property (retain, nonatomic) IBOutlet UILabel *priorityLabel;
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
    
    
//    // PEND FAKE STUFF
//    [NSTimer scheduledTimerWithTimeInterval:6.0
//                                     target:self
//                                   selector:@selector(fakeSensor)
//                                   userInfo:nil
//                                    repeats:NO];
//    
    [NSTimer scheduledTimerWithTimeInterval:4.0 
                                     target:self
                                   selector:@selector(fakeMessage)
                                   userInfo:nil
                                    repeats:NO];
}

// PEND FAKE STUFF
//- (void)fakeSensor {
//    [self.monitorStatusIcon setHidden:false];
//    [self.monitorStatusIcon setAlpha:1.0];
//}
//
- (void)fakeMessage {
    NSLog(@"fake sensor");
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate triggerNotification:@"hrv"];
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
    
    if ([[FBHandler data] useFakebook]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *email = [defaults objectForKey:@"email"];
        NSString *pass = [defaults objectForKey:@"pass"];
        
        if (!email || !pass) {
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        } else {
            [[FBHandler data] setEmail:email];
            [[FBHandler data] setPass:pass];
            [self start];
        }
    } else {
        if (![[FBHandler data] loggedIn]) {
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        } else {
            [self start];
        }
    }
}

- (void)start {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:@"useMonitor"]) { // only check if connected before
        [[HeartRateMonitor data] scheduleCheckSensor];
    }
    //[[InteractionData data] checkTakeAction]; // PEND
    
    [[FBHandler data] logData:[[HeartRateAnalyzer data] getHRVDataString] withTag:@"rr" withCompletion:nil];
    [[FBHandler data] logData:[[HeartRateAnalyzer data] getRRDataString] withTag:@"hrv" withCompletion:^(NSData *data) {
        [[HeartRateAnalyzer data] resetRecentData];
    }];
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
    if ([self.priorityData count] == 0) {
        
        [self.priorityLabel setText:@"Welcome to pplkpr!\n\nIf you're about to meet someone or just left someone, touch one of the doors above to fill out a report.\n\nOr wear your heart rate monitor and let pplkpr detect when someone is making you feel something.\n\nOver time, pplkpr will analyze your relationships, find trends, and auto-manage your social life for you."];
        //[self.priorityLabel setAlpha:1.0];
        [self.priorityLabel setTextAlignment:NSTextAlignmentCenter];
        [self.priorityLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.priorityLabel setNumberOfLines:0];
        //[self.priorityLabel sizeToFit];
    } else {
        for (int i=0; i < MIN(3, [self.priorityData count]); i++) {
            [self.priorityLabel setText:@"Recently . . ."];
            [self.priorityLabel setAlpha:0.4];
            [self.priorityLabel setTextAlignment:NSTextAlignmentLeft];
            [self.priorityLabel sizeToFit];
            
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
            [tv setDelegate:self];
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
    [[InteractionData data] setJumpToPerson:p];
	[self.tabBarController setSelectedIndex:1];
}


- (void)pushRankViewController:(NSString *)emotion withOrder:(BOOL)order {
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
        id value = [textView.attributedText attribute:@"emotionTag" atIndex:characterIndex effectiveRange:&range];
        id order = [textView.attributedText attribute:@"orderTag" atIndex:characterIndex effectiveRange:&range];
        //NSLog(@"%@, %d, %d, %d", value, [order boolValue], range.location, range.length);
        
        if (value) {
            [self pushRankViewController:value withOrder:[order boolValue]];
        } else {
            id name = [textView.attributedText attribute:@"personTag" atIndex:0 effectiveRange:&range];
            [self pushPersonViewController:name];
        }
        
    } else {
        NSRange range;
        id name = [textView.attributedText attribute:@"personTag" atIndex:0 effectiveRange:&range];
        [self pushPersonViewController:name];
    }
}

- (void)updateMonitorStatus:(float)status {
    [self.monitorStatusIcon setHidden:!status];
}

- (void)updateMonitorBatteryLevel:(float)level {
    [self.monitorStatusIcon setAlpha:level];
}

- (IBAction)logoutFB:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Just checking..."
                                                    message:@"Are you sure you want to logout?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        if ([[FBHandler data] useFakebook]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"email"];
            [defaults removeObjectForKey:@"pass"];
            [defaults synchronize];
        } else {
            [[FBHandler data] logout];
        }
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
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


@end
