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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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

#pragma data

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
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								   initWithManagedObjectModel:[self managedObjectModel]];
	if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil URL:storeUrl options:nil error:&error]) {
		/*Error for store creation should be handled in here*/
	}
	
	return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma Location

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
	// The location "unknown" error simply means the manager is currently unable to get the location.
	if ([error code] != kCLErrorLocationUnknown) {
		[self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
	}
}

- (void)stopUpdatingLocation:(NSString *)state {
	[locationManager stopMonitoringSignificantLocationChanges];
	locationManager.delegate = nil;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
	NSLog(@"did you move?");
}

- (void)dealloc {
	[locationManager release];
	[super dealloc];
}

@end
