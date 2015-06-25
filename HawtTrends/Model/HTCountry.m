//
//  HTCountry.m
//  HawtTrends
//
//  Created by Pierre on 23/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCountry.h"

@implementation HTCountry

- (void)dealloc {
    _countryCode = nil;
    _webserviceCode = nil;
}

- (NSString *)displayName {
    return [[NSLocale systemLocale] displayNameForKey:NSLocaleCountryCode value:self.countryCode];
}

@end
