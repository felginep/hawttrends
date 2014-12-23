//
//  HTAppDelegate.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTAppDelegate.h"
#import "HTMainViewController.h"
#import "HTTermsDownloader.h"

@implementation HTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[HTTermsDownloader sharedDownloader] downloadTerms:nil];

    HTMainViewController * mainViewController = [[HTMainViewController alloc] init];
    self.window.rootViewController = mainViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
