//
//  Constants.m
//  pplkpr
//
//  Created by Lauren McCarthy on 9/4/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "Constants.h"

@implementation GlobalMethods

// r:255, g:236, b:0
+(UIColor *) globalYellowColor { return [UIColor colorWithRed:1 green:.925f blue:0 alpha:1]; }

+(UIColor *) globalLightGrayColor { return [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]; }

+(UIFont *)globalFont { return [UIFont fontWithName:@"Karla-Regular" size:16.0]; }
+(UIFont *)globalBoldFont { return [UIFont fontWithName:@"Karla-Bold" size:16.0]; }

+ (NSDictionary *)attrsDict { return [NSDictionary dictionaryWithObject:[GlobalMethods globalFont]
                                                                 forKey:NSFontAttributeName]; };
+ (NSDictionary *) attrsBoldDict { return [NSDictionary dictionaryWithObject:[GlobalMethods globalBoldFont]
                                                                      forKey:NSFontAttributeName]; };
@end
