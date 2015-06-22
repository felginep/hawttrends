//
//  NSArray+HawtTrends.m
//  HawtTrends
//
//  Created by Pierre Felgines on 22/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import "NSArray+HawtTrends.h"

@implementation NSArray (HawtTrends)

+ (instancetype)arrayWithObject:(id)object numberOfOccurences:(NSInteger)numberOfOccurrences {
    NSParameterAssert(object != nil);
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0; i < numberOfOccurrences; i++) {
        [array addObject:object];
    }
    return [array copy];
}

- (NSArray *)map:(id(^)(id obj))block {
    NSMutableArray * array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:block(obj)];
    }];
    return [array copy];
}

@end
