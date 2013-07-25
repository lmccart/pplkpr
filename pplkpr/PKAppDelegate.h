//
//  PKAppDelegate.h
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PKAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
	
	CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) CLLocationManager *locationManager;

- (void)stopUpdatingLocation:(NSString *)state;

@end
