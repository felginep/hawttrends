//
//  HTCountryInterfaceController.m
//  HawtTrends
//
//  Created by Pierre Felgines on 22/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "HTCountryInterfaceController.h"
#import "HTCountryRowController.h"
#import "HTSharedConstants.h"
#import "NSArray+HawtTrends.h"
#import "HTCountryTableViewModel.h"
#import "HTCountry.h"

@implementation HTCountryInterfaceContext

+ (instancetype)contextWithPresentingController:(id<HTPresentationDelegate>)presentingController {
    HTCountryInterfaceContext * context = [[HTCountryInterfaceContext alloc] init];
    context.presentingController = presentingController;
    return context;
}

@end

@interface HTCountryInterfaceController () {
    NSArray * _countries;
    NSArray * _favoriteCountries;
    HTCountryInterfaceContext * _context;
    HTCountryTableViewModel * _tableViewModel;
    BOOL _isSubset;
}

@end

@implementation HTCountryInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self setTitle:NSLocalizedString(@"cancel", nil)];

    _context = context;

    [self.class openParentApplication:@{kHTWatchAction: @(HTWatchActionCountries) } reply:^(NSDictionary *replyInfo, NSError *error) {
        _countries = [NSKeyedUnarchiver unarchiveObjectWithData:replyInfo[kHTWatchResponse]];
        _favoriteCountries = [NSKeyedUnarchiver unarchiveObjectWithData:replyInfo[kHTWatchUserInfos]];
        _isSubset = _favoriteCountries.count == kHTWatchSubsetResultCount;
        if (_countries.count == 0) {
            [self dismissController];
            return;
        }
        [self _updateTable];
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    if (_isSubset && rowIndex == _tableViewModel.rowTypes.count - 1) { // Load more
        [self _loadMore];
    } else { // set current country
        HTCountry * country = [self _displayedCountries][rowIndex];
        [self _setCurrentCountry:country];
    }
}

#pragma mark - Private

- (void)_loadMore {
    _isSubset = NO;

    NSMutableSet * matches = [NSMutableSet setWithArray:_countries];
    NSSet * submatches = [NSSet setWithArray:_favoriteCountries];
    [matches minusSet:submatches];
    NSArray * countriesWithoutFavorites = [[matches allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]]];
    _countries = [_favoriteCountries arrayByAddingObjectsFromArray:countriesWithoutFavorites];

    [self _updateTable];
}

- (void)_setCurrentCountry:(HTCountry *)country {
    if (!country) return;

    NSData * countryData = [NSKeyedArchiver archivedDataWithRootObject:country];
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionSetCurrentCountry), kHTWatchUserInfos: countryData } reply:^(NSDictionary *replyInfo, NSError *error) {
        BOOL success = [replyInfo[kHTWatchResponse] boolValue];
        if (!success) {
            NSLog(@"Error setting up new country");
            return ;
        }
        [self _dismiss];
    }];
}

- (void)_dismiss {
    if ([_context.presentingController respondsToSelector:@selector(presentedControllerWillDismiss:)]) {
        [_context.presentingController presentedControllerWillDismiss:self];
    }
    [self dismissController];
}

- (NSArray *)_displayedCountries {
    return _isSubset ? _favoriteCountries : _countries;
}

- (void)_updateTable {
    HTCountryTableViewModel * tableViewModel = [[HTCountryTableViewModel alloc] initWithCountries:[self _displayedCountries] isSubset:_isSubset];
    [self.table updateFrom:_tableViewModel to:tableViewModel];
    _tableViewModel = tableViewModel;
}

@end



