//
//  PKMeetViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKMeetViewController.h"



@interface PKMeetViewController ()

@end

@implementation PKMeetViewController

@synthesize bleManager, guiRefreshTimer, peripheralManager, selectedPeripheral;

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
    self.bleManager = [[HxMBLEConnectionManager alloc] initWithDeleget:self];
	devicesArray = [[NSMutableArray alloc] init];
	
	self.peripheralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) disconnectClicked:(id)sende
{
    [bleManager setReconnectOnDisconnect:NO];
    [bleManager disconnectHxmDevice];
}
-(IBAction) startScanClicked:(id)sender
{
	[peripheralManager scanForPeripheralsWithServices:nil options:nil];
	
}
-(IBAction) stopScanClicked:(id)sender
{

}

-(void)dealloc
{
    if(guiRefreshTimer) {
        [guiRefreshTimer invalidate];
        guiRefreshTimer = nil;
    }
    if(bleManager) {
        [bleManager release];
        bleManager = nil;
    }
    [super dealloc];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"manager updated state");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	
    NSLog(@"Discovered %@", peripheral.name);
	
	if (peripheral) {
		selectedPeripheral = [peripheral retain];
		
		[peripheralManager stopScan];
		NSLog(@"Scanning stopped");
		
		[peripheralManager connectPeripheral:selectedPeripheral options:nil];
	}
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	
    NSLog(@"Peripheral connected");
	
	peripheral.delegate = self;
	// PEND: set reconnect [bleManager setReconnectOnDisconnect:YES];
	// PEND: handle errors
	[peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
		[peripheral discoverCharacteristics:nil forService:service]; // pend pass UDID of characteristic
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
			 error:(NSError *)error {
	
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@ for service %@", characteristic, service);
		[peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
	
	if (!error) {
		NSData *data = characteristic.value;
		// parse the data as needed
        NSLog(@"Read value %@ for characteristic %@", data, characteristic);
		
	}
}

-(void) onUnspportedHarware:(NSString *) error
{
    NSLog(@"$$$$$$$$$$$ Iphone does not support BLE.   Error:%@",error);
}
-(void) onHxmDeviceDiscovered:(CBPeripheral *) device
{
    NSLog(@"$$$$$$$$$$$ HxM device discovered: %@",device);
    if(device && ![devicesArray containsObject:device]) {
        [devicesArray addObject:device];
    }
}
-(void) onHxmDeviceConnected:(CBPeripheral *) device
{
    NSLog(@"$$$$$$$$$$$ HxM device Connected: %@",device);
}
-(void) onHxmdeviceFialedToConnect:(CBPeripheral *)device error:(NSError *)error
{
    NSLog(@"$$$$$$$$$$$ HxM device Failed to connect: %@      Error is:%@",device, error);
}
-(void) onHxmDeviceDisconnected:(CBPeripheral *)device error:(NSError *)error
{
    NSLog(@"$$$$$$$$$$$ HxM device disconnected: %@      Error is:%@",device, error);
}
-(void) onPhysiologicalDataReceived:(PhysiologicalData *) data
{
    NSLog(@"$$$$$$$$$$$ Hxm device data received. HR:%d    isDeviceWorn: %@",[data heartRate],
		  [data isDeviceWorn]?@"YES":@"NO");
}


@end
