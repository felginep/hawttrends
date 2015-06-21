//
//  InterfaceController.m
//  HawtTrends WatchKit Extension
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "InterfaceController.h"
#import "UIColor+HawtTrends.h"

@interface InterfaceController() {
    NSArray * _terms;
    NSUInteger _termIndex;
}

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.mainLabel setText:@""];
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

#pragma mark - Actions

- (IBAction)nextTerm {
    NSString * term = _terms[_termIndex];
    _termIndex = (_termIndex + 1) % _terms.count;
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:term attributes:@{ NSForegroundColorAttributeName: [UIColor htYellow]}];
    [self.mainLabel setAttributedText:attributedString];
}

#pragma mark - Private

- (void)_fetchTerms {
    [self.class openParentApplication:@{ @"action": @"terms" } reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"reply = %@", replyInfo);
        _terms = replyInfo[@"response"];
        _termIndex = 0;

        [self nextTerm];
    }];
}

@end


