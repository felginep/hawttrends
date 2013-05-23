//
//  HTCellView.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTCellView.h"
#import "UIColor+Trends.h"

#define HT_TIMER_INTERVAL 1.0f

@interface HTCellView (Private)
- (void)_handleTimer:(NSTimer *)timer;
@end

@interface HTCellView () {
    NSTimer * _animationTimer;
}
@end

@implementation HTCellView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor randomTrendColor];
        _animationTimer = [NSTimer timerWithTimeInterval:HT_TIMER_INTERVAL target:self selector:@selector(_handleTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}


@end

@implementation HTCellView (Private)

- (void)_handleTimer:(NSTimer *)timer {
    self.backgroundColor = [UIColor randomTrendColor];
}

@end