//
//  HTCellView.h
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HTAnimationTypeTop = 0,
    HTAnimationTypeRight = 1,
    HTAnimationTypeBottom = 2,
    HTAnimationTypeLeft
} HTAnimationType;

@interface HTCellView : UIView

@property (retain, nonatomic) IBOutlet UIView * contentView;

@end
