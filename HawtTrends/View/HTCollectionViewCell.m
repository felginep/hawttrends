//
//  HTCollectionViewCell.m
//  HawtTrends
//
//  Created by Pierre on 29/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCollectionViewCell.h"

#define HT_TIMER_INTERVAL 3.0f
#define HT_ANIMATION_DURATION 0.5f
#define HT_LABEL_ANIMATION_DURATION 0.33f
#define HT_LABEL_MOVE 30.0f

typedef enum {
    HTAnimationTypeTop = 0,
    HTAnimationTypeRight = 1,
    HTAnimationTypeBottom = 2,
    HTAnimationTypeLeft
} HTAnimationType;

@interface HTCollectionViewCell () {
    NSUInteger _colorIndex;
    HTAnimationType _currentAnimationType;
    NSTimer * _backgroundTimer;
    NSTimer * _labelTimer;
    BOOL _needsAnimating;
}
@end

@implementation HTCollectionViewCell

- (void)dealloc {
    [_backgroundTimer invalidate];
    _backgroundTimer = nil;
    _textView = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _colorIndex = [self _random];
        self.backgroundColor = [self _nextColor];
        self.clipsToBounds = YES;

        _backgroundContentView = [[UIView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_backgroundContentView];

        _textView = [[HTTextView alloc] init];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor whiteColor];
        _textView.animationDelegate = self;
        _textView.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f];
        _textView.shadowOffset = CGSizeMake(1.0f, 1.0f);
        [_backgroundContentView addSubview:_textView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _backgroundContentView.frame = self.contentView.bounds;
    CGFloat margin = floorf(MIN(_backgroundContentView.frame.size.width, _backgroundContentView.frame.size.height) / 10.0f);
    _textView.frame = CGRectMake(margin, margin, _backgroundContentView.frame.size.width - 2 * margin, _backgroundContentView.frame.size.height - 2 * margin);

    if (_needsAnimating) {
        _needsAnimating = NO;
        [self _animate];
    }
}

- (void)setNeedsAnimating {
    if (!_needsAnimating) {
        _needsAnimating = YES;
        [self setNeedsLayout];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];

    [_backgroundTimer invalidate];
    _backgroundTimer = nil;

    [_labelTimer invalidate];
    _labelTimer = nil;

    [_textView stopTimers];

    [CATransaction begin]; {
        [_backgroundContentView.layer removeAllAnimations];
        [_textView.layer removeAllAnimations];
    } [CATransaction commit];
}

#pragma HTTextViewDelegate

- (void)textViewDidStopAnimating:(HTTextView *)textView {
    _labelTimer = [NSTimer timerWithTimeInterval:HT_TIMER_INTERVAL target:self selector:@selector(_handleTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_labelTimer forMode:NSDefaultRunLoopMode];
}


#pragma mark - Private

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
    CALayer * layer = self.backgroundContentView.layer;
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

    CGPoint center = self.backgroundContentView.center;
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
        _textView.center = self.backgroundContentView.center;
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
