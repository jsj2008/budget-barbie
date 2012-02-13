//
//  Place.h
//  Budget Barbie
//
//  Created by Daniel Quek on 4/2/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic, copy) NSString *placeId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *likes;
@property (nonatomic, copy) NSString *videoURL;

@end
