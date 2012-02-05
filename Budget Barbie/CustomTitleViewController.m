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
        [[self navigationItem]setTitleView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"titleView.png"]]];
    }
    return self;
}

@end
