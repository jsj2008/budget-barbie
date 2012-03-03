//
//  StartUpViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

//#import <iAd/iAd.h>
#import <UIKit/UIKit.h>

@interface StartUpViewController : UIViewController  //<ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *staticWeekUpdateImage;

@end
