//
//  StartUpViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "StartUpViewController.h"
#import "AmazonClientManager.h"
#import "WebViewController.h"




@implementation StartUpViewController
{
    SimpleDBAttribute *webAttribute;
}

@synthesize descriptionLabel = _descriptionLabel;
@synthesize webButton = _webButton;
@synthesize staticWeekUpdateImage = _staticWeekUpdateImage;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushWebView"]) {
        [segue.destinationViewController setWebAttribute:webAttribute];
    }
}

-(void)showImage
{
    SimpleDBGetAttributesRequest *attributesRequest = [[SimpleDBGetAttributesRequest alloc]initWithDomainName:HomeScreenDomainName andItemName:HomeScreenItemName];
    
    __block UIImage *image;
    __block NSString *description;
    dispatch_queue_t fetchQ = dispatch_queue_create("Attributes", NULL);
    dispatch_async(fetchQ, ^{
        SimpleDBGetAttributesResponse *response = [[AmazonClientManager sdb] getAttributes:attributesRequest];
        for (SimpleDBAttribute *attr in response.attributes) {
            if ([attr.name isEqualToString:@"Image"]) {
                image = [UIImage imageWithData:
                                  [NSData dataWithContentsOfURL:
                                   [NSURL URLWithString:attr.value]]];
            }
            else if ([attr.name isEqualToString:@"Description"])
            {
                description = attr.value;
            } else
                webAttribute = attr;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.staticWeekUpdateImage.transform = CGAffineTransformScale(self.staticWeekUpdateImage.transform, 0.1, 0.1);
            [UIView animateWithDuration:0.7 animations:^{
                self.staticWeekUpdateImage.alpha = 1.0;
                self.staticWeekUpdateImage.transform = CGAffineTransformScale(self.staticWeekUpdateImage.transform, 10.0, 10.0);
            }];
            [MBProgressHUD hideHUDForView:self.webButton animated:YES];
            [self.webButton setBackgroundImage:image forState:UIControlStateNormal];
            self.descriptionLabel.text = description;
        });
    });

    dispatch_release(fetchQ);

}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.staticWeekUpdateImage.alpha = 0.0;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.webButton animated:YES];
    hud.labelText = @"Retrieving";
    hud.detailsLabelText = @"Updates";
    
    [self showImage];
}


- (void)viewDidUnload {
    [self setDescriptionLabel:nil];
    [self setWebButton:nil];
    [self setStaticWeekUpdateImage:nil];
    [super viewDidUnload];
}
@end
