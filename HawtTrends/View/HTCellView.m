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
#define HT_LABEL_ANIMATION_DURATION 0.33f
#define HT_LABEL_MOVE 60.0f

@interface HTCellView (Private)
- (void)_handleTimer:(NSTimer *)timer;
- (HTAnimationType)_randomAnimation;
- (void)_animate;
- (void)_makeLabelAppear;
@end

@interface HTCellView () {
    HTAnimationType _currentAnimationType;
}
@end

@implementation HTCellView

- (void)dealloc {
    [_contentView release];
    [_label release];
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
        
        [_label release], _label = nil;
        _label = [[HTLabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, _contentView.frame.size.width - 40.0f, _contentView.frame.size.height - 40.0f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:60.0f];
        _label.delegate = self;
        [self addSubview:_label];
        
        _label.animatedText = @"Dummy text";
        [_label startAnimating];
    }
    return self;
}

#pragma mark - HTLabelDelegate

- (void)labelDidStopAnimating:(HTLabel *)label {
    [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:HT_TIMER_INTERVAL target:self selector:@selector(_handleTimer:) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

@end

@implementation HTCellView (Private)

- (void)_handleTimer:(NSTimer *)timer {
    self.backgroundColor = [UIColor randomTrendColorWithBaseColor:self.contentView.backgroundColor];
    _currentAnimationType = [self _randomAnimation];
    [self _animate];
}

- (HTAnimationType)_randomAnimation {
    return (int)(((float)rand() / (float)RAND_MAX) * 4);;
}

- (void)_animate {
    CALayer * layer = self.contentView.layer;
    [layer setOpaque:YES];
    
    CGPoint lastPosition = layer.position;
    // Calculate the new position for the layer
    CGPoint newPosition = lastPosition;
    switch (_currentAnimationType) {
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
            [self _makeLabelAppear];
        }];
        // Animate the position
        CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:lastPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
        [layer addAnimation:positionAnimation forKey:@"position"];
        layer.position = newPosition;
        
        [_label.layer addAnimation:positionAnimation forKey:@"position"];
        _label.layer.position = newPosition;
        
    } [CATransaction commit];
}

- (void)_makeLabelAppear {
    _label.animatedText = @"Another text";
    [_label startAnimating];
    
    CGPoint center = self.center;
    switch (_currentAnimationType) {
        case HTAnimationTypeTop:
            center.y -= HT_LABEL_MOVE;
            break;
        case HTAnimationTypeRight:
            center.x += HT_LABEL_MOVE;
            break;
        case HTAnimationTypeBottom:
            center.y += HT_LABEL_MOVE;
            break;
        case HTAnimationTypeLeft:
            center.x -= HT_LABEL_MOVE;
            break;
    }
    
    _label.alpha = 0;
    _label.center = center;
    [UIView animateWithDuration:HT_LABEL_ANIMATION_DURATION animations:^{
        _label.alpha = 1.0f;
        _label.center = self.center;
    }];
}

@end