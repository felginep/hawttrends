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

@interface HTInterfaceController() <HTPresentationDelegate> {
    NSArray * _terms;
    NSUInteger _termIndex;
    NSUInteger _colorIndex;
    NSTimer * _timer;
}

@end


@implementation HTInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.mainLabel setText:@""];
    [self.countryLabel setText:@""];
    [self.countryLabel setTextColor:[UIColor htYellow]];
    [self _fetchTerms];
    [self _fetchCountry];

    [self setTitle:@"HotTrends"];

    [self addMenuItemWithItemIcon:WKMenuItemIconMore title:@"Country" action:@selector(_chooseCountry)];
}

- (void)_chooseCountry {
    HTCountryInterfaceContext * context = [HTCountryInterfaceContext contextWithPresentingController:self];
    [self presentControllerWithName:NSStringFromClass(HTCountryInterfaceController.class) context:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    [self nextTerm];
    [self _restartTimer];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self _stopTimer];
}

#pragma mark - Actions

- (IBAction)nextTerm {
    [self _restartTimer];
    [self _nextTerm];
}

#pragma mark - HTPresentationDelegate

- (void)presentedControllerWillDismiss:(WKInterfaceController *)presentedController {
    [self _fetchTerms];
    [self _fetchCountry];
}

#pragma mark - Private

- (void)_stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)_restartTimer {
    [self _stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(nextTerm) userInfo:nil repeats:YES];
}

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

        [self nextTerm];
    }];
}

- (void)_fetchCountry {
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionCurrentCountry) } reply:^(NSDictionary *replyInfo, NSError *error) {
        NSString * countryName = replyInfo[kHTWatchResponse];
        [self.countryLabel setText:countryName];
    }];
}

@end



