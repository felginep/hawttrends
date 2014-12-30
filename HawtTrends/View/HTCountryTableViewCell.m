//
//  HTCountryTableViewCell.m
//  HawtTrends
//
//  Created by Pierre on 22/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCountryTableViewCell.h"
#import "UIColor+HawtTrends.h"

@implementation HTCountryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_label];

        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor htBlue];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        [UIView animateWithDuration:0.1f animations:^{
            _label.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
            _label.alpha = 0.9f;
        }];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            _label.transform = CGAffineTransformIdentity;
            _label.alpha = 1.0f;
        }];
    }
}

@end
