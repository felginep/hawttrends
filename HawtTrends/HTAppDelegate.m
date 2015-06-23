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
#import "HTSharedConstants.h"
#import "NSArray+HawtTrends.h"

@implementation HTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    


    HTMainViewController * mainViewController = [[HTMainViewController alloc] init];
    self.window.rootViewController = mainViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[HTTermsDownloader sharedDownloader] downloadTerms:nil];
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    UIBackgroundTaskIdentifier taskIdentifier = [application beginBackgroundTaskWithName:@"WatchKitBackgroundTask" expirationHandler:^{
        // TODO: Handle task expiration
    }];

    HTCountry * country = [HTTermsDownloader sharedDownloader].currentCountry;

    HTWatchAction action = [userInfo[kHTWatchAction] integerValue];
    switch (action) {
        case HTWatchActionFetchTerms: {
            [[HTTermsDownloader sharedDownloader] downloadTerms:^{
                NSArray * allTerms = [HTTermsDownloader sharedDownloader].terms;
                if (!allTerms) { allTerms = @[]; }
                NSLog(@" => %@", @{ kHTWatchResponse: allTerms, kHTWatchUserInfos: country.displayName });
                reply(@{ kHTWatchResponse: allTerms, kHTWatchUserInfos: country.displayName });
                [application endBackgroundTask:taskIdentifier];
            }];
        } break;
        case HTWatchActionCurrentCountry: {
            reply(@{ kHTWatchResponse: country.displayName });
            [application endBackgroundTask:taskIdentifier];
        } break;
        case HTWatchActionCountries: {
            NSArray * countryNames = [[HTTermsDownloader sharedDownloader].countries map:^id(HTCountry * c) { return c.displayName; }];
            reply(@{ kHTWatchResponse: countryNames });
            [application endBackgroundTask:taskIdentifier];
        } break;
        case HTWatchActionSetCurrentCountry: {
            NSString * currentCountryName = userInfo[kHTWatchUserInfos];
            HTCountry * currentCountry = nil;
            for (HTCountry * country in [HTTermsDownloader sharedDownloader].countries) {
                if ([country.displayName isEqualToString:currentCountryName]) {
                    currentCountry = country;
                    break;
                }
            }

            BOOL success = currentCountry != nil;
            if (currentCountry) {
                [HTTermsDownloader sharedDownloader].currentCountry = currentCountry;
            }
            reply(@{ kHTWatchResponse: @(success) });
            [application endBackgroundTask:taskIdentifier];
        } break;
        default:
            break;
    }
}

@end
