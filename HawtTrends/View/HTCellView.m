//
//  HTCellView.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HTCellView.h"
#import "HTTermsDownloader.h"

#define HT_TIMER_INTERVAL 3.0f
#define HT_ANIMATION_DURATION 0.5f
#define HT_LABEL_ANIMATION_DURATION 0.33f
#define HT_LABEL_MOVE 30.0f

@interface HTCellView (Private)
- (void)_handleTimer:(NSTimer *)timer;
- (int)_random;
- (HTAnimationType)_randomAnimation;
- (void)_animate;
- (void)_makeLabelAppear;
- (NSArray *)_trendColors;
- (UIColor *)_nextColor;
@end

@interface HTCellView () {
    HTAnimationType _currentAnimationType;
    NSUInteger _colorIndex;
    NSTimer * _labelTimer;
}
@end

@implementation HTCellView

- (void)dealloc {
    _contentView = nil;
    [_labelTimer invalidate];
    _labelTimer = nil;
    _textView = nil;
    [_textView stopTimers];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _colorIndex = [self _random];
        self.backgroundColor = [self _nextColor];
        self.clipsToBounds = YES;
        
        _contentView = nil;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_contentView setOpaque:YES];
        [self addSubview:_contentView];
        self.contentView.backgroundColor = self.backgroundColor;

        _textView = nil;
        CGFloat margin = MIN(_contentView.frame.size.width, _contentView.frame.size.height) / 10.0f;
        _textView = [[HTTextView alloc] initWithFrame:CGRectMake(margin, margin, _contentView.frame.size.width - 2 * margin, _contentView.frame.size.height - 2 * margin)];
        _textView.backgroundColor = [UIColor clearColor];
//        _textView.font = [UIFont boldSystemFontOfSize:60.0f];
        _textView.textColor = [UIColor whiteColor];
//        _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
//        _textView.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _textView.animationDelegate = self;
        _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
        _textView.shadowOffset = CGSizeMake(1.0f, 1.0f);
        [self.contentView addSubview:_textView];
    }
    return self;
}

- (void)setDatasource:(id<HTCellViewDataSource>)datasource {
    _datasource = datasource;
    _textView.animatedText = [datasource textToDisplayForCellView:self];
    [_textView startAnimating];
}

#pragma HTTextViewDelegate

- (void)textViewDidStopAnimating:(HTTextView *)textView {
    _labelTimer = [NSTimer timerWithTimeInterval:HT_TIMER_INTERVAL target:self selector:@selector(_handleTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_labelTimer forMode:NSDefaultRunLoopMode];
}

@end

@implementation HTCellView (Private)

- (void)_handleTimer:(NSTimer *)timer {
    [_labelTimer invalidate];
    _labelTimer = nil;
    self.backgroundColor = [self _nextColor];
    _currentAnimationType = [self _randomAnimation];
    [self _animate];
}

- (HTAnimationType)_randomAnimation {
    return [self _random];
}

- (int)_random {
    return (int)(((float)rand() / (float)RAND_MAX) * 4);
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
            layer.position = lastPosition;
            [self _makeLabelAppear];
        }];
        // Animate the position
        CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:lastPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
        [layer addAnimation:positionAnimation forKey:@"position"];
        layer.position = newPosition;
    } [CATransaction commit];
}

- (void)_makeLabelAppear {
    _textView.animatedText = [self.datasource textToDisplayForCellView:self];
    [_textView startAnimating];

    CGPoint center = self.contentView.center;
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

    _textView.alpha = 0;
    _textView.center = center;
    [UIView animateWithDuration:HT_LABEL_ANIMATION_DURATION animations:^{
        _textView.alpha = 1.0f;
        _textView.center = self.contentView.center;
    }];
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