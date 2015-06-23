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


@implementation HTCountryInterfaceContext

+ (instancetype)contextWithPresentingController:(id<HTPresentationDelegate>)presentingController {
    HTCountryInterfaceContext * context = [[HTCountryInterfaceContext alloc] init];
    context.presentingController = presentingController;
    return context;
}

@end

@interface HTCountryInterfaceController () {
    NSArray * _countries;
    HTCountryInterfaceContext * _context;
    HTCountryTableViewModel * _tableViewModel;
}

@end

@implementation HTCountryInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    _context = context;

    [self.class openParentApplication:@{kHTWatchAction: @(HTWatchActionCountries) } reply:^(NSDictionary *replyInfo, NSError *error) {
        _countries = replyInfo[kHTWatchResponse];
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
    NSString * country = _countries[rowIndex];

    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionSetCurrentCountry), kHTWatchUserInfos: country } reply:^(NSDictionary *replyInfo, NSError *error) {
        BOOL success = [replyInfo[kHTWatchResponse] boolValue];
        if (!success) {
            NSLog(@"Error setting up new country");
            return ;
        }

        [self _dismiss];
    }];
}

#pragma mark - Private

- (void)_dismiss {
    if ([_context.presentingController respondsToSelector:@selector(presentedControllerWillDismiss:)]) {
        [_context.presentingController presentedControllerWillDismiss:self];
    }
    [self dismissController];
}

- (void)_updateTable {
    HTCountryTableViewModel * tableViewModel = [[HTCountryTableViewModel alloc] initWithCountries:_countries isSubset:NO];
    [self.table updateFrom:_tableViewModel to:tableViewModel];
    _tableViewModel = tableViewModel;

    // TODO: be smarter, and save favorites countries
}

@end



