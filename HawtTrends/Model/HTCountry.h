//
//  HTCountry.h
//  HawtTrends
//
//  Created by Pierre on 23/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTCountry : NSObject
@property (nonatomic, strong) NSString * countryCode;
@property (nonatomic, strong) NSString * webserviceCode;
@property (nonatomic, readonly) NSString * displayName;
@end
