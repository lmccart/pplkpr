//
//  PKAppDelegate.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBService.h>
#import <CoreBluetooth/CBUUID.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import <CoreBluetooth/CBDescriptor.h>

@interface PKAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate> {
	CLLocationManager *locationManager;
	CBCentralManager *peripheralManager;
    CBPeripheral *selectedPeripheral;
}

@property (strong, nonatomic) UIWindow *window;

- (void) writeToLogFile:(NSString*)content;
#pragma mark data

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark location

@property (retain, nonatomic) CLLocationManager *locationManager;

- (void) startUpdatingLocation;
- (void) stopUpdatingLocation;

#pragma mark heart rate

@property(nonatomic,retain) CBCentralManager *peripheralManager;
@property(strong, retain) CBPeripheral *selectedPeripheral;

-(void) startUpdatingHeartRate;
-(void) stopUpdatingHeartRate;

@end
