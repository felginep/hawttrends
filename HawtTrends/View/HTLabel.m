//
//  HTLabel.m
//  HawtTrends
//
//  Created by Pierre Felgines on 09/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTLabel.h"

#define HT_TIMER_INTERVAL 0.25f
#define HT_EPSILON 0.10f

@interface HTLabel (Private)
- (void)_handleTimer:(id)sender;
- (NSTimeInterval)_randomTimeInterval;
- (void)_createTimer;
@end

@interface HTLabel () {
    NSString * _animatedText;
    NSUInteger _textIndex;
}
@end

@implementation HTLabel

- (void)dealloc {
    [_animatedText release];
    [super dealloc];
}

- (void)setAnimatedText:(NSString *)animatedText {
    [_animatedText release];
    _animatedText = [animatedText copy];
    _textIndex = 0;
}

- (void)startAnimating {
    [self _handleTimer:nil];
}

@end

@implementation HTLabel (Private)

- (void)_handleTimer:(id)sender {
    if (_textIndex < _animatedText.length) {
        _textIndex++;
        [self _createTimer];
    } else {
        [self.delegate labelDidStopAnimating:self];
    }
    self.text = [_animatedText substringToIndex:_textIndex];
}

- (NSTimeInterval)_randomTimeInterval {
    CGFloat random;
    do {
        random = ((float)rand() / (float)RAND_MAX) * HT_TIMER_INTERVAL;
    } while (ABS(HT_TIMER_INTERVAL - random) > HT_EPSILON);
    return random;
}

- (void)_createTimer {
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:[self _randomTimeInterval] target:self selector:@selector(_handleTimer:) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

@end
