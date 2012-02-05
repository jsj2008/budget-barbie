//
//  WebViewController.h
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "AmazonClientManager.h"
#import "MBProgressHUD.h"
#import "CustomTitleViewController.h"
#import <UIKit/UIKit.h>

@interface WebViewController : CustomTitleViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) SimpleDBAttribute *webAttribute;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end
