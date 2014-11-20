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
@property (nonatomic, assign) id<HTGridSizeSelectorDelegate> delegate;
@end
