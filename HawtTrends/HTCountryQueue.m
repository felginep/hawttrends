//
//  HTCountryQueue.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "HTCountryQueue.h"
#import "HTCountry.h"

static NSString * kCountryQueueKey = @"kCountryQueueKey";

@implementation HTCountryQueue

+ (void)addCountry:(NSString *)country {
    NSMutableArray * queue = [[self countries] mutableCopy];
    if (!queue) {
        queue = [NSMutableArray array];
    }

    NSUInteger index = [queue indexOfObjectPassingTest:^BOOL(HTCountry * obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqual:country];
    }];
    if (index != NSNotFound) {
        [queue removeObjectAtIndex:index];
    }
    [queue insertObject:country atIndex:0];


    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[queue copy]];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCountryQueueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)countries {
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kCountryQueueKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSArray *)countriesToIndex:(NSInteger)index {
    NSArray * countries = [self countries];
    if (index > countries.count) {
        return countries;
    }
    return [countries subarrayWithRange:NSMakeRange(0, index)];
}

+ (void)flush {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCountryQueueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
