//
//  ReportViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 9/5/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "ReportViewController.h"

@interface ReportViewController()
@end


@implementation ReportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"initing\n");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}




#pragma mark UI handlers

- (IBAction)reportMeet:(id)sender {
    [self performSegueWithIdentifier:@"meetSegue" sender:self];
}

- (IBAction)reportLeft:(id)sender {
    [self performSegueWithIdentifier:@"leftSegue" sender:self];
}



@end
