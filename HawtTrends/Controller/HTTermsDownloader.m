//
//  HTTermsDownloader.m
//  HawtTrends
//
//  Created by Pierre Felgines on 10/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTTermsDownloader.h"
#import "Reachability.h"
#import "HTTermCache.h"
#import "HTCountryQueue.h"

#define HT_TERMS_API_URL @"http://hawttrends.appspot.com/api/terms/"
#define HT_LANGUAGE_KEY @"HT_LANGUAGE_KEY"

@interface HTTermsDownloader () <UIAlertViewDelegate> {
    NSDictionary * _countryAssociations;
    UIAlertView * _alertView;
    Reachability * _internetReachability;
}

@end

@implementation HTTermsDownloader

+ (HTTermsDownloader *)sharedDownloader {
    static HTTermsDownloader * sSharedDownloader = nil;
    if (!sSharedDownloader) {
        sSharedDownloader = [[HTTermsDownloader alloc] init];
    }
    return sSharedDownloader;
}

- (void)dealloc {
    _countryAssociations = nil;
    _currentCountry = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (id)init {
    _countryAssociations = @{
                             @"ZA": @"40",
                             @"DE": @"15",
//                             @"SA": @"36",
                             @"AR": @"30",
                             @"AU": @"8",
                             @"AT": @"44",
                             @"BE": @"41",
                             @"BR": @"18",
                             @"CA": @"13",
                             @"CL": @"38",
                             @"CO": @"32",
                             @"KR": @"23",
                             @"DK": @"49",
//                             @"EG": @"29",
                             @"ES": @"26",
                             @"US": @"1",
                             @"FI": @"50",
                             @"FR": @"16",
                             @"GR": @"48",
                             @"HK": @"10",
                             @"HU": @"45",
                             @"IN": @"3",
                             @"ID": @"19",
//                             @"IL": @"6",
                             @"IT": @"27",
                             @"JP": @"4",
                             @"KE": @"37",
                             @"MY": @"34",
                             @"MX": @"21",
                             @"NG": @"52",
                             @"NO": @"51",
                             @"NL": @"17",
                             @"PH": @"25",
                             @"PL": @"31",
                             @"PT": @"47",
                             @"CZ": @"43",
                             @"RO": @"39",
                             @"GB": @"9",
                             @"RU": @"14",
                             @"SG": @"5",
                             @"SE": @"42",
                             @"CH": @"46",
                             @"TW": @"12",
//                             @"TH": @"33",
                             @"TR": @"24",
                             @"UA": @"35",
                             @"VN": @"28"
                             };

    if (self = [super init]) {
        NSString * currentCountryCode = [[NSUserDefaults standardUserDefaults] objectForKey:HT_LANGUAGE_KEY];

        NSMutableArray * countries = [NSMutableArray array];
        for (NSString * countryCode in [_countryAssociations allKeys]) {
            //        NSString * identifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCountryCode: countryCode}];
            //        NSString * country = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
            HTCountry * country = [[HTCountry alloc] init];
            country.countryCode = countryCode;
            country.webserviceCode = _countryAssociations[countryCode];
            country.displayName = [[NSLocale systemLocale] displayNameForKey:NSLocaleCountryCode value:countryCode];
            [countries addObject:country];

            if ([currentCountryCode isEqualToString:countryCode]) {
                self.currentCountry = country;
            }
            if (!_currentCountry && [countryCode isEqualToString:@"US"]) {
                self.currentCountry = country;
            }
        }

        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        [countries sortUsingDescriptors:@[sortDescriptor]];
        _countries = countries;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        _internetReachability = [Reachability reachabilityForInternetConnection];
        [_internetReachability startNotifier];
    }

    return self;
}

- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability * currentReachability = [notification object];
    NSParameterAssert([currentReachability isKindOfClass:[Reachability class]]);
    if ([currentReachability currentReachabilityStatus] != NotReachable) {
        [self downloadTerms:nil];
    }
}

- (void)setCurrentCountry:(HTCountry *)currentCountry {
    _currentCountry = currentCountry;
    [HTCountryQueue addCountry:currentCountry.displayName];
    [[NSUserDefaults standardUserDefaults] setObject:currentCountry.countryCode forKey:HT_LANGUAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self downloadTerms:nil];
}

- (NSString *)randomTerm {
    NSUInteger index = (int)(((float)rand() / (float)RAND_MAX) * self.terms.count);
    return self.terms[index];
}

- (void)downloadTerms:(void(^)(void))callback {
    _terms = @[@"Loading..."];

    NSURL * url = [NSURL URLWithString:HT_TERMS_API_URL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && !_alertView) {
                NSLog(@"ERROR => %@", error);
                [self _displayAlertViewWithErrorMessage:error.localizedDescription];
                return;
            }

            NSError * jsonError = nil;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError && !_alertView) {
                NSLog(@"ERROR => %@", jsonError.description);
                [self _displayAlertViewWithErrorMessage:@"An error occurred"];
                return ;
            }

            [HTTermCache saveTermsByCountry:json];

            _terms = [self _filteredTerms:[json objectForKey:_currentCountry.webserviceCode]];
            if (callback) {
                callback();
            }
        });
    }];
    [task resume];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _alertView && buttonIndex == 1) {
        [self downloadTerms:nil];
    }
    _alertView = nil;
}

#pragma mark - Private

- (void)_displayAlertViewWithErrorMessage:(NSString *)errorMessage {
    if (_alertView) {
        return;
    }

    _alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                            message:errorMessage
                                           delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Retry", nil];
    [_alertView show];
}

- (NSArray *)_filteredTerms:(NSArray *)terms {
    return [terms filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * term, NSDictionary *bindings) {
        return term.length < 30;
    }]];
}

@end
