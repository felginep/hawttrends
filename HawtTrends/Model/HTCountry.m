//
//  HTCountry.m
//  HawtTrends
//
//  Created by Pierre on 23/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCountry.h"

static NSString * kCountryCodeKey = @"kCountryCodeKey";
static NSString * kWebserviceCodeKey = @"kWebserviceCodeKey";

@implementation HTCountry

- (void)dealloc {
    _countryCode = nil;
    _webserviceCode = nil;
}

- (NSString *)displayName {
    return [[NSLocale systemLocale] displayNameForKey:NSLocaleCountryCode value:self.countryCode];
}

- (BOOL)isEqual:(HTCountry *)other {
    return [other.countryCode isEqualToString:self.countryCode];
}

- (NSUInteger)hash {
    return [self.countryCode hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.countryCode, self.webserviceCode];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_countryCode forKey:kCountryCodeKey];
    [aCoder encodeObject:_webserviceCode forKey:kWebserviceCodeKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _countryCode = [aDecoder decodeObjectForKey:kCountryCodeKey];
        _webserviceCode = [aDecoder decodeObjectForKey:kWebserviceCodeKey];
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
