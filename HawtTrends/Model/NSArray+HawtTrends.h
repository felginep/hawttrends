//
//  NSArray+HawtTrends.h
//  HawtTrends
//
//  Created by Pierre Felgines on 22/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HawtTrends)

+ (instancetype)arrayWithObject:(id)object numberOfOccurences:(NSInteger)numberOfOccurrences;

- (NSArray *)map:(id(^)(id obj))block;

@end
