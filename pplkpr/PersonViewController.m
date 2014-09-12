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

@interface PersonViewController () {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UILabel *personLabel;
@property (strong, nonatomic) IBOutlet UIImageView *personPhoto;
@property (strong, nonatomic) IBOutlet UITextView *personTickets;

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
	
}

- (void)viewWillAppear:(BOOL)animated {
    
	if ([[InteractionData data] jumpToPerson]) {
        self.curPerson = [[InteractionData data] jumpToPerson];
        NSLog(@"%@", self.curPerson.fb_tickets);
        [_personLabel setText:self.curPerson.name];
        [[InteractionData data] setJumpToPerson:nil];
        
        [[FBHandler data] requestProfilePic:self.curPerson.fbid withCompletion:^(NSDictionary * result){
            NSDictionary *pic = [result objectForKey:@"picture"];
            NSDictionary *data = [pic objectForKey:@"data"];
            NSString *url = [data objectForKey:@"url"];
            
            [self.personPhoto sd_setImageWithURL:[NSURL URLWithString:url]];
        }];
        
        [self checkTickets];
        
	} else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)checkTickets {
    Person *p = self.curPerson;
    for (NSString *tick in self.curPerson.fb_tickets) {
        [[FBHandler data] checkTicket:tick withCompletion:^(int status) {
            NSString *action = [p.fb_tickets objectForKey:tick];
            if (status == 1) {
                NSLog(@"ticket successful %@ %@", tick, action);
                [p.fb_tickets removeObjectForKey:tick];
                [p.fb_completed_actions addObject:action];
                NSLog(@"%@", p.fb_completed_actions);
            } else if (status == 0) {
                NSLog(@"ticket processing %@", tick);
            } else if (status == -1) {
                NSLog(@"ticket failed %@", tick);
                [p.fb_tickets removeObjectForKey:tick];
            }
        }];
            
    }
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
