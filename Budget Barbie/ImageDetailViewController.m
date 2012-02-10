//
//  ImageDetailViewController.m
//  Budget Barbie
//
//  Created by Daniel Quek on 10/2/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "ImageDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GradientView.h"
#import "UIImageView+WebCache.h"


@interface ImageDetailViewController()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

- (IBAction)close:(id)sender;

@end

@implementation ImageDetailViewController
{
    GradientView *gradientView;
}
@synthesize closeButton = _closeButton;
@synthesize imageView = _imageView;
@synthesize itemName = _itemName;
@synthesize backgroundView = _backgroundView;

@synthesize itemBought = _itemBought;



-(void) updateUI
{
    self.itemName.text = self.itemBought.item;
	[self.imageView setImageWithURL:[NSURL URLWithString:self.itemBought.image] placeholderImage:[UIImage imageNamed:@"DetailPlaceholder"]];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
	self.backgroundView.layer.borderWidth = 3.0f;
	self.backgroundView.layer.cornerRadius = 10.0f;
    
    if (self.itemBought != nil) [self updateUI];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setItemName:nil];
    [self setBackgroundView:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
    self.itemBought = nil;

}

- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	CGRect rect = self.closeButton.frame;
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		rect.origin = CGPointMake(28, 61);
	} else {
		rect.origin = CGPointMake(108, 0);
	}
	self.closeButton.frame = rect;
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
	gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
	[parentViewController.view addSubview:gradientView];
    
	CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
	fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
	fadeAnimation.duration = 0.1;
	[gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    
	self.view.frame = parentViewController.view.bounds;
	[self layoutForInterfaceOrientation:parentViewController.interfaceOrientation];
	[parentViewController.view addSubview:self.view];
	[parentViewController addChildViewController:self];
    
    
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
	bounceAnimation.duration = 0.4;
	bounceAnimation.delegate = self;
    
	bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0f],
                              nil];
    
	bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    
	bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       nil];
    
	[self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
     
}

-(IBAction)close:(id)sender
{
    [self dismissFromParentViewControllerWithAnimationType:ImageDetailViewControllerAnimationTypeFade];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	[self didMoveToParentViewController:self.parentViewController];	
}

- (void)dismissFromParentViewControllerWithAnimationType:(ImageDetailViewControllerAnimationType)animationType;
{
	[self willMoveToParentViewController:nil];
    
	[UIView animateWithDuration:0.4 animations:^{
		if (animationType == ImageDetailViewControllerAnimationTypeSlide) {
			CGRect rect = self.view.bounds;
			rect.origin.y += rect.size.height;
			self.view.frame = rect;
		} else {
			self.view.alpha = 0.0f;
		}
		gradientView.alpha = 0.0f;
	}
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];	
                         [gradientView removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self layoutForInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
