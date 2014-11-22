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
#define HT_LABEL_FONT_FACTOR 0.113f

@interface HTLabel (Private)
- (void)_handleTimer:(id)sender;
- (void)_handleCursor:(id)sender;
- (void)_createTimer;
- (void)_createCursorTimer;
- (NSTimeInterval)_randomTimeInterval;
- (void)_positionCursor;
- (CGFloat)_fontSizeForText:(NSString *)string;
@end

@interface HTLabel () {
    NSString * _animatedText;
    NSUInteger _textIndex;
    UIView * _cursor;
    NSTimer * _cursorTimer;
    NSTimer * _textTimer;
}
@property (nonatomic, assign) BOOL isWriting;
@end

@implementation HTLabel

- (void)dealloc {
    _animatedText = nil;
    _cursor = nil;
    [self stopTimers];
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
    _animatedText = [animatedText copy];
    _textIndex = 0;
    self.text = nil;
    CGFloat fontSize = [self _fontSizeForText:_animatedText];
    self.font = [UIFont systemFontOfSize:fontSize];
    CGRect frame = _cursor.frame;
    frame.size.width = (fontSize < 30) ? 1.0 : 2.0f;
    frame.size.height = fontSize;
    frame.origin.y = (self.frame.size.height - frame.size.height) * 0.5f;
    _cursor.frame = frame;
    [self _positionCursor];
    self.isWriting = NO;
}

- (void)startAnimating {
    [self _handleTimer:nil];
    self.isWriting = YES;
}

- (void)stopTimers {
    [_cursorTimer invalidate];
    _cursorTimer = nil;
    [_textTimer invalidate];
    _textTimer = nil;
}

- (void)setIsWriting:(BOOL)isWriting {
    _isWriting = isWriting;
    if (isWriting) {
        _cursor.hidden = NO;
        [_cursorTimer invalidate];
        _cursorTimer = nil;
    } else {
        [self _createCursorTimer];
    }
}

@end

@implementation HTLabel (Private)

- (void)_handleTimer:(id)sender {
    [_textTimer invalidate];
    _textTimer = nil;
    if (_textIndex < _animatedText.length) {
        _textIndex++;
        [self _createTimer];
    } else {
        if ([self.delegate respondsToSelector:@selector(labelDidStopAnimating:)]) {
            [self.delegate labelDidStopAnimating:self];
        }
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
    [_textTimer invalidate];
    _textTimer = [NSTimer timerWithTimeInterval:[self _randomTimeInterval] target:self selector:@selector(_handleTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_textTimer forMode:NSDefaultRunLoopMode];
}

- (void)_createCursorTimer {
    [_cursorTimer invalidate];
    _cursorTimer = [NSTimer timerWithTimeInterval:HT_CURSOR_TIMER_INTERVAL target:self selector:@selector(_handleCursor:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_cursorTimer forMode:NSDefaultRunLoopMode];
}

- (void)_positionCursor {
    CGRect cursorFrame = _cursor.frame;
    cursorFrame.origin.x = [self.text sizeWithFont:self.font].width;
    _cursor.frame = cursorFrame;
}

- (CGFloat)_fontSizeForText:(NSString *)string {
    UILabel * label = [[UILabel alloc] initWithFrame:self.frame];
    label.text = string;
    label.font = [UIFont systemFontOfSize:self.frame.size.width * HT_LABEL_FONT_FACTOR];
    CGFloat fontSize;
    [label.text sizeWithFont:label.font minFontSize:10.0f actualFontSize:&fontSize forWidth:label.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
    return fontSize - 1.0f; //to see the cursor
}

@end
