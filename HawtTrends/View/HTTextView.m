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

@interface HTTextView () {
    NSString * _animatedText;
    NSUInteger _textIndex;
    UIView * _cursor;
    NSTimer * _cursorTimer;
    NSTimer * _textTimer;
    UITextView * _textView;
}
@property (nonatomic, assign) BOOL isWriting;
@end

@implementation HTTextView

- (void)dealloc {
    _animatedText = nil;
    _textView = nil;
    _cursor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTermsDownloadedNotification object:nil];
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

        CGFloat fontSize = [[HTTermsDownloader sharedDownloader] fontSizeForSize:self.bounds.size];
        _textView.font = [UIFont boldSystemFontOfSize:fontSize];
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.textContainer.lineFragmentPadding = 0;

        self.isWriting = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateFont:) name:kTermsDownloadedNotification object:nil];
    }
    return self;
}

- (void)_updateFont:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat fontSize = [[HTTermsDownloader sharedDownloader] fontSizeForSize:self.bounds.size];
        _textView.font = [UIFont boldSystemFontOfSize:fontSize];
        CGRect frame = _cursor.frame;
        frame.size.height = fontSize;
        _cursor.frame = frame;
    });
}

- (void)setTextColor:(UIColor *)textColor {
    _textView.textColor = textColor;
    _cursor.backgroundColor = textColor;
}

- (void)setAnimatedText:(NSString *)animatedText {
    _animatedText = [animatedText copy];
    _textIndex = 0;
    _textView.text = nil;
    CGFloat fontSize = _textView.font.pointSize; // to change
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
    _textView.text = [_animatedText substringToIndex:_textIndex];

    _textView.frame = self.bounds;
    [_textView sizeToFit];
    CGRect frame = _textView.frame;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2.0f;
    _textView.frame = frame;

    [self _positionCursor];
}

- (CGRect)_boundingRectForCharacterRange:(NSRange)range {
    CGFloat fontSize = _textView.font.pointSize;

    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:_textView.text attributes:@{NSFontAttributeName : _textView.font}];
    NSTextStorage * textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];

    NSTextContainer * textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];

    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];

    CGRect rect = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];

    return rect;
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
    cursorFrame.origin.x = lastCharacterRect.origin.x + lastCharacterRect.size.width + 2.0f;
    cursorFrame.origin.y = lastCharacterRect.origin.y + _textView.frame.origin.y;
    _cursor.frame = cursorFrame;
}

@end
