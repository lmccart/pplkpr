//
//  PKMeetViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HxmBLEConnectionManager.h"

@interface PKMeetViewController : UIViewController<HxMBLEManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
	
    IBOutlet UILabel *hrLbl, *deviceWornLbl, *deviceNameLbl,*statusLbl;
    HxMBLEConnectionManager *bleManager;
    NSTimer *guiRefreshTimer;
    IBOutlet UITableView *devicesTableView;
    NSMutableArray *devicesArray;
    CBPeripheral *selectedDevice;
    
    IBOutlet UIView *connectView;
}

@property(nonatomic,retain) NSTimer *guiRefreshTimer;
@property(nonatomic,retain) HxMBLEConnectionManager *bleManager;
-(IBAction) connectClicked:(id)sender;
-(IBAction) disconnectClicked:(id)sender;
-(IBAction) startScanClicked:(id)sender;
-(IBAction) stopScanClicked:(id)sender;
-(IBAction) exitClicked:(id)sender;
-(IBAction)backClicked:(id)sender;


@end
