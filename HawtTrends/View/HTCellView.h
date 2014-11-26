//
//  HTCellView.h
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HTLabel.h"
#import "HTTextView.h"

typedef enum {
    HTAnimationTypeTop = 0,
    HTAnimationTypeRight = 1,
    HTAnimationTypeBottom = 2,
    HTAnimationTypeLeft
} HTAnimationType;

@protocol HTCellViewDataSource;

@interface HTCellView : UIView <HTLabelDelegate, HTTextViewDelegate>

@property (strong, nonatomic) IBOutlet UIView * contentView;
@property (strong, nonatomic) IBOutlet HTTextView * textView;
@property (nonatomic, weak) id<HTCellViewDataSource> datasource;

@end

@protocol HTCellViewDataSource <NSObject>
- (NSString *)textToDisplayForCellView:(HTCellView *)cellView;
@end
