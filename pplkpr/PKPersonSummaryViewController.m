//
//  PKPersonSummaryViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKPersonSummaryViewController.h"

@interface PKPersonSummaryViewController () {
	
	NSMutableData *receivedData;
}

@property (retain, nonatomic) IBOutlet UILabel *personLabel;

@end

@implementation PKPersonSummaryViewController

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
	
	for(id key in [[PKInteractionData data] summary]) {
		id value = [[[PKInteractionData data] summary] objectForKey:key];
		NSLog(@"%@ %@", value, key);
	}
	
}

- (void)viewWillAppear:(BOOL)animated {
	[_personLabel setText:[[PKInteractionData data] jumpToName]];
	[[PKInteractionData data] setJumpToName:nil];
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

- (void)dealloc {
	[_personLabel release];
	[super dealloc];
}

@end
