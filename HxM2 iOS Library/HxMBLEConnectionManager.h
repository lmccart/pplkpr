//
//  BLEConnectionManager.h
//
//  Created by Apple on 17/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBService.h>
#import <CoreBluetooth/CBUUID.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import "PhysiologicalData.h"

@protocol HxMBLEManagerDelegate <NSObject>
-(void) onUnspportedHarware:(NSString *) error;
-(void) onHxmDeviceDiscovered:(CBPeripheral *) device;
-(void) onHxmDeviceConnected:(CBPeripheral *) device;
-(void) onHxmdeviceFialedToConnect:(CBPeripheral *)device error:(NSError *)error;
-(void) onHxmDeviceDisconnected:(CBPeripheral *)device error:(NSError *)error;
-(void) onPhysiologicalDataReceived:(PhysiologicalData *) data;
@end

@interface HxMBLEConnectionManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    NSMutableArray *peripheralArr;
    CFUUIDRef selectedDeviceUUID;
    BOOL isConnected;
    BOOL reconnectOnDisconnect;
    id<HxMBLEManagerDelegate> delegate;
}
@property(nonatomic,retain) id<HxMBLEManagerDelegate> delegate;
@property(nonatomic,assign) CFUUIDRef selectedDeviceUUID;
@property(nonatomic,retain) CBCentralManager *manager;
@property(nonatomic,retain) NSMutableArray *peripheralArr;
@property(nonatomic,assign) BOOL isConnected,reconnectOnDisconnect;

- (id) initWithDeleget:(id) delegate;
- (void) startScan;
- (void) stopScan;

-(void) disconnectHxmDevice;
-(void) connectToHxmDevice:(CBPeripheral *) hxmDevice;

-(BOOL) isBluetoothEnabled;

@end




