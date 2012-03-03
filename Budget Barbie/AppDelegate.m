//
//  AppDelegate.m
//  Budget Barbie
//
//  Created by Daniel Quek on 20/1/12.
//  Copyright (c) 2012 Cellcity. All rights reserved.
//

#import "AppDelegate.h"
#import "UAirship.h"
#import "UAPush.h"



@implementation AppDelegate


@synthesize window = _window;

-(void)customizeAppearance
{
    // UIBarButtonItem - Back
    

    UIImage *buttonBack30 = [[UIImage imageNamed:@"button_back_textured_30"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    UIImage *buttonBack24 = [[UIImage imageNamed:@"button_back_textured_24"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack24 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone]; 
    
    // UIBarButtonItem - About
    
    UIImage *button30 = [[UIImage imageNamed:@"button_textured_30"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *button24 = [[UIImage imageNamed:@"button_textured_24"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:button24 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Helvetica-Bold" size:0.0], UITextAttributeFont, nil] forState:UIControlStateNormal];

    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navbar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"navbar_bg(landscape)"] forBarMetrics:UIBarMetricsLandscapePhone];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self customizeAppearance];
   // [self failIfSimulator];
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airhship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge];//zero badge on startup
    
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
    
    return YES;
}


-(void)applicationDidBecomeActive:(UIApplication *)application
{
    UALOG(@"Application did become active.");
    [[UAPush shared] resetBadge]; //zero badge when resuming from background (iOS 4+)
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    UALOG(@"APN device token: %@", deviceToken);
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UALOG(@"Received remote notification: %@", userInfo);
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [[UAPush shared] handleNotification:userInfo applicationState:appState];
    [[UAPush shared] resetBadge]; // zero badge after push received
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [UAirship land];
}

- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                            message:@"You will not be able to recieve push notifications in the simulator."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [someError show];
    }
}

@end
