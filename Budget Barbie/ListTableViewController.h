//
//  ListTableViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 21/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTitleViewController.h"

@interface ListTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
