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

@interface PKViewController()



@end




@implementation PKViewController



- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ( [segue.identifier isEqualToString:@"MeetSegue"] ){
		//PKMeetViewController *mvc = (PKMeetViewController*)segue.destinationViewController;
	}
	else if ([segue.identifier isEqualToString:@"LeftSegue"]){
		//[[PKInteractionData data] setPersonName:_whoTextField.text];
	}
	else if ([segue.identifier isEqualToString:@"RankSegue"]){
		//[[PKInteractionData data] setPersonName:_whoTextField.text];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

@end
