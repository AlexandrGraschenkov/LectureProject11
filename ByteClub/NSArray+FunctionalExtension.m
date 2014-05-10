//
//  NSArray+FunctionalExtension.m
//  HW_Blocks
//
//  Created by Alexander on 05.04.14.
//  Copyright (c) 2014 Alexander. All rights reserved.
//

#import "NSArray+FunctionalExtension.h"

@implementation NSArray (FunctionalExtension)

- (NSArray*)ex_map:(id(^)(id obj))mapBlock
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in self)
    {
        [result addObject:mapBlock(obj)];
    }
    return result;
}

- (NSArray*)ex_filter:(BOOL(^)(id obj))filterBlock
{
    NSMutableArray *result = [NSMutableArray new];
    for (id obj in self)
    {
        if (filterBlock(obj))
        {
            [result addObject:obj];
        }
    }
    return result;
}

- (id)ex_sum:(id)initialValue withBlock:(id(^)(id sum, id obj))sumBlock
{
    id result = initialValue;
    for (id obj in self)
    {
        result = sumBlock(result, obj);
    }
    return result;
}

@end
