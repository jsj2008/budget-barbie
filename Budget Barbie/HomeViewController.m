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

#define ANIMATE_DURATION 0.8

@implementation HomeViewController
{
    SystemSoundID soundID;
}

@synthesize budgetButton = _budgetButton;
@synthesize specialButton = _specialButton;
@synthesize videoButton = _videoButton;
@synthesize giveawayButton = _feedbackButton;
@synthesize presentImage = _presentImage;


#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.budgetButton moveTo:CGPointMake(-32.0, 31.0) duration:ANIMATE_DURATION delay:0.0 option:UIViewAnimationCurveLinear];
    [self.specialButton moveTo:CGPointMake(108, 123) duration:ANIMATE_DURATION delay:0.0 option:UIViewAnimationCurveLinear];
    [self.videoButton moveTo:CGPointMake(-32.0, 213.0) duration:ANIMATE_DURATION delay:0.0 option:UIViewAnimationCurveLinear];
    [self.giveawayButton moveTo:CGPointMake(108, 305) duration:ANIMATE_DURATION delay:0.0 option:UIViewAnimationCurveLinear];
    [self.presentImage moveTo:CGPointMake(120, 319) duration:ANIMATE_DURATION delay:0.0 option:UIViewAnimationCurveLinear];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self.budgetButton.layer removeAllAnimations];
    [self.specialButton.layer removeAllAnimations];
    [self.videoButton.layer removeAllAnimations];
    [self.giveawayButton.layer removeAllAnimations];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GetPlaces"]) {
        [segue.destinationViewController setDomainName:DOMAIN_NAME_FOR_PLACES];
    }
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


- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (IBAction)specialPressed 
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Under Construction" 
                                                   message:@"Content is currently unavailable."
                                                  delegate:self
                                         cancelButtonTitle:@"OK" 
                                         otherButtonTitles: nil];
    
    [alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end