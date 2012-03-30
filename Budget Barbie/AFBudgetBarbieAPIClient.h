//
//  AFBudgetBarbieAPIClient.h
//  Budget Barbie
//
//  Created by Daniel Quek on 22/3/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFBudgetBarbieAPIClient : AFHTTPClient

+ (AFBudgetBarbieAPIClient *)shareClient;

@end
