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
#define HT_CURSOR_TIMER_INTERVAL 0.4f

@interface HTLabel (Private)
- (void)_handleTimer:(id)sender;
- (void)_handleCursor:(id)sender;
- (void)_createTimer;
- (void)_createCursorTimer;
- (NSTimeInterval)_randomTimeInterval;
- (void)_positionCursor;
@end

@interface HTLabel () {
    NSString * _animatedText;
    NSUInteger _textIndex;
    UIView * _cursor;
    NSTimer * _cursorTimer;
}
@property (nonatomic, assign) BOOL isWriting;
@end

@implementation HTLabel

- (void)dealloc {
    [_animatedText release];
    [_cursorTimer invalidate], [_cursorTimer release];
    [_cursor release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2.0f, 60.0f)];
        _cursor.center = CGPointMake(self.center.x, self.center.y - _cursor.frame.size.height / 3.0f);
        _cursor.backgroundColor = [UIColor blackColor];
        [self addSubview:_cursor];
        self.isWriting = NO;
    }
    return self;
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    _cursor.backgroundColor = textColor;
}

- (void)setAnimatedText:(NSString *)animatedText {
    [_animatedText release];
    _animatedText = [animatedText copy];
    _textIndex = 0;
    self.text = nil;
    [self _positionCursor];
}

- (void)startAnimating {
    [self _handleTimer:nil];
    self.isWriting = YES;
}

- (void)setIsWriting:(BOOL)isWriting {
    _isWriting = isWriting;
    if (isWriting) {
        _cursor.hidden = NO;
        [_cursorTimer invalidate];
        [_cursorTimer release], _cursorTimer = nil;
    } else {
        [self _createCursorTimer];
    }
}

@end

@implementation HTLabel (Private)

- (void)_handleTimer:(id)sender {
    if (_textIndex < _animatedText.length) {
        _textIndex++;
        [self _createTimer];
    } else {
        [self.delegate labelDidStopAnimating:self];
        self.isWriting = NO;
    }
    self.text = [_animatedText substringToIndex:_textIndex];
    [self _positionCursor];
}

- (void)_handleCursor:(id)sender {
    _cursor.hidden = !_cursor.hidden;
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

- (void)_createCursorTimer {
    [_cursorTimer release];
    _cursorTimer = [[NSTimer timerWithTimeInterval:HT_CURSOR_TIMER_INTERVAL target:self selector:@selector(_handleCursor:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop mainRunLoop] addTimer:_cursorTimer forMode:NSDefaultRunLoopMode];
}

- (void)_positionCursor {
    CGRect cursorFrame = _cursor.frame;
    cursorFrame.origin.x = [self.text sizeWithFont:self.font].width;
    _cursor.frame = cursorFrame;
}

@end
