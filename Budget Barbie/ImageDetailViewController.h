//
//  ImageDetailViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 10/2/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemBought;

typedef enum {
	ImageDetailViewControllerAnimationTypeSlide,
	ImageDetailViewControllerAnimationTypeFade
} ImageDetailViewControllerAnimationType;

@interface ImageDetailViewController : UIViewController

@property (nonatomic, strong) ItemBought *itemBought;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewControllerWithAnimationType:(ImageDetailViewControllerAnimationType)animationType;

@end
