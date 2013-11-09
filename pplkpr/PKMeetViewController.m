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


/*
 
 
// Zephyr packet constants
public final static int checksumPolynomial = 0x8C;

// HXM message id
public final static byte HXM_ID = 0x26;

// End of text
public final static byte ETX = 0x03;

// Start of text
public final static byte STX = 0x02;

// HXM packet size
public final static byte HXM_DLC = 0x37;
 
 
 
 public static boolean vaildHxmPacket(byte[] packet) {
 
 if (packet == null)
 return false;
 
 if (packet.length != 60) {
 // most common, happens when not in sync with HXM
constants.error("wrong packet size on HXM");
return false;
}

if (packet[0] != STX) {
	constants.error("STX error on HXM");
	return false;
}

if (packet[1] != HXM_ID) {
	constants.error("MSG_ID error on HXM");
	return false;
}

if (packet[2] != HXM_DLC) {
	constants.error("DLC error on HXM");
	return false;
}

if (packet[59] != ETX) {
	constants.error("ETC error on HXM");
	return false;
}

if (ZephyrUtils.checkCRC(packet)) {
	constants.error("CRC error on HXM");
	return false;
}

return true;
}


 * Convert a raw bluetooth packet an XML command object
 *
 * @param packet
 *            is the raw bytes from the SPP
 * @return Command is the same command passed in, but with the Accelerometer
 *         elements added

public static Command parseHxmPacket(byte[] packet, Command command) {
	
	try {
		
		// add packet type to avoid confusion with RR packets
		// command.add(PrototypeFactory.type, "HXM");
		command.add(PrototypeFactory.strides, ZephyrUtils.parseString(packet, 54));
		
		// turn into a string, after scale factor applied
		int d = ZephyrUtils.mergeUnsigned(packet[50], packet[51]);
		command.add(PrototypeFactory.distance, String.valueOf(Math
															  .abs(((double) d / (double) 16))));
		
		int s = ZephyrUtils.mergeUnsigned(packet[52], packet[53]);
		command.add(PrototypeFactory.speed, String.valueOf(Math
														   .abs(((double) s / (double) 256))));
		
		int c = ZephyrUtils.mergeUnsigned(packet[54], packet[55]);
		command.add(PrototypeFactory.cadence, String.valueOf(Math
															 .abs(((double) c / (double) 16))));
		
	} catch (Exception e) {
		constants.error("parseHxmPacket() : " + e.getMessage());
	}
	
	// add other tags before sending ?
	return command;
}

*/


@end
