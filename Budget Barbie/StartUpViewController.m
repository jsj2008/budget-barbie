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
}


@synthesize descriptionLabel = _descriptionLabel;
@synthesize webButton = _webButton;
@synthesize staticWeekUpdateImage = _staticWeekUpdateImage;

dispatch_queue_t queue;

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

-(void)fetchSplashScreenInfo
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.webButton animated:YES];
    hud.labelText = @"Retrieving";
    hud.detailsLabelText = @"Updates";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kHostName,kHostMainDirectory,kHostPathForSplashScreen];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    dispatch_async(queue, ^{
        AFJSONRequestOperation *operation = [AFJSONRequestOperation 
                                             JSONRequestOperationWithRequest:request 
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                 webUrlstring = [JSON objectForKey:@"webview"];
                                                 self.descriptionLabel.text = [JSON objectForKey:@"description"];
                                                 UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[JSON objectForKey:@"image"]]]];
                                                 [self.webButton setBackgroundImage:image forState:UIControlStateNormal];
                                                 
                                                 self.staticWeekUpdateImage.transform = CGAffineTransformScale(self.staticWeekUpdateImage.transform, 0.1, 0.1);
                                                 [UIView animateWithDuration:0.7 animations:^{
                                                     self.staticWeekUpdateImage.alpha = 1.0;
                                                     self.staticWeekUpdateImage.transform = CGAffineTransformScale(self.staticWeekUpdateImage.transform, 10.0, 10.0);
                                                     [MBProgressHUD hideHUDForView:self.webButton animated:YES];
                                                     
                                                 }];
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                 NSLog(@"error:%@",error);
                                                 [MBProgressHUD hideHUDForView:self.webButton animated:YES];
                                                 
                                             }];
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [queue addOperation:operation];
    });

}

- (IBAction)enterClicked:(id)sender 
{
    [self playSoundEffect];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSoundEffect];
    self.staticWeekUpdateImage.alpha = 0.0;

    queue = dispatch_queue_create("com.localhost.queue",nil);
        [self fetchSplashScreenInfo];
}


- (void)viewDidUnload {
    [self unloadSoundEffect];
    [self setDescriptionLabel:nil];
    [self setWebButton:nil];
    [self setStaticWeekUpdateImage:nil];
    [super viewDidUnload];
}

-(void)dealloc
{
    dispatch_release(queue);
}

@end
