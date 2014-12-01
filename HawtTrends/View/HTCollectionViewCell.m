//
//  HTCollectionViewCell.m
//  HawtTrends
//
//  Created by Pierre on 29/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCollectionViewCell.h"
#import "HTCellView.h" // to remove later

#define HT_TIMER_INTERVAL 3.0f
#define HT_ANIMATION_DURATION 0.5f
#define HT_LABEL_ANIMATION_DURATION 0.33f
#define HT_LABEL_MOVE 30.0f

@interface HTCollectionViewCell () {
    NSUInteger _colorIndex;
    HTAnimationType _currentAnimationType;
    CALayer * _backgroundLayer;
    NSTimer * _backgroundTimer;
}
@end

@implementation HTCollectionViewCell

- (void)dealloc {
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
}

- (void)prepareForReuse {
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _colorIndex = [self _random];
        self.backgroundColor = [self _nextColor];
        self.clipsToBounds = YES;

        _backgroundTimer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(_changeBackground) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_backgroundTimer forMode:NSRunLoopCommonModes];
        [self _animate];
    }
    return self;
}

- (void)_changeBackground {
    self.backgroundColor = [self _nextColor];
    _currentAnimationType = [self _randomAnimation];
    
    [self _animate];
}


#pragma mark - Private

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
            layer.position = lastPosition;

//            [self _makeLabelAppear];
            
        }];
        // Animate the position
        CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:lastPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
        [layer addAnimation:positionAnimation forKey:@"position"];
        layer.position = newPosition;
    } [CATransaction commit];
}


- (int)_random {
    return (int)(((float)rand() / (float)RAND_MAX) * 4);
}

- (HTAnimationType)_randomAnimation {
    return [self _random];
}

- (NSArray *)_trendColors {
    static NSArray * sTrendColors = nil;
    if (!sTrendColors) {
        sTrendColors = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:0.258f green:0.521f blue:0.956 alpha:1.0f], //blue
                        [UIColor colorWithRed:0.854f green:0.266f blue:0.215f alpha:1.0f], //red
                        [UIColor colorWithRed:0.952f green:0.710f blue:0 alpha:1.0f], //orange
                        [UIColor colorWithRed:0.058f green:0.615f blue:0.345 alpha:1.0f], nil]; //green
    }
    return sTrendColors;
}

- (UIColor *)_nextColor {
    _colorIndex = (_colorIndex + 1) % [self _trendColors].count;
    return [self _trendColors][_colorIndex];
}

@end
