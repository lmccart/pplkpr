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
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.side = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.side == -1) {
        [self performSegueWithIdentifier:@"meetSegue" sender:self];
    } else if (self.side == 1) {
        [self performSegueWithIdentifier:@"leftSegue" sender:self];
    }
    self.side = 0;
}

#pragma mark UI handlers

- (IBAction)reportMeet:(id)sender {
    [self performSegueWithIdentifier:@"meetSegue" sender:self];
}

- (IBAction)reportLeft:(id)sender {
    [self performSegueWithIdentifier:@"leftSegue" sender:self];
}



@end
