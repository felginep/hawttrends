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
    [_countryAssociations release], _countryAssociations = nil;
    [_currentCountry release], _currentCountry = nil;
    [super dealloc];
}

- (id)init {
    if (self = [super init]) {
        _countryAssociations = [[NSDictionary alloc] initWithDictionary:@{
                                                                          @"Afrique du Sub": @"40",
                                                                          @"Allemagne": @"15",
                                                                          @"Arabie Saoudite": @"36",
                                                                          @"Argentine": @"30",
                                                                          @"Australie": @"8",
                                                                          @"Autriche": @"44",
                                                                          @"Belgique": @"41",
                                                                          @"Brésil": @"18",
                                                                          @"Canada": @"13",
                                                                          @"Chili": @"38",
                                                                          @"Colombie": @"32",
                                                                          @"Corée du Sud": @"23",
                                                                          @"Danemark": @"49",
                                                                          @"Egypte": @"29",
                                                                          @"Espagne": @"26",
                                                                          @"Etats Unis": @"1",
                                                                          @"Finlande": @"50",
                                                                          @"France": @"16",
                                                                          @"Grèce": @"48",
                                                                          @"Hong Kong": @"10",
                                                                          @"Hongrie": @"45",
                                                                          @"Inde": @"3",
                                                                          @"Indonésie": @"19",
                                                                          @"Israël": @"6",
                                                                          @"Italie": @"27",
                                                                          @"Japon": @"4",
                                                                          @"Kenya": @"37",
                                                                          @"Malaisie": @"34",
                                                                          @"Mexique": @"21",
                                                                          @"Nigeria": @"52",
                                                                          @"Norvège": @"51",
                                                                          @"Pays-Bas": @"17",
                                                                          @"Philippines": @"25",
                                                                          @"Pologne": @"31",
                                                                          @"Portugal": @"47",
                                                                          @"République Tchèque": @"43",
                                                                          @"Roumanie": @"39",
                                                                          @"Royaume Uni": @"9",
                                                                          @"Russie": @"14",
                                                                          @"Singapour": @"5",
                                                                          @"Suède": @"42",
                                                                          @"Suisse": @"46",
                                                                          @"Taïwan": @"12",
                                                                          @"Thaïlande": @"33",
                                                                          @"Turquie": @"24",
                                                                          @"Ukraine": @"35",
                                                                          @"Vietnam": @"28"
                                                                          }];

        _currentCountry = [[NSUserDefaults standardUserDefaults] objectForKey:HT_LANGUAGE_KEY];
        if (!_currentCountry) {
            self.currentCountry = @"Etats Unis";
        }
    }
    return self;
}

- (NSArray *)countries {
    return [[_countryAssociations allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)setCurrentCountry:(NSString *)currentCountry {
    _currentCountry = currentCountry;
    [[NSUserDefaults standardUserDefaults] setObject:currentCountry forKey:HT_LANGUAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self downloadTerms];
}


- (NSString *)randomTerm {
    NSUInteger index = (int)(((float)rand() / (float)RAND_MAX) * self.terms.count);
    return self.terms[index];
}

- (void)downloadTerms {
    [_terms release], _terms = nil;
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
        
        [_terms release];
        _terms = [[json objectForKey:_countryAssociations[_currentCountry]] retain];
    });
}

@end
