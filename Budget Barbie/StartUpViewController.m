//
//  StartUpViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "StartUpViewController.h"
#import "WebViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import "MyConstants.h"
#import "AFJSONRequestOperation.h"

@implementation StartUpViewController
{
    NSString *webUrlstring;
    SystemSoundID soundID;
 //   ADBannerView *_bannerView;
}


@synthesize descriptionLabel = _descriptionLabel;
@synthesize webButton = _webButton;
@synthesize contentView = _contentView;
@synthesize staticWeekUpdateImage = _staticWeekUpdateImage;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
     //   _bannerView = [[ADBannerView alloc]initWithCoder:coder];
       // _bannerView.delegate = self;
    }
    return self;
}

/*
- (void)layoutAnimated:(BOOL)animated
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _contentView.frame = contentFrame;
        [_contentView layoutIfNeeded];
        _bannerView.frame = bannerFrame;
    }];
}
*/

- (void)loadSoundEffect
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"startingSound.wav" ofType:nil];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil)
	{
		NSLog(@"NSURL is nil for path: %@", path);
		return;
	}
    
	OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
	if (error != kAudioServicesNoError)
	{
		NSLog(@"Error code %ld loading sound at path: %@", error, path);
		return;
	}
}

- (void)unloadSoundEffect
{
	AudioServicesDisposeSystemSoundID(soundID);
	soundID = 0;
}

- (void)playSoundEffect
{
	AudioServicesPlaySystemSound(soundID);
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushWebView"]) {
        [segue.destinationViewController setUrlString:webUrlstring];
    }
}

-(void)loadImage:(NSString *)imageURL
{
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webButton setBackgroundImage:image forState:UIControlStateNormal];
            self.staticWeekUpdateImage.transform = CGAffineTransformScale(self.staticWeekUpdateImage.transform, 0.1, 0.1);
            [UIView animateWithDuration:0.7 animations:^{
                self.staticWeekUpdateImage.alpha = 1.0;
                self.staticWeekUpdateImage.transform = CGAffineTransformScale(self.staticWeekUpdateImage.transform, 10.0, 10.0);
                [MBProgressHUD hideHUDForView:self.webButton animated:YES];
            }];
        });
    });

    dispatch_release(queue);
}

-(void)fetchSplashScreenInfo
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.webButton animated:YES];
    hud.labelText = @"Retrieving";
    hud.detailsLabelText = @"Updates";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForSplashScreen];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation 
                                             JSONRequestOperationWithRequest:request 
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                 webUrlstring = [JSON objectForKey:@"webview"];
                                                 self.descriptionLabel.text = [JSON objectForKey:@"description"];
                                                 NSString *imageURL = [JSON objectForKey:@"image"];
                                                 [self loadImage:imageURL];
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                 NSLog(@"error:%@",error);
                                                 [MBProgressHUD hideHUDForView:self.webButton animated:YES];
                                                 
                                             }];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];

}

- (IBAction)enterClicked:(id)sender 
{
    [self playSoundEffect];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
 //   [self.view addSubview:_bannerView];
    
    [self loadSoundEffect];
    self.staticWeekUpdateImage.alpha = 0.0;

    [self fetchSplashScreenInfo];
}

/*
-(void)viewDidAppear:(BOOL)animated
{
 //   [self layoutAnimated:NO];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
  //  [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
  //  [self layoutAnimated:YES];
}
*/


- (void)viewDidUnload {
    [self unloadSoundEffect];
    [self setDescriptionLabel:nil];
    [self setWebButton:nil];
    [self setStaticWeekUpdateImage:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}


@end
