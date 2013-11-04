//
//  PhysiologicalData.h
//  BLETestApp
//
//  Created by Apple on 07/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhysiologicalData : NSObject
{
    int heartRate;
    BOOL isDeviceWorn;
}
@property (nonatomic, assign) int heartRate;
@property(nonatomic, assign) BOOL isDeviceWorn;
@end
