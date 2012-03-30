//
//  Place.m
//  Budget Barbie
//
//  Created by Daniel Quek on 4/2/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "Place.h"
#import "AFBudgetBarbieAPIClient.h"
#import "MyConstants.h"
#import "UIDevice+IdentifierAddition.h"


@implementation Place

@synthesize placeId = _placeId;
@synthesize name = _name;
@synthesize imageURL = _imageURL;
@synthesize description = _description;
@synthesize likes = _likes;
@synthesize videoURL = _videoURL;

-(id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _name = [attributes objectForKey:@"itemName()"];
    _description = [attributes objectForKey:@"Description"];
    _imageURL = [attributes objectForKey:@"Image"];
    _placeId = [attributes objectForKey:@"id"];
    _likes = [attributes objectForKey:@"likes"];
    _videoURL = [attributes objectForKey:@"Video"];
    
    return self;
}

+(void)getBudgetPlacesWithBlock:(void (^)(NSArray *))block
{
    [[AFBudgetBarbieAPIClient shareClient]getPath:kHostPathForGetPlaces parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *budgetPlaces = [[NSMutableArray alloc]initWithCapacity:[responseObject count]];
        for (NSDictionary *attributes in responseObject) {
            Place *place = [[Place alloc]initWithAttributes:attributes];
            [budgetPlaces addObject:place];
        }
        if (block) {
            block([NSArray arrayWithArray:budgetPlaces]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@",error);
    }];
    
}

+(void)postLikesWithBlock:(void (^)(NSString *))block withSelectedPlace:(NSString *)placeID
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            placeID, @"places_id",
                            [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier], @"device_id",
                            nil];
    
    [[AFBudgetBarbieAPIClient shareClient]postPath:@"/budget_barbie/likes.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *likes = [[responseObject objectForKey:@"likes"]stringValue];
        if (block) {
            block(likes);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error : %@",error);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Budget Barbie" 
                                                       message:@"You have liked this place before!"
                                                      delegate:self 
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    }];
}

@end
