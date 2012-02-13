//
//  DetailViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 22/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFJSONRequestOperation.h"
#import "MBProgressHUD.h"
#import "Place.h"
#import "MyConstants.h"
#import "ItemBought.h"
#import "ImageDetailViewController.h"
#import "SpecialItem.h"
#import "YouTubeView.h"

@interface DetailViewController()

@property (nonatomic, assign) BOOL loadMoreSelected;

@end


@implementation DetailViewController
{
    BOOL loaded;
    NSMutableArray *itemsBought;
}

@synthesize placeObject = _placeObject;
@synthesize tableView = _tableView;
@synthesize loadMoreSelected = _loadMoreSelected;
@synthesize specialItem = _specialItem;
@synthesize youtubeView = _youtubeView;

#pragma mark - View lifecycle

-(void)fetchShopsListing
{
    itemsBought = [NSMutableArray new];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@?id=%@",kHostName,kHostMainDirectory,kHostPathForGetShops,self.placeObject.placeId]];
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
                                                                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                                            [self.tableView reloadData];
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                                            NSLog(@"error:'%@'",error);
                                                                                        }];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}

-(void)fetchSpecialListing
{
    itemsBought = [NSMutableArray new];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?id=%@",kHostName,kHostMainDirectory,kHostPathForSpecialDetails,self.specialItem.specialID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
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
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             [self.tableView reloadData];
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             NSLog(@"error:'%@'",error);
                                         }];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}

-(void)loadPlaceImage:(UITableViewCell *)cell
{

    if (self.placeObject) {
        NSString *videoURL = self.placeObject.videoURL;
        self.youtubeView = [[YouTubeView alloc]initWithStringAsURL:videoURL frame:CGRectMake(180, 10, 128, 107)];
        [cell addSubview:self.youtubeView];
        
        UITextView *description = (UITextView *)[cell viewWithTag:8];
        description.text = self.placeObject.description;
    } else {
        NSString *videoURL = self.specialItem.videoURL;
        self.youtubeView = [[YouTubeView alloc]initWithStringAsURL:videoURL frame:CGRectMake(180, 10, 128, 107)];
        [cell addSubview:self.youtubeView];

        UITextView *description = (UITextView *)[cell viewWithTag:8];
        description.text = self.specialItem.description;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    if (self.placeObject) {
        self.title = self.placeObject.name;
        [self fetchShopsListing];
    } else {
        self.title = self.specialItem.title;
        [self fetchSpecialListing];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading now...";
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark TableView Datasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 135.0;
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
        if (!loaded) {
            loaded = YES;
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            [self loadPlaceImage:cell];
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
            return cell;
        }
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
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Loading now...";
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else 
        {
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i=2; i<[itemsBought count]+2; i++) 
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            
            NSArray *deleteIndexPaths = [NSArray arrayWithArray:indexPaths];
        
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    } 
    else if (indexPath.row >= 2) {
        ItemBought *item = [itemsBought objectAtIndex:indexPath.row-2];    
        ImageDetailViewController *controller = [[ImageDetailViewController alloc] initWithNibName:@"ImageDetailViewController" bundle:nil];
        controller.itemBought = item;
        [controller presentInParentViewController:self];
    }
}

@end
