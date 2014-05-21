//
//  PKAppDelegate.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKAppDelegate.h"
#import "PKViewController.h"
#import "PKInteractionData.h"

@implementation PKAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize locationManager;
@synthesize peripheralManager, selectedPeripheral;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self startUpdatingLocation];
    
    
    #if !(TARGET_IPHONE_SIMULATOR)
        [self startUpdatingHeartRate];
    #endif
	
	// tab bar items
	
	UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UITabBar *tabBar = tabBarController.tabBar;
	
	NSArray *names = @[@"pplkpr", @"rank", @"report"];
	
	for (int i=0; i<3; i++) {
		UITabBarItem *tabBarItem = [tabBar.items objectAtIndex:i];
		tabBarItem.image= [[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", names[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_sel.png", names[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		tabBarItem.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);
		tabBarItem.title = @"";
	}

	
	/*
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
	NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	 */
	
	return YES;
}

-(void) writeToLogFile:(NSString*)content{
    content = [NSString stringWithFormat:@"%@\n",content];
	
    //get the documents directory:
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [NSString stringWithFormat:@"%@/log.txt", documentsDirectory];
	
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else{
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
}

- (void)dealloc {
	[locationManager release];
	[peripheralManager release];
	[selectedPeripheral release];
	[super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark data

- (NSManagedObjectContext *) managedObjectContext {
	if (_managedObjectContext != nil) {
		return _managedObjectContext;
	}
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
											   stringByAppendingPathComponent: @"PhoneBook.sqlite"]];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								   initWithManagedObjectModel:[self managedObjectModel]];
	if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil URL:storeUrl options:options error:&error]) {
		/*Error for store creation should be handled in here*/
	}
	
	return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark location

/*
 notes on location:
 - energy usage can be analyzed with the instruments tool
 - regular gps usage destroys battery life (15% of battery every few hours)
 - significant location changes do not use gps, and use less power
 - enabling the gps once every 10-15 minutes is not a viable option
 - iphone 5+ has allowDeferredLocationUpdatesUntilTraveled, accurate & low power
 
 location update logic
 trigger notification unless:
 - time since last update is small (e.g., <30 min, moving in a car)
 - distance since last update is small (e.g., <100m, sitting in one place)
 */

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
	
	NSMutableArray* locationsArray = [[PKInteractionData data] locationsArray];
	[locationsArray addObjectsFromArray:locations];
	CLLocation* current = [locationsArray lastObject];
    
	NSLog(@"didUpdateLocations: %+.6f, %+.6f\n",
          current.coordinate.latitude,
          current.coordinate.longitude);
	
	NSTimeInterval timeThresholdInSeconds = 15 * 60; // 15 minutes
	CLLocationDistance distanceThresholdInMeters = 100; // 100 meters
	
	NSUInteger count = [locationsArray count];
	if(count > 1) {
		CLLocation* previous = [locationsArray objectAtIndex:(count - 2)];
		NSTimeInterval time = [[current timestamp] timeIntervalSinceDate:[previous timestamp]];
		if(time < timeThresholdInSeconds) {
			NSLog(@"too recent: %f < %f\n", time, timeThresholdInSeconds);
			return;
		}
		CLLocationDistance distance = [current distanceFromLocation:previous];
		if(distance < distanceThresholdInMeters) {
			NSLog(@"too close: %f < %f\n", distance, distanceThresholdInMeters);
			return;
		}
	}
    
    UILocalNotification * notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Are you about to meet someone or did you leave someone?";
    notification.alertAction = @"Yes";
    notification.hasAction = YES;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
	
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"locationManager failed with error %@", error);
}

- (void)startUpdatingLocation {
	NSLog(@"startUpdatingLocation");
	if ([CLLocationManager locationServicesEnabled]) {
		if (locationManager == nil) {
			locationManager = [[CLLocationManager alloc] init];
		}
		locationManager.delegate = self;
		[locationManager startMonitoringSignificantLocationChanges];
	} else {
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. Please enable them in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[servicesDisabledAlert show];
		[servicesDisabledAlert release];
	}
}

- (void)stopUpdatingLocation {
	NSLog(@"stopUpdatingLocation");
	[locationManager stopMonitoringSignificantLocationChanges];
	locationManager.delegate = nil;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
	
}

#pragma mark heart rate

- (void)startUpdatingHeartRate {
	NSLog(@"startUpdatingHeartRate");
	if(peripheralManager == nil) {
		peripheralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
	}
	[peripheralManager scanForPeripheralsWithServices:nil options:nil];
	
	// start log to file
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
//	NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//	freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void)stopUpdatingHeartRate {
	// log back to console
//	int stderrSave = dup(STDERR_FILENO);
//	fflush(stderr);
//	dup2(stderrSave, STDERR_FILENO);
//	close(stderrSave);
	NSLog(@"stop scan");
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"manager updated state");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	
    NSLog(@"Discovered %@", peripheral.name);
	
	if (peripheral) {
		selectedPeripheral = [peripheral retain];
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
	CBUUID* target = [CBUUID UUIDWithString:@"2a37"]; // heart rate measurement characteristic
	if([[characteristic.UUID data] isEqualToData:[target data]]) {
		NSData* data = characteristic.value;
		
		int readOffset = 0;
		
		uint8_t flags;
		[data getBytes:&flags range:NSMakeRange(readOffset, 1)];
		readOffset += 1;
		
		uint8_t HeartRateValueFormat = (flags & (1 << 0)) >> 0;
		uint8_t SensorContactStatus = (flags & (3 << 1)) >> 1;
		uint8_t EnergyExpendedStatus = (flags & (1 << 3)) >> 3;
		uint8_t RRInterval = (flags & (1 << 4)) >> 4;
		
		//        NSLog(@"Heart Rate %@ flags %hhu, %hhu, %hhu, %hhu for %@", characteristic.value, HeartRateValueFormat, SensorContactStatus, EnergyExpendedStatus, RRInterval, characteristic.UUID);
		
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
		
		if(SensorContactStatus == 2) {
			NSLog(@"Sensor contact is not detected");
		} else if(SensorContactStatus == 3) {
			//			NSLog(@"Sensor contact is detected");
		}
		
		if(EnergyExpendedStatus == 1) {
			uint16_t EnergyExpended;
			[data getBytes:&EnergyExpended range:NSMakeRange(readOffset, sizeof(EnergyExpended))];
			readOffset += sizeof(EnergyExpended);
			NSLog(@"Energy expended is %hu", EnergyExpended);
		}
		
		if(RRInterval) {
			//			NSLog(@"One or more RR-Interval values are present.");
			uint8_t entry = 0;
			while(readOffset < data.length) {
				uint16_t rr;
				[data getBytes:&rr range:NSMakeRange(readOffset, sizeof(rr))];
//				NSLog(@"RR-Interval %hhu: %hu", entry, rr);
				
				time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
				NSString* cur = [NSString stringWithFormat:@"%ld\t%hu", unixTime, rr];
				[self writeToLogFile:cur];
				
				entry++;
				readOffset += sizeof(rr);
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

@end
