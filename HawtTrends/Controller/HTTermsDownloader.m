//
//  HTTermsDownloader.m
//  HawtTrends
//
//  Created by Pierre Felgines on 10/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTTermsDownloader.h"

#define HT_TERMS_API_URL @"http://hawttrends.appspot.com/api/terms/"
#define HT_LANGUAGE_KEY @"HT_LANGUAGE_KEY"

@interface HTTermsDownloader () {
    NSDictionary * _countryAssociations;
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
}

- (id)init {
    _countryAssociations = @{
                             @"ZA": @"40",
                             @"DE": @"15",
                             @"SA": @"36",
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
                             @"EG": @"29",
                             @"ES": @"26",
                             @"US": @"1",
                             @"FI": @"50",
                             @"FR": @"16",
                             @"GR": @"48",
                             @"HK": @"10",
                             @"HU": @"45",
                             @"IN": @"3",
                             @"ID": @"19",
                             @"IL": @"6",
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
                             @"TH": @"33",
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
    }

    return self;
}

- (void)setCurrentCountry:(HTCountry *)currentCountry {
    _currentCountry = currentCountry;
    [[NSUserDefaults standardUserDefaults] setObject:currentCountry.countryCode forKey:HT_LANGUAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self downloadTerms];
}

- (NSString *)randomTerm {
    NSUInteger index = (int)(((float)rand() / (float)RAND_MAX) * self.terms.count);
    return self.terms[index];
}

- (void)downloadTerms {
    _terms = @[@"Loading..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error = nil;
        NSString * jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:HT_TERMS_API_URL] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"ERROR : %@", error.description);
            return ;
        }

        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error) {
            NSLog(@"ERROR : %@", error.description);
            return ;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            _terms = [json objectForKey:_currentCountry.webserviceCode];
        });
    });
}

@end
