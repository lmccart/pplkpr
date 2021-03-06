//
//  AppDelegate.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "AppDelegate.h"
#import "InteractionData.h"
#import "HeartRateMonitor.h"
#import "IOSHandler.h"
#import "HeartRateAnalyzer.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
	[self startUpdatingLocation];
    
	[[UITextField appearance] setTintColor:[UIColor blackColor]];
    
	// Setup tab bar items
	UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UITabBar *tabBar = tabBarController.tabBar;
	
	NSArray *names = @[@"home", @"rank", @"report"];
	
	for (int i=0; i<3; i++) {
		UITabBarItem *tabBarItem = [tabBar.items objectAtIndex:i];
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", names[i]]];
		tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_sel.png", names[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		tabBarItem.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);
		tabBarItem.title = @"";
	}

    UINavigationController *nc = tabBarController.viewControllers[0];
    self.homeController = nc.viewControllers[0];
    [[HeartRateMonitor data] setViewController:(ViewController *)self.homeController];
    
    // Init data
    [[IOSHandler data] init];
    [[InteractionData data] checkTickets];
    
    // Make sure notifs are allowed
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Handle launching from a notification
    UILocalNotification *notification =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        NSString *type = [notification.userInfo objectForKey:@"type"];
        if ([type isEqualToString:@"hrv"] || [type isEqualToString:@"location"]) {
            [self popToReportView];
        }
    }
    
	return YES;
}

//-(void) writeToLogFile:(NSString*)content{
//    content = [NSString stringWithFormat:@"%@\n",content];
//	
//    //get the documents directory:
//    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSString *fileName = [NSString stringWithFormat:@"%@/log.txt", documentsDirectory];
//	
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
//    if (fileHandle){
//        [fileHandle seekToEndOfFile];
//        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
//        [fileHandle closeFile];
//    }
//    else{
//        [content writeToFile:fileName
//                  atomically:NO
//                    encoding:NSStringEncodingConversionAllowLossy
//                       error:nil];
//    }
//}

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
    [self stopUpdatingLocation];
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
    
    CLLocation* current = [locations lastObject];
    
//	NSLog(@"didUpdateLocations: %+.6f, %+.6f\n",
//          current.coordinate.latitude,
//          current.coordinate.longitude);
	
	NSTimeInterval timeThresholdInSeconds = 15 * 60; // 15 minutes
//	CLLocationDistance distanceThresholdInMeters = 100; // 100 meters
	
    CLLocation *lastLoc = [[InteractionData data] lastLoc];
    
	if(lastLoc) {
		NSTimeInterval time = [[current timestamp] timeIntervalSinceDate:[lastLoc timestamp]];
		if(time < timeThresholdInSeconds) {
			//NSLog(@"too recent: %f < %f\n", time, timeThresholdInSeconds);
			return;
		}
//		CLLocationDistance distance = [current distanceFromLocation:lastLoc];
//		if(distance < distanceThresholdInMeters) {
//			//NSLog(@"too close: %f < %f\n", distance, distanceThresholdInMeters);
//			return;
//        }
        
        // trigger alert
        [self triggerNotification:@"location"];
	}
    [[InteractionData data] setLastLoc:current];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"locationManager failed with error %@", error);
}

- (void)startUpdatingLocation {
	if ([CLLocationManager locationServicesEnabled]) {
		if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.locationManager.distanceFilter = 100.0f;
		}
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
		[self.locationManager startMonitoringSignificantLocationChanges];
	} else {
		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. Please enable them in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[servicesDisabledAlert show];
	}
}

- (void)stopUpdatingLocation {
	NSLog(@"stopUpdatingLocation");
	[self.locationManager stopMonitoringSignificantLocationChanges];
	self.locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)triggerNotification:(NSString *)type {
    
    NSLog(@"trying to send notification");
    
    bool exists = false;
    
    for(UILocalNotification *n in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSString *t = [n.userInfo objectForKey:@"type"];
        if([t isEqualToString:type]) {
            exists = true;
        }
    }
    
    
    if (!exists) {
        NSString *msg;
        if ([type isEqualToString:@"hrv"]) {
            msg = @"Are you feeling something?";
        } else if ([type isEqualToString:@"location"]) {
            msg = @"Are you about to meet someone or did you just leave someone?";
        } else if ([type isEqualToString:@"hr_monitor"]) {
            msg = @"Heart rate monitor is not connected.";
        } else if ([type isEqualToString:@"hr_battery"]) {
            msg = @"Heart rate monitor battery is low.";
        }
        UILocalNotification * notification = [[UILocalNotification alloc] init];
        notification.alertBody = msg;
        notification.alertAction = @"Report";
        notification.hasAction = YES;
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:type forKey:@"type"];
        notification.userInfo = infoDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        NSLog(@"sending notification");
    }
}

// fired in all when app notif received while app is foregrounded
// fired in iOS7 when app opened from touch on notif
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSString *type = [notification.userInfo objectForKey:@"type"];
    
    if ([type isEqualToString:@"hrv"] || [type isEqualToString:@"location"]) {

        if (application.applicationState == UIApplicationStateInactive ) {
            //The application received the notification from an inactive state, i.e. the user tapped the "View" button for the alert.
            [self popToReportView];
        }
        
        else if (application.applicationState == UIApplicationStateActive) {
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            if ([tabBarController selectedIndex] != 2) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!"
                                                                message:[notification alertBody]
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes", nil];
                [alert show];
            }
        }
    } else if ([type isEqualToString:@"hr_monitor"]) {
        if (application.applicationState == UIApplicationStateActive) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!"
                                                            message:[notification alertBody]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else if ([type isEqualToString:@"hr_battery"]) {
        if (application.applicationState == UIApplicationStateActive) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!"
                                                            message:[notification alertBody]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

// fired in iOS8 when app opened from touch on notif
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    NSString *type = [notification.userInfo objectForKey:@"type"];
    if ([type isEqualToString:@"hrv"] || [type isEqualToString:@"location"]) {
        [self popToReportView];
    }
    completionHandler();
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        [self popToReportView];
    }
}

- (void)popToReportView {
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    [tabBarController setSelectedIndex:2];
}

@end
