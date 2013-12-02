//
//  PKViewController.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBService.h>
#import <CoreBluetooth/CBUUID.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import <CoreBluetooth/CBDescriptor.h>

@interface PKViewController : UIViewController <UITextFieldDelegate, CBCentralManagerDelegate, CBPeripheralDelegate> {
	
	CBCentralManager *peripheralManager;
    CBPeripheral *selectedPeripheral;
    NSMutableArray *devicesArray;
}


@property(nonatomic,retain) CBCentralManager *peripheralManager;
@property(strong, retain) CBPeripheral *selectedPeripheral;

-(IBAction) startScanClicked:(id)sender;
-(IBAction) stopScanClicked:(id)sender;


@end