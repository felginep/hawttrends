//
//  HTTermCache.h
//  HawtTrends
//
//  Created by Pierre Felgines on 23/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTermCache : NSObject

+ (void)saveTermsByCountry:(NSDictionary *)termsByCountry;
+ (NSArray *)termsForCountry:(NSString *)countryCode;
+ (BOOL)hasExpired;

@end
