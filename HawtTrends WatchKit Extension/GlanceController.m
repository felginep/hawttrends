//
//  GlanceController.m
//  HawtTrends WatchKit Extension
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "GlanceController.h"
#import "UIColor+HawtTrends.h"
#import "HTSharedConstants.h"

@interface GlanceController() {
    NSArray * _terms;
}

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.

    [self _fetchTerms];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Private

- (void)_fetchTerms {
    [self.class openParentApplication:@{ kHTWatchAction: @(HTWatchActionFetchTerms) } reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"reply = %@", replyInfo);
        _terms = replyInfo[kHTWatchResponse];
        [self _displayTerm];
    }];
}

- (void)_displayTerm {
    NSInteger termIndex = arc4random() % _terms.count;
    NSInteger colorIndex = arc4random() % [UIColor htTrendsColors].count;
    NSString * term = _terms[termIndex];
    UIColor * color = [UIColor htTrendsColors][colorIndex];
    NSDictionary * attributes = @{ NSForegroundColorAttributeName: color };
    NSAttributedString * attributedTerm = [[NSAttributedString alloc] initWithString:term attributes:attributes];
    [self.mainLabel setAttributedText:attributedTerm];
}


@end



