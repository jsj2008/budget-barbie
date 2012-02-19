//
//  HomeViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTitleViewController.h"

@interface HomeViewController : CustomTitleViewController 

@property (weak, nonatomic) IBOutlet UIButton *budgetButton;
@property (weak, nonatomic) IBOutlet UIButton *specialButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *giveawayButton;
@property (weak, nonatomic) IBOutlet UIImageView *presentImage;

@end
