//
//  DetailViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 22/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Place *placeObject;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
