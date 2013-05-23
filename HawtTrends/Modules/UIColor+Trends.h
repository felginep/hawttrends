//
//  UIColor+Trends.h
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Trends)
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (NSArray *)trendColors;
+ (UIColor *)randomTrendColor;
+ (UIColor *)randomTrendColorWithBaseColor:(UIColor *)baseColor;
@end
