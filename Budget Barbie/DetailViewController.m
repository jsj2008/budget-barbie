//
//  DetailViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 22/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "AFJSONRequestOperation.h"
#import "ItemBought.h"

@interface DetailViewController()

@property (nonatomic, strong) NSString *subDomain;
@property (nonatomic, assign) BOOL loadMoreSelected;

@end


@implementation DetailViewController
{
    NSMutableArray *itemsBought;
}

@synthesize subDomain = _subDomain;
@synthesize placeObject = _placeObject;
@synthesize tableView = _tableView;
@synthesize loadMoreSelected = _loadMoreSelected;

#pragma mark - View lifecycle

-(void)fetchShopsListing
{
    itemsBought = [[NSMutableArray alloc]initWithCapacity:10];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://122.248.252.119/budget_barbie/get_shops.php?id=%@",self.placeObject.placeId]];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                                                ItemBought *item = [[ItemBought alloc]init];
                                                                                                item.shop = [obj objectForKey:@"Shop"];
                                                                                                item.location = [obj objectForKey:@"Location"];
                                                                                                item.price = [obj objectForKey:@"Price"];
                                                                                                item.item = [obj objectForKey:@"itemName()"];
                                                                                                item.image = [obj objectForKey:@"Image"];
                                                                                                [itemsBought addObject:item];
                                                                                            }];
                                                                                            [self.tableView reloadData];
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"error:'%@'",error);
                                                                                        }];
    operation.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
    
    
    /*
    for (SimpleDBAttribute *attr in self.itemSDB.attributes) {
        if ([attr.name isEqualToString:@"SubDomain"]) {
            self.subDomain = attr.value;
        }
    }
    
    dispatch_queue_t fetchQ = dispatch_queue_create("SubDomain", NULL);
    dispatch_async(fetchQ, ^{
        NSString *selectExpression = [NSString stringWithFormat:@"Select * from `%@` where Shop is not null order by Shop",self.subDomain];
        SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc]initWithSelectExpression:selectExpression];
        
        SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb]select:selectRequest];
        if (self.itemsBought == nil) {
            self.itemsBought = [[NSMutableArray alloc]initWithCapacity:[selectResponse.items count]];
        } else
            [self.itemsBought removeAllObjects];
        
        for (SimpleDBItem *sdbItem in selectResponse.items) {
            [self.itemsBought addObject:sdbItem];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if ([self.itemsBought count] <= 3) self.tableView.scrollEnabled = NO; 
        });
    });
    dispatch_release(fetchQ);
*/
}

-(void)loadPlaceImage:(UITableViewCell *)cell
{
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:6];
    CALayer *imageLayer = [imageView layer];
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 10.0;
    imageLayer.borderWidth = 1.5;
    imageLayer.borderColor = [UIColor blackColor].CGColor;
    
    [imageView setImageWithURL:[NSURL URLWithString:self.placeObject.imageURL] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
    UITextView *description = (UITextView *)[cell viewWithTag:8];
    description.text = self.placeObject.description;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.placeObject.name;
    [self fetchShopsListing];
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

#pragma mark TableView Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 211.0;
    else if (indexPath.row == 1)
        return 44.0;
    else
        return 82.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.loadMoreSelected) {
        return 2;
    } else
        return [itemsBought count]+2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier3 = @"ItemBoughtCell";
    static NSString *CellIdentifier1 = @"ImageCell";
    static NSString *CellIdentifier2 = @"LoadMoreCell";

    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        [self loadPlaceImage:cell];
        
        
        
        return cell;
        
    } 
    else if (indexPath.row == 1) 
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        
        UILabel *message = (UILabel *)[cell viewWithTag:7];
        message.text = @"Tab here to find out!";

        return cell;
    } 
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        
        //item name
        UILabel *itemLabel = (UILabel *)[cell viewWithTag:2];
        ItemBought *item = [itemsBought objectAtIndex:indexPath.row-2];
        itemLabel.text = item.item;
        
        //item image
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        CALayer *imageLayer = [imageView layer];
        imageLayer.masksToBounds = YES;
        imageLayer.cornerRadius = 15.0;
        imageLayer.borderWidth = 1.5;
        imageLayer.borderColor = [UIColor blackColor].CGColor;
        [imageView setImageWithURL:[NSURL URLWithString:item.image] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];

        //shop name
        UILabel *shopLabel = (UILabel *)[cell viewWithTag:3];
        shopLabel.text = item.shop;
        //location
        UILabel *locationLabel = (UILabel *)[cell viewWithTag:4];
        locationLabel.text = item.location;
        //price
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:5];
        priceLabel.text = [NSString stringWithFormat:@"$%@",item.price];
        
        UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:[cell frame]];
        [backgroundView setImage:[UIImage imageNamed:@"detailTableCell.png"]];
        cell.backgroundView = backgroundView;
        
        return cell;
    }
}

#pragma mark TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        
        self.loadMoreSelected = !self.loadMoreSelected;
        
        if (self.loadMoreSelected) {
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i=2; i<[itemsBought count]+2; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            NSArray *insertIndexPaths = [NSArray arrayWithArray:indexPaths];
                                         
            
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
            [tableView endUpdates];
            
        } 
        else 
        {
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i=2; i<[itemsBought count]+2; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            NSArray *deleteIndexPaths = [NSArray arrayWithArray:indexPaths];
        
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
            [tableView endUpdates];
        }
    }
}

@end
