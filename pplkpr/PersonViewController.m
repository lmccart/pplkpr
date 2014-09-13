//
//  PersonViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PersonViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "FBHandler.h"
#import "Constants.h"
#import "InteractionData.h"

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
	
	for(id key in [[InteractionData data] summary]) {
		id value = [[[InteractionData data] summary] objectForKey:key];
		NSLog(@"%@ %@", value, key);
	}
    
    [self.personPhoto.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.personPhoto.layer setBorderWidth: 1.5];
}

- (void)viewWillAppear:(BOOL)animated {
    
	if ([[InteractionData data] jumpToPerson]) {
        self.curPerson = [[InteractionData data] jumpToPerson];
        NSLog(@"%@", self.curPerson.fbTickets);
        [_personLabel setText:self.curPerson.name];
        [[InteractionData data] setJumpToPerson:nil];
        
        [[FBHandler data] requestProfilePic:self.curPerson.fbid withType:@"large" withCompletion:^(NSDictionary * result){
            NSDictionary *pic = [result objectForKey:@"picture"];
            NSDictionary *data = [pic objectForKey:@"data"];
            NSString *url = [data objectForKey:@"url"];
            
            [self.personPhoto sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error) {
                    CGRect frame = self.personPhoto.frame;
                    [self.personPhoto setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width*image.size.height/image.size.width)];
                }
            }];
        }];
        
        [self checkTickets];
        [self updatePriority];
        
        // pend test this
        //[[FBHandler data] requestInviteToEvent:self.curPerson];
        
	} else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)checkTickets {
    Person *p = self.curPerson;
    for (NSString *tick in self.curPerson.fbTickets) {
        [[FBHandler data] checkTicket:tick withCompletion:^(int status) {
            NSString *action = [p.fbTickets objectForKey:tick];
            if (status == 1) {
                NSLog(@"ticket successful %@ %@", tick, action);
                [p.fbTickets removeObjectForKey:tick];
                [p.fbCompletedActions addObject:action];
                NSLog(@"%@", p.fbCompletedActions);
            } else if (status == 0) {
                NSLog(@"ticket processing %@", tick);
            } else if (status == -1) {
                NSLog(@"ticket failed %@", tick);
                [p.fbTickets removeObjectForKey:tick];
            }
        }];
            
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
            
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[GlobalMethods globalFont]
                                                                        forKey:NSFontAttributeName];
            
            NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Makes me %@ %@.\n", order, [emotion lowercaseString]] attributes:attrsDictionary];
            
            int l = [emotion length] + [order length] + 2;
            [attributedString addAttribute:@"emotionTag" value:emotion range:NSMakeRange([attributedString length]-l-1, l-1)];
            [attributedString addAttribute:@"orderTag" value:[entry objectAtIndex:2] range:NSMakeRange([attributedString length]-l-1, l-1)];
            [attributedString addAttribute:NSFontAttributeName value:[GlobalMethods globalBoldFont] range:NSMakeRange([attributedString length]-l-1, l-1)];
            
            
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
            n++;
        }
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
        id value = [textView.attributedText attribute:@"emotionTag" atIndex:characterIndex effectiveRange:&range];
        id order = [textView.attributedText attribute:@"orderTag" atIndex:characterIndex effectiveRange:&range];
        //NSLog(@"%@, %d, %d, %d", value, [order boolValue], range.location, range.length);
        
        if (value) {
            [self pushRankViewController:value withOrder:[order boolValue]];
        }
        
    }
}

- (void)pushRankViewController:(NSString *)emotion withOrder:(BOOL)order
{
    NSLog(@"jump to rank %d %@", order, emotion);
    [[InteractionData data] setJumpToEmotion:emotion];
    [[InteractionData data] setJumpToOrder:order];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



-(IBAction)sendInAppSMS:(id)sender {
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = @"Lauren is on her way to meet you and she is very excited.";
		controller.recipients = [NSArray arrayWithObjects:@"1234567890", nil];
		controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:nil];
	}
    //[[FBHandler data] requestPoke:self.curPerson];
    [[FBHandler data] requestPost:self.curPerson withMessage:@"hi kyle from fakebook"];
}

/*

- (void)fetchContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure {
	if (ABAddressBookRequestAccessWithCompletion) {
		// on iOS 6
		
		CFErrorRef err;
		ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
			// ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
			dispatch_async(dispatch_get_main_queue(), ^{
				if (!granted) {
					failure((__bridge NSError *)error);
				} else {
					readAddressBookContacts(addressBook, success);
				}
				CFRelease(addressBook);
			});
		});
	} else {
		// on iOS < 6
		
		ABAddressBookRef addressBook = ABAddressBookCreate();
		readAddressBookContacts(addressBook, success);
		CFRelease(addressBook);
	}
}
-(IBAction)deleteContact:(id)sender {
	ABAddressBookRef ab = NULL;
	
	if (&ABAddressBookCreateWithOptions) {
		NSError *error = nil;
		ab = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
	}
	
	if (ab) {
		if (&ABAddressBookRequestAccessWithCompletion) {
            ABAddressBookRequestAccessWithCompletion(ab,
			 ^(bool granted, CFErrorRef error) {
				 if (granted) {
					 // constructInThread: will CFRelease ab.
					 [NSThread detachNewThreadSelector:@selector(constructInThread:)
											  toTarget:self
											withObject:ab];
				 } else {
					 CFRelease(ab);
				 }
			 });
		} else {
            // constructInThread: will CFRelease ab.
            [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                     toTarget:self
                                   withObject:ab];
		}
	}
	
	ABRecordSetValue(delete, kABPersonFirstNameProperty, @"Max", nil);
	ABRecordSetValue(delete, kABPersonLastNameProperty, @"Mustermann", nil);
	
	//Gets the array of everybody in the
	NSArray *peopleArray = (__bridge NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
	
	//Creates a pass test block to see if the ABRecord has the same name as delete
	BOOL (^predicate)(id obj, NSUInteger idx, BOOL *stop) = ^(id obj, NSUInteger idx, BOOL *stop) {
		ABRecordRef person = (__bridge ABRecordRef)obj;
		CFComparisonResult result =  ABPersonComparePeopleByName(person, delete, kABPersonSortByLastName);
		bool pass = (result == kCFCompareEqualTo);
		if (pass) {
			delete = person;
		}
		return (BOOL) pass;
	};
	
	int idx = [peopleArray indexOfObjectPassingTest:predicate];
	
	bool removed = ABAddressBookRemoveRecord(addressBook, delete, &error);
	bool saved = ABAddressBookSave(addressBook, &error);
}
*/
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			NSLog(@"FAILURE");
			break;
		case MessageComposeResultSent:
			break;
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showMore:(id)sender {
	[self.navigationController popToRootViewControllerAnimated:YES];
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
