//
//  HTCountryTableViewModel.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "HTCountryTableViewModel.h"
#import "NSArray+HawtTrends.h"
#import "HTCountryRowController.h"
#import "HTCountry.h"

@interface HTCountryTableViewModel () {
    NSArray * _rowTypes; // of NSString
    NSArray * _rowViewModels; // of NSString
    BOOL _isSubset;
}

@end

@implementation HTCountryTableViewModel

- (instancetype)initWithCountries:(NSArray *)countries isSubset:(BOOL)isSubset {
    if (self = [super init]) {
        _rowTypes = [NSArray arrayWithObject:NSStringFromClass(HTCountryRowController.class) numberOfOccurences:countries.count + (isSubset ? 1 : 0)];
        NSArray * countryNames = [countries map:^id(HTCountry * obj) { return obj.displayName; }];
        _rowViewModels = isSubset ? [countryNames arrayByAddingObject:NSLocalizedString(@"load_more", nil)] : countryNames;
        _isSubset = isSubset;
    }
    return self;
}

#pragma mark - PLTableViewModel

- (NSArray *)rowTypes {
    return _rowTypes;
}

- (id)rowViewModelAtIndex:(NSInteger)index {
    return index < _rowViewModels.count ? _rowViewModels[index] : nil;
}

- (void)table:(WKInterfaceTable *)table updateFrom:(NSString *)oldViewModel to:(NSString *)newViewModel atIndex:(NSInteger)index {
    HTCountryRowController * row = [table rowControllerAtIndex:index];
    [row.mainLabel updateFrom:oldViewModel to:newViewModel];
}

@end
