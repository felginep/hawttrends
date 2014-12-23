//
//  HTTextView.m
//  HawtTrends
//
//  Created by Pierre on 25/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTTextView.h"
#import "HTTermsDownloader.h"

#define HT_TIMER_INTERVAL 0.25f
#define HT_EPSILON 0.10f
#define HT_CURSOR_TIMER_INTERVAL 0.4f
#define HT_LABEL_FONT_FACTOR 0.113f

struct HTTextAttribute {
    CGFloat fontSize;
    CGFloat pixelOffset;
};
typedef struct HTTextAttribute HTTextAttribute;

@interface HTTextView () {
    NSString * _animatedText;
    NSUInteger _textIndex;
    UIView * _cursor;
    NSTimer * _cursorTimer;
    NSTimer * _textTimer;
    UITextView * _textView;
    NSMutableDictionary * _textAttributes;
}
@property (nonatomic, assign) BOOL isWriting;
@end

@implementation HTTextView

- (void)dealloc {
    _animatedText = nil;
    _textView = nil;
    _cursor = nil;
    _shadowColor = nil;
    _textColor = nil;
    _textAttributes = nil;
    [self stopTimers];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cursor = [[UIView alloc] init];
        _cursor.backgroundColor = [UIColor blackColor];
        [self addSubview:_cursor];

        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.backgroundColor = [UIColor clearColor];
        [self addSubview:_textView];

        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.dataDetectorTypes = UIDataDetectorTypeNone;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.userInteractionEnabled = NO;

        self.isWriting = NO;

        _textAttributes = [NSMutableDictionary dictionaryWithDictionary:@{ NSShadowAttributeName: [[NSShadow alloc] init] }];
    }
    return self;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _textAttributes[NSForegroundColorAttributeName] = textColor;
    _cursor.backgroundColor = textColor;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    ((NSShadow *)_textAttributes[NSShadowAttributeName]).shadowColor = shadowColor;
}

- (void)setAnimatedText:(NSString *)animatedText {
    // Update text attributes
    HTTextAttribute textAttributes = [self _textAttributesFromBounds];
    _textAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:textAttributes.fontSize];
    ((NSShadow *)_textAttributes[NSShadowAttributeName]).shadowOffset = CGSizeMake(textAttributes.pixelOffset, textAttributes.pixelOffset);

    _animatedText = [animatedText copy];
    _textIndex = 0;
    _textView.text = nil;
    
    [self _setCursorFrameForTextAttributes:textAttributes];
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

#pragma mark - Private methods

- (void)_handleTimer:(id)sender {
    [_textTimer invalidate];
    _textTimer = nil;
    if (_textIndex < _animatedText.length) {
        _textIndex++;
        [self _createTimer];
    } else {
        if ([self.animationDelegate respondsToSelector:@selector(textViewDidStopAnimating:)]) {
            [self.animationDelegate textViewDidStopAnimating:self];
        }
        self.isWriting = NO;
    }

    _textView.attributedText = [[NSAttributedString alloc] initWithString:[_animatedText substringToIndex:_textIndex]
                                                               attributes:_textAttributes];

    CGSize sizeToFitIn = [_textView sizeThatFits:self.bounds.size];
    CGRect frame = _textView.frame;
    frame.size = sizeToFitIn;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2.0f;
    _textView.frame = frame;

    [self _positionCursor];
}

- (CGRect)_boundingRectForCharacterRange:(NSRange)range {
    NSRange glyphRange;
    [_textView.layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    return [_textView.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_textView.textContainer];
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
    CGRect lastCharacterRect = [self _boundingRectForCharacterRange:NSMakeRange(_textView.text.length - 1, 1)];

    CGRect cursorFrame = _cursor.frame;
    cursorFrame.origin.x = lastCharacterRect.origin.x + lastCharacterRect.size.width + [self _textAttributesFromBounds].pixelOffset;
    cursorFrame.origin.y = lastCharacterRect.origin.y + _textView.frame.origin.y;
    _cursor.frame = cursorFrame;
}

- (HTTextAttribute)_textAttributesFromBounds {
    HTTextAttribute textAttributes;
    if (self.bounds.size.width > self.bounds.size.height) {
        textAttributes.fontSize = self.bounds.size.height / 4.0f;
    } else {
        textAttributes.fontSize = self.bounds.size.width / 8.0f;
    }
    textAttributes.pixelOffset = (int)(textAttributes.fontSize / 50.0f) + 1;
    return textAttributes;
}

- (void)_setCursorFrameForTextAttributes:(HTTextAttribute)textAttributes {
    CGRect frame = _cursor.frame;
    frame.size.width = textAttributes.pixelOffset;
    frame.size.height = textAttributes.fontSize;
    _cursor.frame = frame;
}

@end
