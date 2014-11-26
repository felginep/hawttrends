//
//  HTTextView.h
//  HawtTrends
//
//  Created by Pierre on 25/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTTextViewDelegate;

@interface HTTextView : UIView

@property (nonatomic, copy) NSString * animatedText;
@property (nonatomic, weak) id<HTTextViewDelegate> animationDelegate;
@property (nonatomic, strong) UIColor * textColor;
@property (nonatomic, strong) UIColor * shadowColor;
@property (nonatomic) CGSize shadowOffset;

- (void)startAnimating;
- (void)stopTimers;

@end

@protocol HTTextViewDelegate <NSObject>
@optional
- (void)textViewDidStopAnimating:(HTTextView *)textView;
@end