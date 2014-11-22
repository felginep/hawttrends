//
//  HTMeasureTextView.m
//  HawtTrends
//
//  Created by Pierre Felgines on 26/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTMeasureTextField.h"

@interface HTMeasureTextField () {
    NSDate * _previousDate;
}
@end

@implementation HTMeasureTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_previousDate) {
        NSLog(@"'%@' %f", string, ABS([_previousDate timeIntervalSinceNow]));
    }
    _previousDate = [NSDate date];
    return YES;
}

@end
