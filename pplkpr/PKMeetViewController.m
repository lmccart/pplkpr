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

@synthesize guiRefreshTimer, peripheralManager, selectedPeripheral;

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
	devicesArray = [[NSMutableArray alloc] init];
	
	self.peripheralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
		
		//[peripheralManager stopScan];
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
	
	CBUUID* target = [CBUUID UUIDWithString:@"180d"]; // heart rate service
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service.UUID);
		if([[service.UUID data] isEqualToData:[target data]]) {
			[peripheral discoverCharacteristics:nil forService:service];
		}
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
			 error:(NSError *)error {
	
	CBUUID* target = [CBUUID UUIDWithString:@"2a38"]; // body location characteristic (testing)
    for (CBCharacteristic *characteristic in service.characteristics) {
		if([[characteristic.UUID data] isEqualToData:[target data]]) {
			[peripheral readValueForCharacteristic:characteristic];
		}
        NSLog(@"Discovered characteristic %@ for service %@ notifying %hhd", characteristic.UUID, service.UUID, characteristic.isNotifying);
		[peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error {
	CBUUID* target = [CBUUID UUIDWithString:@"2902"]; // client characteristic configuration
	for(CBDescriptor *descriptor in characteristic.descriptors) {
		NSLog(@"Discovered descriptor %@ for characteristic %@ ", descriptor.UUID, characteristic.UUID);
		if([[descriptor.UUID data] isEqualToData:[target data]]) {
			// need to configure here according to https://developer.bluetooth.org/gatt/descriptors/Pages/DescriptorViewer.aspx?u=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
			NSLog(@"Ready to configure heart rate notifications");
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
	if (!error) {
		// parse the data as needed
        NSLog(@"Read value %@ for characteristic %@", characteristic.value, characteristic.UUID);
	}
}

@end
