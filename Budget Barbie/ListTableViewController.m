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
#import "AFHTTPClient.h"
#import "Place.h"
#import "UIDevice+IdentifierAddition.h"
#import "MyConstants.h"

@implementation ListTableViewController
{
    NSMutableArray *places;
}

@synthesize domainName = _domainName;

#pragma mark - View lifecycle


-(void)fetchData
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.labelText = @"Loading...";
    places = [[NSMutableArray alloc]initWithCapacity:10];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForGetPlaces]];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                 Place *place = [[Place alloc]init];
                                                 place.name = [obj objectForKey:@"itemName()"];
                                                 place.description = [obj objectForKey:@"Description"];
                                                 place.imageURL = [obj objectForKey:@"Image"];
                                                 place.placeId = [obj objectForKey:@"id"];
                                                 place.likes = [obj objectForKey:@"likes"];
                                                 place.videoURL = [obj objectForKey:@"Video"];
                                                 [places addObject:place];
                                             }];
                                             [self.tableView reloadData];
                                             [MBProgressHUD hideHUDForView:self.tableView animated:YES];
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"error:'%@'",error);
                                         }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}

-(void) loadAlertView:(NSString *)alertMsg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Budget Barbie" 
                                                   message:alertMsg
                                                  delegate:self 
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}

-(void)likeRequest:(int)placeId
{
	NSString *deviceUDID = [[UIDevice currentDevice]uniqueDeviceIdentifier];
    NSString *placeIdString = [NSString stringWithFormat:@"%d",placeId];
    
    NSURL *url = [NSURL URLWithString:@"http://122.248.252.119/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithBaseURL:url];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            placeIdString, @"places_id",
                            deviceUDID, @"device_id",
                            nil];

    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/budget_barbie/likes.php" parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation 
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             for (Place *place in places) {
                                                 if ([place.placeId intValue] == placeId) {
                                                     place.likes = [[JSON objectForKey:@"likes"]stringValue];
                                                     int reloadRowIndex = [places indexOfObject:place];
                                                     NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:reloadRowIndex inSection:0]];
                                                     [self.tableView beginUpdates];
                                                     [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.tableView endUpdates];
                                                 }
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             [self loadAlertView:[JSON objectForKey:@"result"]];
                                         }];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem]setTitleView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"titleView.png"]]];


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
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1002];
    nameLabel.text = place.name;
    
    UIButton *button = (UIButton *)[cell.contentView.subviews objectAtIndex:0];
    [button setTag:[place.placeId intValue]];
    [button addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *likeLabel = (UILabel *)[cell viewWithTag:1003];
    likeLabel.text = place.likes;
    

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001];
  /*  CALayer *imageLayer = [imageView layer];
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 10.0;
    imageLayer.borderWidth = 0.5;
    imageLayer.borderColor = [UIColor grayColor].CGColor;
   */ 
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

- (void)likeButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int placeId = button.tag;
    [self likeRequest:placeId];
}
@end
