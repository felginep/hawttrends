//
//  HTTermCache.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "HTTermCache.h"

static NSString * kUserDefaultCacheKey = @"HTTermsUserDefaultKey";

@implementation HTTermCache

+ (void)saveTermsByCountry:(NSDictionary *)termsByCountry {
    if (!termsByCountry) {
        return;
    }

    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSDictionary * response = @{ @"response": termsByCountry,
                                 @"date": @(currentTimeInterval) };
    [[NSUserDefaults standardUserDefaults] setObject:response forKey:kUserDefaultCacheKey];
}

+ (NSArray *)termsForCountry:(NSString *)countryCode {
    NSDictionary * termsByCountry = [self _savedObject][@"response"];
    return termsByCountry ? termsByCountry[countryCode] : nil;
}

+ (BOOL)hasExpired {
    NSDictionary * savedObject = [self _savedObject];
    if (!savedObject || !savedObject[@"response"]) {
        return YES;
    }
    NSTimeInterval timeInterval = [savedObject[@"date"] doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return ABS([date timeIntervalSinceNow]) > 60 * 60; // every hour
}

+ (NSDictionary *)_savedObject {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultCacheKey];
}

@end
