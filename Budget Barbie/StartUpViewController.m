//
//  StartUpViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "StartUpViewController.h"
#import "WebViewController.h"
#import "GADBannerView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import "MyConstants.h"
#import "AFJSONRequestOperation.h"
#import "SplashScreen.h"

@implementation StartUpViewController
{
    NSString *webUrlstring;
    SystemSoundID soundID;

    GADBannerView *bannerView_;
}


@synthesize descriptionLabel = _descriptionLabel;
@synthesize webButton = _webButton;
@synthesize contentView = _contentView;
@synthesize staticWeekUpdateImage = _staticWeekUpdateImage;


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
    
    [SplashScreen getSplashScreenInfoWithBlock:^(NSArray *info) {
        SplashScreen *splashScreen = [info objectAtIndex:0];
        webUrlstring = splashScreen.videoURLString;
        self.descriptionLabel.text = splashScreen.description;
        [self loadImage:splashScreen.imageURL];
        
    }];
    
    /*
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
*/
}

- (IBAction)enterClicked:(id)sender 
{
    [self playSoundEffect];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    bannerView_ = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            self.view.frame.size.height -
                                            GAD_SIZE_320x50.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = MY_BANNER_UNIT_ID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    
    [self loadSoundEffect];
    self.staticWeekUpdateImage.alpha = 0.0;

    [self fetchSplashScreenInfo];
}



- (void)viewDidUnload {
    [self unloadSoundEffect];
    [self setDescriptionLabel:nil];
    [self setWebButton:nil];
    [self setStaticWeekUpdateImage:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}


@end
