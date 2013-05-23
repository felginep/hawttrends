//
//  UIColor+Trends.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "UIColor+Trends.h"

@implementation UIColor (Trends)

+ (UIColor *)randomTrendColor {
    static NSArray * sTrendColors = nil;
    if (!sTrendColors) {
        sTrendColors = @[[UIColor colorWithRed:243.0f green:179.0f blue:0], //orange
                        [UIColor colorWithRed:66.0f green:133.0f blue:244.0f], //blue
                        [UIColor colorWithRed:218.0f green:68.0f blue:55.0f], //red
                        [UIColor colorWithRed:15.0f green:157.0f blue:88.0f]]; //green
    }
    
    int randIndex = (int)(((float)rand() / (float)RAND_MAX) * 4.0f);
    return sTrendColors[randIndex];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.0];
}

@end
