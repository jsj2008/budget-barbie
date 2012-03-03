//
//  HomeViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "HomeViewController.h"
#import "UIView+Animation.h"
#import "ListTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation HomeViewController
{
    SystemSoundID soundID;
    BOOL didAnimate;
}

@synthesize contentView = _contentView;
@synthesize budgetButton = _budgetButton;
@synthesize specialButton = _specialButton;
@synthesize videoButton = _videoButton;
@synthesize giveawayButton = _feedbackButton;
@synthesize presentImage = _presentImage;


#pragma mark - View lifecycle

-(void)animateButtons
{
    if (!didAnimate) {
        [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
            self.budgetButton.center = CGPointMake(98, 76);
            self.specialButton.center = CGPointMake(134, 166);
            self.videoButton.center = CGPointMake(186, 254);
            self.giveawayButton.center = CGPointMake(222, 344);
        } completion:^(BOOL finished) {
            self.presentImage.alpha = 1.0;
            didAnimate = YES;
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self animateButtons];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


- (void)loadSoundEffect
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"92909__robinhood76__01526-swoosh-2.wav" ofType:nil];
    
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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.budgetButton.center = CGPointMake(0-self.budgetButton.frame.size.width/2, self.budgetButton.frame.origin.y+self.budgetButton.frame.size.height/2);
    self.specialButton.center = CGPointMake(0-self.specialButton.frame.size.width/2, self.specialButton.frame.origin.y+self.specialButton.frame.size.height/2);
    self.videoButton.center = CGPointMake(0-self.videoButton.frame.size.width/2, self.videoButton.frame.origin.y+self.videoButton.frame.size.height/2);
    self.giveawayButton.center = CGPointMake(0-self.giveawayButton.frame.size.width/2, self.giveawayButton.frame.origin.y+self.giveawayButton.frame.size.height/2);
    self.presentImage.alpha = 0.0;
    
    [self loadSoundEffect];
    [self performSelector:@selector(playSoundEffect) withObject:nil afterDelay:0.6];

}


- (void)viewDidUnload
{
    [self setBudgetButton:nil];
    [self setSpecialButton:nil];
    [self setVideoButton:nil];
    [self setGiveawayButton:nil];
    [self unloadSoundEffect];
    [self setPresentImage:nil];
    [super viewDidUnload];
}



@end
