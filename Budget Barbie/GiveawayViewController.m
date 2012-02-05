//
//  GiveawayViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 24/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "GiveawayViewController.h"
#import "AmazonClientManager.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface GiveawayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GiveawayViewController
{
    NSMutableArray *headerTitles;
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
    NSString *selectExpression = [NSString stringWithFormat:@"Select * From `%@` where itemName() is not null order by itemname()", GiveawayHeaderDomain];
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc]initWithSelectExpression:selectExpression];
    
    NSString *selectGiveAwayExpression = [NSString stringWithFormat:@"Select * From `%@` where itemName() is not null order by itemname()", GiveawayGiftsDomain];
    SimpleDBSelectRequest *selectGiveAwayRequest = [[SimpleDBSelectRequest alloc]initWithSelectExpression:selectGiveAwayExpression];
    
    NSString *selectWinnersExpression = [NSString stringWithFormat:@"Select * From `%@` where itemName() is not null order by itemname()", GiveawayWinnersDomain];
    SimpleDBSelectRequest *selectWinnersRequest = [[SimpleDBSelectRequest alloc]initWithSelectExpression:selectWinnersExpression];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Fetcher", NULL);
    dispatch_async(fetchQ, ^{
        // titles
        SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb]select:selectRequest];
        if (headerTitles == nil) {
            headerTitles = [[NSMutableArray alloc]initWithCapacity:[selectResponse.items count]];
        } else
            [headerTitles removeAllObjects];
        for (SimpleDBItem *sdbItem in selectResponse.items)
            [headerTitles addObject:sdbItem];
        
        //giveaways
        SimpleDBSelectResponse *selectGiveAwayResponse = [[AmazonClientManager sdb]select:selectGiveAwayRequest];
        if (giveawayItems == nil) {
            giveawayItems = [[NSMutableArray alloc]initWithCapacity:[selectGiveAwayResponse.items count]];
        } else
            [giveawayItems removeAllObjects];
        for (SimpleDBItem *sdbItem in selectGiveAwayResponse.items)
            [giveawayItems addObject:sdbItem];
        
        //winners
        SimpleDBSelectResponse *selectWinnersResponse = [[AmazonClientManager sdb]select:selectWinnersRequest];
        if (winnersList == nil) {
            winnersList = [[NSMutableArray alloc]initWithCapacity:[selectWinnersResponse.items count]];
        } else
            [winnersList removeAllObjects];
        for (SimpleDBItem *sdbItem in selectWinnersResponse.items)
            [winnersList addObject:sdbItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        });
    });
    dispatch_release(fetchQ);
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
    
    if (section == 0) {
        SimpleDBItem *item = (SimpleDBItem *)[headerTitles objectAtIndex:0];
        SimpleDBAttribute *attr = (SimpleDBAttribute *)[item.attributes objectAtIndex:0];
        titleLabel.text = attr.value;
    }
    else
    {
        SimpleDBItem *item = (SimpleDBItem *)[headerTitles objectAtIndex:1];
        SimpleDBAttribute *attr = (SimpleDBAttribute *)[item.attributes objectAtIndex:0];
        titleLabel.text = attr.value;
    }
    
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
        [backgroundView setImage:[UIImage imageNamed:@"giveawayCell.png"]];
    else if (indexPath.row == sectionRows-1)
        [backgroundView setImage:[UIImage imageNamed:@"giveawayCell.png"]];
    else
        [backgroundView setImage:[UIImage imageNamed:@"giveawayCell.png"]];

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
            
            SimpleDBItem *item = (SimpleDBItem *)[giveawayItems objectAtIndex:indexPath.row];
            SimpleDBAttribute *attr = (SimpleDBAttribute *)[item.attributes objectAtIndex:0];
            [giftImageView setImageWithURL:[NSURL URLWithString:attr.value] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
            
            //name
            UILabel *itemName = (UILabel *)[cell viewWithTag:2];
            itemName.text = item.name;
            
        
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

        SimpleDBItem *item = (SimpleDBItem *)[winnersList objectAtIndex:indexPath.row];
        SimpleDBAttribute *attr = (SimpleDBAttribute *)[item.attributes objectAtIndex:0];

        winnerName.text = item.name;
        winnerItem.text = attr.value;
        
        cell.backgroundView = [self customiseCellBackground:cell cellForRowAtIndexPath:indexPath];
        
        return cell;
    }
}



@end
