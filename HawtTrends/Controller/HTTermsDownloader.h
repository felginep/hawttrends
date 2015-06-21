//
//  HTTermsDownloader.h
//  HawtTrends
//
//  Created by Pierre Felgines on 10/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCountry.h"

@interface HTTermsDownloader : NSObject

@property (nonatomic, strong, readonly) NSArray * terms;
@property (nonatomic, strong) HTCountry * currentCountry;
@property (nonatomic, strong) NSArray * countries;

+ (HTTermsDownloader *)sharedDownloader;
- (NSString *)randomTerm;
- (void)downloadTerms:(void(^)(void))callback;

@end
