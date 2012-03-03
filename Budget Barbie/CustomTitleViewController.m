//
//  CustomTitleViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 21/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "CustomTitleViewController.h"

@implementation CustomTitleViewController

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"titleView.png"]];
        [[self navigationItem]setTitleView:imageView];
    }
    return self;
}

@end
