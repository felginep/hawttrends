//
//  HTCountryTableViewModel.h
//  HawtTrends
//
//  Created by Pierre Felgines on 23/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKInterface+Performance.h"

@interface HTCountryTableViewModel : NSObject <WKTableViewModel>

- (instancetype)initWithCountries:(NSArray *)countries isSubset:(BOOL)isSubset;

@end
