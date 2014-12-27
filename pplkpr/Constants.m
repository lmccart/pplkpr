//
//  Constants.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/4/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "Constants.h"

@implementation GlobalMethods

+(UIColor *) globalYellowColor { return [UIColor colorWithRed:(255.0f/255.0f) green:(236.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f]; }

+(UIColor *) globalLightGrayColor { return [UIColor colorWithRed:(0.0f/255.0f) green:(0.0f/255.0f) blue:(0.0f/255.0f) alpha:0.1f]; }

+(UIFont *)globalFont { return [UIFont fontWithName:@"Karla-Regular" size:16.0]; }
+(UIFont *)globalBoldFont { return [UIFont fontWithName:@"Karla-Bold" size:16.0]; }

+ (NSDictionary *)attrsDict { return [NSDictionary dictionaryWithObject:[GlobalMethods globalFont]
                                                                 forKey:NSFontAttributeName]; };
+ (NSDictionary *) attrsBoldDict { return [NSDictionary dictionaryWithObject:[GlobalMethods globalBoldFont]
                                                                      forKey:NSFontAttributeName]; };
@end
