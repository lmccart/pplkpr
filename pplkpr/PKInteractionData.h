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
@property (retain) NSMutableArray *momentsArray;
@property (retain) NSString *overallDescription;
@property (assign) float *overallRating;

@property (nonatomic, strong) NSArray *emotionsArray;


-(id)initWithName:(NSString *)aPersonName;

@end


