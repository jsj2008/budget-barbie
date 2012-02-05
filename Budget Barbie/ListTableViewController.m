//
//  ListTableViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 21/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "ListTableViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "AFJSONRequestOperation.h"
#import "Place.h"

@implementation ListTableViewController
{
    NSMutableArray *places;
}

@synthesize domainName = _domainName;

#pragma mark - View lifecycle

-(void)fetchData
{
    places = [[NSMutableArray alloc]init];
    NSURL *url = [NSURL URLWithString:@"http://localhost/budget_barbie/get_places.php"];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                                                Place *place = [[Place alloc]init];
                                                                                                place.name = [obj objectForKey:@"itemName()"];
                                                                                                place.description = [obj objectForKey:@"Description"];
                                                                                                place.imageURL = [obj objectForKey:@"Image"];
                                                                                                place.placeId = [obj objectForKey:@"id"];
                                                                                                [places addObject:place];
                                                                                            }];
                                                                                            [self.tableView reloadData];
                                                                                            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"error:'%@'",error);
                                                                                        }];
    
    operation.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
    
    /*
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
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"Loading...";
    [self fetchData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.domainName = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Place *place = [places objectAtIndex:indexPath.row]; 
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    nameLabel.text = place.name;

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    CALayer *imageLayer = [imageView layer];
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 15.0;
    imageLayer.borderWidth = 2.0;
    imageLayer.borderColor = [UIColor blackColor].CGColor;
    
    [imageView setImageWithURL:[NSURL URLWithString:place.imageURL] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:[cell frame]];
    [backgroundView setImage:[UIImage imageNamed:@"backgroundCell.png"]];
    cell.backgroundView = backgroundView;
    
    return cell;
}

#pragma mark - Table view delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GetDetails"]) {
        [segue.destinationViewController setPlaceObject:sender];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place *place = [places objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"GetDetails" sender:place];

}

@end
