//
//  HTLabel.h
//  HawtTrends
//
//  Created by Pierre Felgines on 09/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTLabelDelegate;

@interface HTLabel : UILabel

@property (nonatomic, copy) NSString * animatedText;
@property (nonatomic, assign) id<HTLabelDelegate> delegate;

- (void)startAnimating;
- (void)stopTimers;

@end

@protocol HTLabelDelegate <NSObject>
@optional
- (void)labelDidStopAnimating:(HTLabel *)label;
@end