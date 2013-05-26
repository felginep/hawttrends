//
//  HTCellView.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HTCellView.h"
#import "UIColor+Trends.h"


#define HT_TIMER_INTERVAL 3.0f
#define HT_ANIMATION_DURATION 0.5f

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
        [_contentView setOpaque:YES];
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
    return (int)(((float)rand() / (float)RAND_MAX) * 4);;
}

- (void)_animateWithAnimation:(HTAnimationType)animationType {
    CALayer * layer = self.contentView.layer;
    [layer setOpaque:YES];
    
    CGPoint lastPosition = layer.position;
    CGPoint newPosition = lastPosition;
    switch (animationType) {
        case HTAnimationTypeTop:
            newPosition.y += self.frame.size.height;
            break;
        case HTAnimationTypeRight:
            newPosition.x += -self.frame.size.width;
            break;
        case HTAnimationTypeBottom:
            newPosition.y += -self.frame.size.height;
            break;
        case HTAnimationTypeLeft:
            newPosition.x += self.frame.size.width;
            break;
    }
    
    [CATransaction begin]; {
        [CATransaction setAnimationDuration:HT_ANIMATION_DURATION];
        // See http://cubic-bezier.com/ for control points
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.11f :0.31f :0.49f :1.0f]];
        [CATransaction setCompletionBlock:^{
            layer.backgroundColor = self.layer.backgroundColor;
            layer.position = self.layer.position;
        }];
        CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:lastPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
        [layer addAnimation:positionAnimation forKey:@"position"];
        layer.position = newPosition;
    } [CATransaction commit];
}

@end