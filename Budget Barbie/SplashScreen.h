//
//  SplashScreen.h
//  Budget Barbie
//
//  Created by Daniel Quek on 22/3/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplashScreen : NSObject

@property (readonly) NSString *videoURLString;
@property (readonly) NSString *description;
@property (readonly) NSString *imageURL;

+(void)getSplashScreenInfoWithBlock:(void (^)(NSArray *info))block;

@end
