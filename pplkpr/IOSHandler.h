//
//  IOSHandler.h
//  pplkpr
//
//  Created by Lauren McCarthy on 11/23/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RHAddressBook/AddressBook.h>
#import "Person.h"

@interface IOSHandler : NSObject <NSURLConnectionDelegate>

+(id)data;
-(id)init;

@end


