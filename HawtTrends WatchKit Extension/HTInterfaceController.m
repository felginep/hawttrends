//
//  InterfaceController.m
//  HawtTrends WatchKit Extension
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "HTInterfaceController.h"
#import "UIColor+HawtTrends.h"
#import "HTSharedConstants.h"
#import "HTCountryInterfaceController.h"
#import "HTCountry.h"

@interface HTInterfaceController() <HTPresentationDelegate> {
    NSArray * _terms;
    NSUInteger _termIndex;
    NSUInteger _colorIndex;
    BOOL _needsUpdateTermsAndCountry;
    BOOL _isFetchingCountry;
    HTCountry * _country;
    BOOL _isPresentingController;
}

@end


@implementation HTInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.mainLabel setText:@""];
    [self.countryLabel setText:@""];
    [self.countryLabel setTextColor:[UIColor htYellow]];
    [self _fetchTerms];
    [self _fetchCountryWithCompletion:nil];

    [self setTitle:@"HotTrends"];

    [self addMenuItemWithImageNamed:@"HTFlagIcon" title:NSLocalizedString(@"countries", nil) action:@selector(_chooseCountry)];
}

- (void)_chooseCountry {
    _isPresentingController = YES;
    HTCountryInterfaceContext * context = [HTCountryInterfaceContext contextWithPresentingController:self];
    [self presentControllerWithName:NSStringFromClass(HTCountryInterfaceController.class) context:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    if (!_isPresentingController) {
        [self nextTerm];
    }

    NSLog(@"willActivate %@", _isPresentingController ? @"Y" : @"N");

    if (_needsUpdateTermsAndCountry) {
        [self _fetchTerms];
        _needsUpdateTermsAndCountry = NO;
    } else {
        [self _fetchCountryWithCompletion:^(HTCountry * country) {
            if (country && ![country isEqual:_country]) {
                _country = country;
                [self _fetchTerms];
            }
        }];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];

    NSLog(@"didDeactivate %@", _isPresentingController ? @"Y" : @"N");
}

#pragma mark - Actions

- (IBAction)nextTerm {
    [self _nextTerm];
}

#pragma mark - HTPresentationDelegate

- (void)presentedControllerWillDismiss:(WKInterfaceController *)presentedController {
    NSLog(@"presentedControllerWillDismiss");
    _needsUpdateTermsAndCountry = YES;
}

- (void)presentedControllerDidDismiss:(WKInterfaceController *)presentedController {
    NSLog(@"presentedControllerDidDismiss");
    _isPresentingController = NO;
}

#pragma mark - Private

- (void)_nextTerm {
    if (_terms.count == 0) {
        return;
    }

    NSString * term = _terms[_termIndex];
    _termIndex = (_termIndex + 1) % _terms.count;

    UIColor * color = [UIColor htTrendsColors][_colorIndex];
    _colorIndex = (_colorIndex + 1) % [UIColor htTrendsColors].count;

    NSDictionary * attributes = @{ NSForegroundColorAttributeName: color };
    NSAttributedString * attributedTerm = [[NSAttributedString alloc] initWithString:term attributes:attributes];
    [self.mainLabel setAttributedText:attributedTerm];
}

- (void)_fetchTerms {
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionFetchTerms) } reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"reply = %@", replyInfo);
        _terms = replyInfo[kHTWatchResponse];
        _termIndex = 0;
        _colorIndex = 0;

        NSData * countryData = replyInfo[kHTWatchUserInfos];
        if (countryData) {
            HTCountry * country = [NSKeyedUnarchiver unarchiveObjectWithData:countryData];
            [self.countryLabel setText:country.displayName];
        }

        [self nextTerm];
    }];
}

- (void)_fetchCountryWithCompletion:(void(^)(HTCountry * country))completion {
    if (_isFetchingCountry) {
        return;
    }

    _isFetchingCountry = YES;
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionCurrentCountry) } reply:^(NSDictionary *replyInfo, NSError *error) {
        _isFetchingCountry = NO;

        NSData * countryData = replyInfo[kHTWatchResponse];
        HTCountry * country = nil;
        if (countryData) {
            HTCountry * country = [NSKeyedUnarchiver unarchiveObjectWithData:countryData];
            [self.countryLabel setText:country.displayName];
        }
        if (completion) { completion(country); }
    }];
}

@end



