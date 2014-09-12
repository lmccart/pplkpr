//
//  HeartRateMonitor.m
//  HRM
//
//  Created by Lauren McCarthy on 7/15/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "HeartRateMonitor.h"
#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

/*
 
 #import <CoreBluetooth/CBCentralManager.h>
 #import <CoreBluetooth/CBPeripheral.h>
 #import <CoreBluetooth/CBService.h>
 #import <CoreBluetooth/CBUUID.h>
 #import <CoreBluetooth/CBCharacteristic.h>
 #import <CoreBluetooth/CBDescriptor.h>
 */

@interface HeartRateMonitor () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) ViewController *viewController;

@property BOOL sensorContact;

@end

@implementation HeartRateMonitor

+ (id)data {
    static HeartRateMonitor *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[self alloc] init];
    });
    return data;
}

- (id)init {
	
    if (self = [super init]) {
        NSLog(@"init hr\n");
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	}
    
    return self;
}

- (void)setViewController:(ViewController *)viewController {
    _viewController = viewController;
}


#pragma mark - Start/Stop Scan methods

// Use CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. 
- (BOOL) isLECapableHardware
{
    NSString * state = nil;    
    switch ([self.manager state]) {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
			[self startScan];
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;            
    }    
    NSLog(@"Central manager state: %@", state);    
    return FALSE;
}

// Request CBCentralManager to scan for heart rate peripherals using service UUID 0x180D
- (void) startScan 
{
    
    NSLog(@"startScan");
	
	// start log to file
    //	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //	NSString *documentsDirectory = [paths objectAtIndex:0];
    //	NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    //	NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    //	freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
    //[self.manager scanForPeripheralsWithServices:nil options:nil];
	
    
    [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] 
                                         options:nil];
}

// Request CBCentralManager to stop scanning for heart rate peripherals
- (void) stopScan 
{
    [self.manager stopScan];
    // log back to console
    //	int stderrSave = dup(STDERR_FILENO);
    //	fflush(stderr);
    //	dup2(stderrSave, STDERR_FILENO);
    //	close(stderrSave);
}

