//
//  WebViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "AFJSONRequestOperation.h"
#import "MyConstants.h"


@implementation WebViewController
{
    MBProgressHUD *hud;
    NSString *webUrlString;
}

@synthesize webView = _webView;
@synthesize urlString = _urlString;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize closeButton = _closeButton;

-(void)getUrlString
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForSplashScreen];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation 
                                         JSONRequestOperationWithRequest:request 
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             webUrlString = [JSON objectForKey:@"webview"];
                                             NSURLRequest *requestVideo = [NSURLRequest requestWithURL:[NSURL URLWithString:webUrlString]];
                                             self.webView.delegate = self;
                                             [self.webView loadRequest:requestVideo];
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"error:%@",error);
                                         }];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];

}

-(void) loadWebRequest
{
    hud = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    hud.labelText = @"Please Wait...";
    
    if (self.urlString) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        self.webView.delegate = self;
        [self.webView loadRequest:request];
    }
    else 
    {
        [self getUrlString];
    }
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
    [self setUrlString:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)backButtonPressed:(id)sender 
{
    if (self.urlString) {
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
    
    if (error != NULL && ([error code] != NSURLErrorCancelled))
    {
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
