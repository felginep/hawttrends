//
//  HTGridSizeSelector.m
//  HawtTrends
//
//  Created by Pierre Felgines on 20/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTGridSizeSelector.h"

@interface HTGridSizeSelector () {
    BOOL _isCollapsed;
    HTPosition _currentPosition;
    NSMutableArray * _squares;
}
@end

@implementation HTGridSizeSelector

- (void)dealloc {
    _squares = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _squareNumbers = 3;
        _squareMargin = 2.0f;
        _isCollapsed = YES;
        _squares = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    for (UIView * subview in self.subviews) {
        [subview removeFromSuperview];
    }

    [_squares removeAllObjects];

    CGFloat size = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat squareSize = (size - (_squareNumbers - 1) * _squareMargin) / _squareNumbers;
    for (int i = 0; i < _squareNumbers; i++) {
        for (int j = 0; j < _squareNumbers; j++) {
            CGRect frame = CGRectMake(i * (squareSize + _squareMargin),
                                      j * (squareSize + _squareMargin),
                                      squareSize,
                                      squareSize);
            UIView * view = [[UIView alloc] initWithFrame:frame];
            view.userInteractionEnabled = NO;
            if (_isCollapsed) {
                view.backgroundColor = [UIColor whiteColor];
            } else {
                if (i == _currentPosition.row && j == _currentPosition.column) {
                    [self _updateViewColor:view forType:HTSquareTypeSelected];
                } else {
                    [self _updateViewColor:view forType:HTSquareTypeEmpty];
                }
            }
            [_squares addObject:view];
            [self addSubview:view];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-44, -44, -44, -44);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _expand];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint position = [[touches anyObject] locationInView:self];
    position = [self _inBoundsPosition:position];

    int row = position.x / (40.0f + _squareMargin);
    int column = position.y / (40.0f + _squareMargin);

    _currentPosition.row = row;
    _currentPosition.column = column;

    for (int i = 0; i < _squareNumbers; i++) {
        for (int j = 0; j < _squareNumbers; j++) {
            UIView * view = _squares[i * _squareNumbers + j];
            if (i <= _currentPosition.row && j <= _currentPosition.column) {
                [self _updateViewColor:view forType:HTSquareTypeSelected];
            } else {
                [self _updateViewColor:view forType:HTSquareTypeEmpty];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _collapse];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint position = [[touches anyObject] locationInView:self];
    position = [self _inBoundsPosition:position];

    int i = position.x / (40.0f + _squareMargin);
    int j = position.y / (40.0f + _squareMargin);

    HTPosition finalPosition;
    finalPosition.row = i;
    finalPosition.column = j;
    if ([self.delegate respondsToSelector:@selector(gridSelector:didChoosePosition:)]) {
        [self.delegate gridSelector:self didChoosePosition:finalPosition];
    }

    [self _collapse];
}

#pragma mark - Private methods

- (CGPoint)_inBoundsPosition:(CGPoint)position {
    if (position.x > self.frame.size.width) {
        position.x = self.frame.size.width;
    }
    if (position.x < 0) {
        position.x = 0;
    }
    if (position.y > self.frame.size.height) {
        position.y = self.frame.size.height;
    }
    if (position.y < 0) {
        position.y = 0;
    }
    return position;
}

- (void)_collapse {
    if (!_isCollapsed) {
        _isCollapsed = YES;
        _squareNumbers = 3;
        _currentPosition.row = _currentPosition.column = 0;
        [self _updateFrame];
        [self setNeedsLayout];
    }
}

- (void)_expand {
    if (_isCollapsed) {
        _isCollapsed = NO;
        _squareNumbers = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 3 : 5;
        [self _updateFrame];
        [self setNeedsLayout];
    }
}

- (void)_updateFrame {
    CGFloat size = _isCollapsed ? 20.0f : _squareNumbers * 40.0f + (_squareNumbers - 1) * _squareMargin;
    CGRect frame = self.frame;
    frame.size.height = frame.size.width = size;
    self.frame = frame;
}

- (void)_updateViewColor:(UIView *)view forType:(HTSquareType)type {
    switch (type) {
        case HTSquareTypeEmpty:
            view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
            view.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
            view.layer.borderWidth = 1.0f;
            break;
        case HTSquareTypeSelected:
            view.backgroundColor = [UIColor whiteColor];
            view.layer.borderWidth = 0.0f;
            break;
        case HTSquareTypeCurrent:
            view.backgroundColor = [UIColor grayColor];
            view.layer.borderWidth = 0.0f;
            break;
        default:
            break;
    }
}


@end

