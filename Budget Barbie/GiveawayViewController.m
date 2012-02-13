//
//  GiveawayViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 24/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "GiveawayViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "AFJSONRequestOperation.h"
#import "Winner.h"
#import "GiveawayItem.h"
#import "MyConstants.h"

@interface GiveawayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GiveawayViewController
{
    NSMutableDictionary *headerTitles;
    NSMutableArray *giveawayItems;
    NSMutableArray *winnersList;
}
@synthesize tableView = _tableView;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIImageView *presentImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"present-nav.png"]];
        [[self navigationItem]setTitleView:presentImageView];
    }
    return self;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)fetchData
{
    giveawayItems = [[NSMutableArray alloc]init];
    winnersList = [[NSMutableArray alloc]init];
    headerTitles = [[NSMutableDictionary alloc]init];

    
    NSURL *urlHeaders = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForGiveawayHeaders]];
    NSURL *urlWinners = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForGiveawayWinners]];
    NSURL *urlGiveaways = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForGiveawayItems]];

    //winners
    NSURLRequest *request1 = [NSURLRequest requestWithURL:urlWinners];
    AFJSONRequestOperation *operation1 = [AFJSONRequestOperation JSONRequestOperationWithRequest:request1 
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                                                 Winner *winner = [[Winner alloc]init];
                                                                                                 winner.name = [obj objectForKey:@"name"];
                                                                                                 winner.item = [obj objectForKey:@"item"];
                                                                                                 [winnersList addObject:winner];
                                                                                             }];
                                                                                             [self.tableView reloadData];
                                                                                             [MBProgressHUD hideHUDForView:self.tableView animated:YES];
                                                                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                             NSLog(@"error:'%@'",error);
                                                                                         }];
    //giveaways
    NSURLRequest *request2 = [NSURLRequest requestWithURL:urlGiveaways];
    AFJSONRequestOperation *operation2 = [AFJSONRequestOperation JSONRequestOperationWithRequest:request2 
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                                                 GiveawayItem *giveawayItem = [[GiveawayItem alloc]init];
                                                                                                 giveawayItem.item = [obj objectForKey:@"item"];
                                                                                                 giveawayItem.imageURL = [obj objectForKey:@"image"];
                                                                                                 [giveawayItems addObject:giveawayItem];
                                                                                             }];
                                                                                             [self.tableView reloadData];
                                                                                             [MBProgressHUD hideHUDForView:self.tableView animated:YES];
                                                                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                             NSLog(@"error:'%@'",error);
                                                                                         }];
    //headers
    NSURLRequest *request3 = [NSURLRequest requestWithURL:urlHeaders];
    AFJSONRequestOperation *operation3 = [AFJSONRequestOperation JSONRequestOperationWithRequest:request3 
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             headerTitles = JSON;
                                                                                             [self.tableView reloadData];
                                                                                             [MBProgressHUD hideHUDForView:self.tableView animated:YES];
                                                                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                             NSLog(@"error:'%@'",error);
                                                                                         }];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:operation1,operation2,operation3,nil];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperations:array waitUntilFinished:NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"Loading..";
    [self fetchData];
    
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma UITableview Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customSectionHeaderView;
    UILabel *titleLabel;
    UIFont *labelFont;
    
    customSectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0)];
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 30.0)];
    labelFont = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:17];
    
    customSectionHeaderView.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = labelFont;
    
    if (section == 0) 
        titleLabel.text = [headerTitles objectForKey:@"giveaway"];
    else
        titleLabel.text = [headerTitles objectForKey:@"winners"];
    
    [customSectionHeaderView addSubview:titleLabel];
    
    return customSectionHeaderView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [giveawayItems count] + 1;
    } else
        return [winnersList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row < [giveawayItems count])
            return 132.0;
        else
            return 76.0;
    }
    else
    {
        return 47.0;
    }
}

-(UIImageView *)customiseCellBackground:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionRows = [self.tableView numberOfRowsInSection:[indexPath section]];
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:[cell frame]];
    if (indexPath.row == 0)
        [backgroundView setImage:[UIImage imageNamed:@"Table_top.png"]];
    else if (indexPath.row == sectionRows-1)
        [backgroundView setImage:[UIImage imageNamed:@"Table_bottom.png"]];
    else
        [backgroundView setImage:[UIImage imageNamed:@"Table_mid.png"]];

    return backgroundView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *giveawayItemCell = @"giveawayItemCell";
    static NSString *commentCell = @"commentCell";
    static NSString *winnerCell = @"winnerCell";
    
    if (indexPath.section == 0) {
        if (indexPath.row < [giveawayItems count]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:giveawayItemCell];
            
            //image
            UIImageView *giftImageView = (UIImageView *)[cell viewWithTag:1];
            CALayer *imageLayer = [giftImageView layer];
            imageLayer.masksToBounds = YES;
            imageLayer.cornerRadius = 10.0;
            imageLayer.borderWidth = 1.5;
            imageLayer.borderColor = [UIColor blackColor].CGColor;
            
            GiveawayItem *item = [giveawayItems objectAtIndex:indexPath.row];
            [giftImageView setImageWithURL:[NSURL URLWithString:item.imageURL] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
            
            //name
            UILabel *itemName = (UILabel *)[cell viewWithTag:2];
            itemName.text = item.item;
            
            cell.backgroundView = [self customiseCellBackground:cell cellForRowAtIndexPath:indexPath];
            return cell;
        }
        else 
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCell];
            cell.backgroundView = [self customiseCellBackground:cell cellForRowAtIndexPath:indexPath];

            return cell;
        }
    } 
    else 
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:winnerCell];
        UILabel *winnerName = (UILabel *)[cell viewWithTag:3];
        UILabel *winnerItem = (UILabel *)[cell viewWithTag:4];

        Winner *winner = [winnersList objectAtIndex:indexPath.row];
        winnerName.text = winner.name;
        winnerItem.text = winner.item;
        
        cell.backgroundView = [self customiseCellBackground:cell cellForRowAtIndexPath:indexPath];
        
        return cell;
    }
}



@end
