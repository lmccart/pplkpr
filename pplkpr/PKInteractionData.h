//
//  PKInteractionData.h
//  pplkpr
//
//  Created by Lauren McCarthy on 8/20/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKInteractionData : NSObject

@property (retain) NSString *personName;
@property (retain) NSMutableArray *dataArray;
@property (retain) NSString *emotion;
@property (retain) NSString *overallDescription;
@property (assign) float *overallRating;

@property (retain) NSDictionary *summary;

@property (nonatomic, strong) NSArray *emotionsArray;

+(id)data;
-(id)init;

@end


