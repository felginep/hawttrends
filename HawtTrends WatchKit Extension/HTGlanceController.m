//
//  GlanceController.m
//  HawtTrends WatchKit Extension
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "HTGlanceController.h"
#import "UIColor+HawtTrends.h"
#import "HTSharedConstants.h"

@interface HTGlanceController() {
    NSArray * _terms;
    NSString * _country;
    BOOL _isFetchingCountry;
    BOOL _isFetchingTerms;
}

@end


@implementation HTGlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.countryLabel setText:@""];
    [self.mainLabel setText:@""];

    // Configure interface objects here.
    [self _fetchCountryWithCompletion:nil];
    [self _fetchTerms];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    [self _fetchCountryWithCompletion:^(NSString *country) {
        if (country && ![country isEqualToString:_country]) {
            _country = country;
            [self _fetchTerms];
        } else {
            [self _displayTerm];
        }
    }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Private

- (void)_fetchCountryWithCompletion:(void(^)(NSString * country))completion {
    if (_isFetchingCountry) {
        return;
    }

    _isFetchingCountry = YES;
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionCurrentCountry) } reply:^(NSDictionary *replyInfo, NSError *error) {
        _isFetchingCountry = NO;
        NSString * country = replyInfo[kHTWatchResponse];
        [self.countryLabel setText:country];
        if (completion) { completion(country); }
    }];
}

- (void)_fetchTerms {
    if (_isFetchingTerms) {
        return;
    }

    _isFetchingTerms = YES;
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionFetchTerms) } reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"reply = %@", replyInfo);
        _isFetchingTerms = NO;
        _terms = replyInfo[kHTWatchResponse];
        [self _displayTerm];
    }];
}

- (void)_displayTerm {
    if (_terms.count == 0) {
        return;
    }

    NSInteger termIndex = arc4random() % _terms.count;
    NSInteger colorIndex = arc4random() % [UIColor htTrendsColors].count;
    NSString * term = _terms[termIndex];
    UIColor * color = [UIColor htTrendsColors][colorIndex];
    NSDictionary * attributes = @{ NSForegroundColorAttributeName: color };
    NSAttributedString * attributedTerm = [[NSAttributedString alloc] initWithString:term attributes:attributes];
    [self.mainLabel setAttributedText:attributedTerm];
}


@end