#pragma mark - CBCentralManager delegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"manager updated state");
    #if !(TARGET_IPHONE_SIMULATOR)
        [self isLECapableHardware];
    #endif
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Discovered %@", aPeripheral.name);
    
	if (aPeripheral) {
        [self stopScan];
		_peripheral = aPeripheral;
        [_manager connectPeripheral:self.peripheral
                            options:[NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithBool:YES]
                                                                forKey:
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
	}
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    
    NSLog(@"Peripheral connected %@", self.viewController);
    [_viewController updateMonitorStatus:@"connecting"];
    
	[aPeripheral setDelegate:self];
	// PEND: set reconnect [bleManager setReconnectOnDisconnect:YES];
	// PEND: handle errors
	[aPeripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
	CBUUID* target = [CBUUID UUIDWithString:@"180d"]; // heart rate service
    for (CBService *service in aPeripheral.services) {
        NSLog(@"Discovered service %@", service.UUID);
		if([[service.UUID data] isEqualToData:[target data]]) {
			[aPeripheral discoverCharacteristics:nil forService:service];
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
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
			// stopScan should call the following
			// [peripheral setNotifyValue:NO forCharacteristic:characteristic];
		}
	}
}


- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
	if (error) {
		return;
	}
    NSLog(@"didUpdateValueForCharacteristic %@", characteristic);
	CBUUID* target = [CBUUID UUIDWithString:@"2a37"]; // heart rate measurement characteristic
	if([[characteristic.UUID data] isEqualToData:[target data]]) {
		NSData* data = characteristic.value;
        
		int readOffset = 0;
        
		uint8_t flags;
		[data getBytes:&flags range:NSMakeRange(readOffset, 1)];
		readOffset += 1;
        
        // PEND KYLE
		uint8_t HeartRateValueFormat = (flags & (1 << 0)) >> 0;
		uint8_t SensorContactStatus = (flags & (3 << 1)) >> 1;
		uint8_t EnergyExpendedStatus = (flags & (1 << 3)) >> 3;
		uint8_t RRInterval = (flags & (1 << 4)) >> 4;
        
		       NSLog(@"Heart Rate %@ flags %hhu, %hhu, %hhu, %hhu for %@", characteristic.value, HeartRateValueFormat, SensorContactStatus, EnergyExpendedStatus, RRInterval, characteristic.UUID);
        
		if(HeartRateValueFormat) {
			uint16_t HeartRateMeasurementValue;
			[data getBytes:&HeartRateMeasurementValue range:NSMakeRange(readOffset, sizeof(HeartRateMeasurementValue))];
			readOffset += sizeof(HeartRateMeasurementValue);
            //			NSLog(@"Heart rate is %hu", HeartRateMeasurementValue);
		} else {
			uint8_t HeartRateMeasurementValue;
			[data getBytes:&HeartRateMeasurementValue range:NSMakeRange(readOffset, sizeof(HeartRateMeasurementValue))];
			readOffset += sizeof(HeartRateMeasurementValue);
            //			NSLog(@"Heart rate is %hhu", HeartRateMeasurementValue);
		}
        
        if(EnergyExpendedStatus == 1) {
            uint16_t EnergyExpended;
            [data getBytes:&EnergyExpended range:NSMakeRange(readOffset, sizeof(EnergyExpended))];
            readOffset += sizeof(EnergyExpended);
            NSLog(@"Energy expended is %hu", EnergyExpended);
        }
        
		if(SensorContactStatus == 2) {
			NSLog(@"Sensor contact is not detected");
            [_viewController updateMonitorStatus:@"no sensor contact"];
            _sensorContact = false;
		} else if(SensorContactStatus == 3) {
			//			NSLog(@"Sensor contact is detected");
            
            [_viewController updateMonitorStatus:@"connected"];
            _sensorContact = true;
            if(RRInterval) {
                //			NSLog(@"One or more RR-Interval values are present.");
                uint8_t entry = 0;
                while(readOffset < data.length) {
                    uint16_t rr;
                    [data getBytes:&rr range:NSMakeRange(readOffset, sizeof(rr))];
                    //				NSLog(@"RR-Interval %hhu: %hu", entry, rr);
                    
                    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
                    NSString* cur = [NSString stringWithFormat:@"%ld\t%hu", unixTime, rr];
                    NSLog(@"%@", cur);
                    //[self writeToLogFile:cur];
                    
                    entry++;
                    readOffset += sizeof(rr);
                }
            }
        }
	}
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error {
	if (!error) {
        NSLog(@"didUpdateNotificationStateForCharacteristic %@ for %@", characteristic.value, characteristic.UUID);
	}
}


# pragma mark reconnection

// Invoked when the central manager retrieves the list of known peripherals.
// Automatically connect to first known peripheral
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %u - %@", [peripherals count], peripherals);
    [self stopScan];
    // If there are any known devices, automatically connect to it.
    if([peripherals count] >= 1) {
        self.peripheral = [peripherals objectAtIndex:0];
        [self.manager connectPeripheral:self.peripheral 
                                options:[NSDictionary dictionaryWithObject:
                                         [NSNumber numberWithBool:YES]
                                                                    forKey:
                                         CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}


// Invoked when an existing connection with the peripheral is torn down. 
// Reset local variables
- (void) centralManager:(CBCentralManager *)central 
didDisconnectPeripheral:(CBPeripheral *)aPeripheral 
                  error:(NSError *)error
{
    NSLog(@"Disconnected peripheral %@", aPeripheral.name);
    [_viewController updateMonitorStatus:@"disconnected"];
    
    if (self.peripheral) {
        [self.peripheral setDelegate:nil];
        self.peripheral = nil;
    }
    
    [self startScan];
}

// Invoked when the central manager fails to create a connection with the peripheral.
- (void) centralManager:(CBCentralManager *)central 
didFailToConnectPeripheral:(CBPeripheral *)aPeripheral 
                  error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if (self.peripheral) {
        [self.peripheral setDelegate:nil];
        self.peripheral = nil;
    }
}


@end




#pragma mark heart rate


