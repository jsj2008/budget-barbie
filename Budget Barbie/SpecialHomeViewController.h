//
//  SpecialHomeViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 12/2/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "CustomTitleViewController.h"
#import "iCarousel.h"

@interface SpecialHomeViewController : CustomTitleViewController <iCarouselDelegate, iCarouselDataSource>

@property (nonatomic, weak) IBOutlet iCarousel *carousel;

@end
