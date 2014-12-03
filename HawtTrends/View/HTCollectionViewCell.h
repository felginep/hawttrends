//
//  HTCollectionViewCell.h
//  HawtTrends
//
//  Created by Pierre on 29/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTextView.h"

@interface HTCollectionViewCell : UICollectionViewCell <HTTextViewDelegate>

//@property (strong, nonatomic) IBOutlet UIView * contentView;
@property (strong, nonatomic) IBOutlet HTTextView * textView;

- (void)startAnimating;
- (void)stopAnimating;
- (void)setNeedsAnimating;

@end

