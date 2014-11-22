//
//  HTGridSizeSelector.h
//  HawtTrends
//
//  Created by Pierre Felgines on 20/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>

struct HTPosition {
    int row;
    int column;
};
typedef struct HTPosition HTPosition;

CG_INLINE HTPosition
HTPositionMake(int row, int column)
{
    HTPosition p; p.row = row; p.column = column; return p;
}

typedef struct HTPosition HTConfiguration;
CG_INLINE HTConfiguration
HTConfigurationMake(int row, int column)
{
    HTConfiguration p; p.row = row; p.column = column; return p;
}

CG_INLINE HTConfiguration
HTConfigurationMakeFromPosition(HTPosition position) {
    HTConfiguration p; p.row = position.row + 1; p.column = position.column + 1; return p;
}

typedef enum {
    HTSquareTypeEmpty = 0,
    HTSquareTypeCurrent,
    HTSquareTypeSelected
} HTSquareType;


@class HTGridSizeSelector;
@protocol HTGridSizeSelectorDelegate <NSObject>
- (void)gridSelector:(HTGridSizeSelector *)gridSelector didChoosePosition:(HTPosition)position;
@end

@interface HTGridSizeSelector : UIView
@property (nonatomic, assign) NSInteger squareNumbers;
@property (nonatomic, assign) CGFloat squareMargin;
@property (nonatomic, weak) id<HTGridSizeSelectorDelegate> delegate;
@end
