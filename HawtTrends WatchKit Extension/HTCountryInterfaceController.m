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

@interface HTCountryInterfaceController () {
    NSArray * _countries;
}

@end

@implementation HTCountryInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    [self.class openParentApplication:@{kHTWatchAction: @(HTWatchActionCountries) } reply:^(NSDictionary *replyInfo, NSError *error) {
        _countries = replyInfo[kHTWatchResponse];
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

        [self dismissController];
    }];
}

#pragma mark - Private

- (void)_updateTable {
    if (_countries.count == 0) {
        [self dismissController];
        return;
    }

    NSMutableArray * rowTypes = [NSMutableArray array];
    for (int i = 0; i < _countries.count; i++) {
        [rowTypes addObject:NSStringFromClass(HTCountryRowController.class)];
    }

    [self.table setRowTypes:[rowTypes copy]];
    for (int i = 0; i < self.table.numberOfRows; i++) {
        HTCountryRowController * row = [self.table rowControllerAtIndex:i];
        NSString * country = _countries[i];
        [row.mainLabel setText:country];
    }
}

@end



