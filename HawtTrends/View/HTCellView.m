//
//  HTCellView.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTCellView.h"
#import "UIColor+Trends.h"

#define HT_TIMER_INTERVAL 3.0f
#define HT_ANIMATION_DURATION 0.25f

@interface HTCellView (Private)
- (void)_handleTimer:(NSTimer *)timer;
- (HTAnimationType)_randomAnimation;
- (void)_animateWithAnimation:(HTAnimationType)animationType;
@end

@interface HTCellView () {
    NSTimer * _animationTimer;
}
@end

@implementation HTCellView

- (void)dealloc {
    [_contentView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor randomTrendColor];
        
        [_contentView release], _contentView = nil;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_contentView];
        self.contentView.backgroundColor = self.backgroundColor;
        
        _animationTimer = [NSTimer timerWithTimeInterval:HT_TIMER_INTERVAL target:self selector:@selector(_handleTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

@end

@implementation HTCellView (Private)

- (void)_handleTimer:(NSTimer *)timer {
    self.backgroundColor = [UIColor randomTrendColorWithBaseColor:self.contentView.backgroundColor];
    [self _animateWithAnimation:[self _randomAnimation]];
}

- (HTAnimationType)_randomAnimation {
    int animation = (int)(((float)rand() / (float)RAND_MAX) * 4);
    return animation;
}

- (void)_animateWithAnimation:(HTAnimationType)animationType {
    CGRect frame = self.contentView.frame;
    switch (animationType) {
        case HTAnimationTypeTop:
            frame.origin.y = self.frame.size.height;
            break;
        case HTAnimationTypeRight:
            frame.origin.x = -self.frame.size.width;
            break;
        case HTAnimationTypeBottom:
            frame.origin.y = -self.frame.size.height;
            break;
        case HTAnimationTypeLeft:
            frame.origin.x = self.frame.size.width;
            break;
    }
    
    [UIView animateWithDuration:HT_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.contentView.backgroundColor = self.backgroundColor;
    }];
}

@end