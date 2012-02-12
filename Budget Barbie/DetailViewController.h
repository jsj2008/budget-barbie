//
//  DetailViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 22/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;
@class SpecialItem;

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Place *placeObject;
@property (nonatomic, strong) SpecialItem *specialItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
