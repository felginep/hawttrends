//
//  HTCollectionViewCell.h
//  HawtTrends
//
//  Created by Pierre on 29/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTextView.h"

@protocol HTCollectionViewCellViewDataSource;

@interface HTCollectionViewCell : UICollectionViewCell <HTTextViewDelegate>

@property (strong, nonatomic) IBOutlet HTTextView * textView;
@property (nonatomic, weak) id<HTCollectionViewCellViewDataSource> datasource;

- (void)setNeedsAnimating;

@end

@protocol HTCollectionViewCellViewDataSource <NSObject>
- (NSString *)textToDisplayForCellView:(HTCollectionViewCell *)cellView;
@end
