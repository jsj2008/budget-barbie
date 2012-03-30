//
//  SplashScreen.m
//  Budget Barbie
//
//  Created by Daniel Quek on 22/3/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "SplashScreen.h"
#import "AFBudgetBarbieAPIClient.h"
#import "MyConstants.h"

@implementation SplashScreen

@synthesize description = _description;
@synthesize imageURL = _imageURL;
@synthesize videoURLString = _videoURLString;

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _description = [attributes valueForKey:@"description"];
    _imageURL = [attributes valueForKey:@"image"];
    _videoURLString = [attributes valueForKey:@"webview"];
    
    return self;
}

+(void)getSplashScreenInfoWithBlock:(void (^)(NSArray *))block
{
    [[AFBudgetBarbieAPIClient shareClient]getPath:kHostPathForSplashScreen parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSMutableArray *array = [NSMutableArray array];
        SplashScreen *info = [[SplashScreen alloc]initWithAttributes:JSON];
        [array addObject:info];
        if (block) {
            block([NSArray arrayWithArray:array]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


@end
