//
//  PersonViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PersonViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"


@interface PersonViewController () {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UILabel *personLabel;

@end

@implementation PersonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        if (!FBSession.activeSession.isOpen) {
            // if the session is closed, then we open it here, and establish a handler for state changes
            [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
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
    
	if ([[InteractionData data] jumpToName]) {
        [_personLabel setText:[[InteractionData data] jumpToName]];
        [[InteractionData data] setJumpToName:nil];
        
        
//        FBRequest* profileRequest = [FBRequest requestForMyFriends];
//        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                      NSDictionary* result,
//                                                      NSError *error) {
//            NSArray *f = [result objectForKey:@"data"];
//            for (NSDictionary<FBGraphUser>* friend in f) {
//                [_friends addObject:friend.name];
//            }
//        }];
        
	} else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
