//
//  AFBudgetBarbieAPIClient.m
//  Budget Barbie
//
//  Created by Daniel Quek on 22/3/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "AFBudgetBarbieAPIClient.h"
#import "MyConstants.h"
#import "AFJSONRequestOperation.h"

@implementation AFBudgetBarbieAPIClient

+(AFBudgetBarbieAPIClient *)shareClient
{
    static AFBudgetBarbieAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFBudgetBarbieAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHostName,kHostMainDirectory]]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
