//
//  WebViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"


@implementation WebViewController
{
    MBProgressHUD *hud;

}

@synthesize webView = _webView;
@synthesize webAttribute = _webAttribute;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize closeButton = _closeButton;

-(NSString *)getUrlString
{
    NSString *string = nil;
    SimpleDBGetAttributesRequest *attributesRequest = [[SimpleDBGetAttributesRequest alloc]initWithDomainName:HomeScreenDomainName andItemName:HomeScreenItemName];
    SimpleDBGetAttributesResponse *response = [[AmazonClientManager sdb] getAttributes:attributesRequest];
    for (SimpleDBAttribute *attr in response.attributes) {
        if ([attr.name isEqualToString:@"Webview"]) {
            string = attr.value;
            }
       }
    return string;
}

-(void) loadWebRequest
{
    hud = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    hud.labelText = @"Please Wait...";
    NSString *urlString = nil;
    if (self.webAttribute.value) {
        urlString = self.webAttribute.value;
    }
    else
    {
        urlString = [self getUrlString];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    self.webView.delegate = self;
    
    [self.webView loadRequest:request];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadWebRequest];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setRefreshButton:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)backButtonPressed:(id)sender 
{
    if (self.webAttribute.value) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebView Delegate


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud hide:YES];

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [hud hide:YES];
    
    // Make sure there's an actual error, and the error is not -999 (JS-induced, or WebKit bug)
    if (error != NULL && ([error code] != NSURLErrorCancelled)) {
		// NSLog(@"Error: %@", error);
		
		if ([error code] != NSURLErrorCancelled) {
			//show error alert, etc.
		}
        UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:@"Error Loading Page"
								   message: [error localizedFailureReason]
								   delegate:nil
								   cancelButtonTitle:@"OK"
								   otherButtonTitles:nil];
        [errorAlert show];
    }
}

@end
