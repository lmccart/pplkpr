//
//  FBHandler.h
//  pplkpr
//
//  Created by Lauren McCarthy on 9/3/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBHandler : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


+(id)data;
-(id)init;

- (void)requestProfile:(NSString *)fbid completion:(void (^)(NSDictionary *result))completionBlock;
- (void) requestFriendsWithCompletion:(void (^)(NSArray *result))completionBlock;

@end


