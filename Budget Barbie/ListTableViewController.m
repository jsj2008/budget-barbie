//
//  ListTableViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 21/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "ListTableViewController.h"
#import "AmazonClientManager.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "AFJSONRequestOperation.h"

@implementation ListTableViewController
{
    NSMutableArray *items;
}

@synthesize domainName = _domainName;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.domainName == DOMAIN_NAME_FOR_PLACES) 
        self.title = @"Places";
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.domainName = nil;
}

-(void)fetchData:(NSString *)domain
{
    NSString *selectExpression = [NSString stringWithFormat:@"Select * From `%@` where itemName() is not null order by itemname()", domain];
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc]initWithSelectExpression:selectExpression];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Fetcher", NULL);
    dispatch_async(fetchQ, ^{
        SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb]select:selectRequest];
        if (items == nil) {
            items = [[NSMutableArray alloc]initWithCapacity:[selectResponse.items count]];
        } else
            [items removeAllObjects];
        
        for (SimpleDBItem *sdbItem in selectResponse.items) {
            [items addObject:sdbItem];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        });
    });
    dispatch_release(fetchQ);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"Loading...";
    [self fetchData:self.domainName];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    SimpleDBItem *sdbItem = (SimpleDBItem *)[items objectAtIndex:indexPath.row];    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    nameLabel.text = sdbItem.name;

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    CALayer *imageLayer = [imageView layer];
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 15.0;
    imageLayer.borderWidth = 2.0;
    imageLayer.borderColor = [UIColor blackColor].CGColor;
    
    for (SimpleDBAttribute *attr in sdbItem.attributes) {
        if ([attr.name isEqualToString:@"Image"]) {
            [imageView setImageWithURL:[NSURL URLWithString:attr.value] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        }
    }
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:[cell frame]];
    [backgroundView setImage:[UIImage imageNamed:@"backgroundCell.png"]];
    cell.backgroundView = backgroundView;
    
    return cell;
}

#pragma mark - Table view delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GetDetails"]) {
        [segue.destinationViewController setItemSDB:sender];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimpleDBItem *sdbItem = (SimpleDBItem *)[items objectAtIndex:indexPath.row];    
    for (SimpleDBAttribute *attr in sdbItem.attributes) {
        if ([attr.name isEqualToString:@"SubDomain"]) {
            [self performSegueWithIdentifier:@"GetDetails" sender:sdbItem];
        }
    }
}

@end
