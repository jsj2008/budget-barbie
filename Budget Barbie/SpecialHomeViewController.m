//
//  SpecialHomeViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 12/2/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "SpecialHomeViewController.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "SpecialItem.h"
#import "DetailViewController.h"
#import "MyConstants.h"

@implementation SpecialHomeViewController
{
    NSMutableArray *items;
}

@synthesize carousel = _carousel;

#pragma mark - View lifecycle

-(void) setUp
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading..";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForSpecialMain];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    items = [NSMutableArray array];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [JSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                 SpecialItem *item = [[SpecialItem alloc]init];
                                                 item.specialID = [obj objectForKey:@"id"];
                                                 item.imageURL = [obj objectForKey:@"image"];
                                                 item.title = [obj objectForKey:@"title"];
                                                 item.description = [obj objectForKey:@"description"];
                                                 [items addObject:item];
                                             }];
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             [self.carousel reloadData];
                                             
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"Error:'%@'",error);
                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                         }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.carousel.type = iCarouselTypeCylinder;
    [self setUp];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

-(NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}


-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    SpecialItem *item = [items objectAtIndex:index];
    UILabel *label = nil;
    UILabel *detailLabel = nil;
	if (view == nil)
	{
        UIImageView *imageView = [[UIImageView alloc]init];
        [imageView setImageWithURL:[NSURL URLWithString:item.imageURL] placeholderImage:[UIImage imageNamed:@"DetailPlaceholder"]];
        imageView.frame = CGRectMake(0, 0, 250, 250);
        imageView.contentMode = UIViewContentModeScaleToFill;
		view = imageView;
		label = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 250, 20)];
        label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [label.font fontWithSize:14];
		[view addSubview:label];
        UIView *blackView = [[UIView alloc]initWithFrame:CGRectMake(0, 220, 250, 30)];
        blackView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        [view addSubview:blackView];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 220, 240, 30)];
        detailLabel.numberOfLines = 0;
        detailLabel.textColor = [UIColor whiteColor];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.textAlignment = UITextAlignmentLeft;
		detailLabel.font = [detailLabel.font fontWithSize:10];
		[view addSubview:detailLabel];
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
	label.text = item.title;
    detailLabel.text = [NSString stringWithFormat:@"%@", item.description];
	
	return view;
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [self performSegueWithIdentifier:@"SpecialDetails" sender:[items objectAtIndex:index]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SpecialDetails"]) {
        [segue.destinationViewController setSpecialItem:sender];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
