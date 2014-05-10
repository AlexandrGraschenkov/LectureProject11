//
//  NSArray+FunctionalExtension.h
//  HW_Blocks
//
//  Created by Alexander on 05.04.14.
//  Copyright (c) 2014 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FunctionalExtension)

/**
 Возвращает новый массив из элементов, который вернул блок кода.
 @[mapBlock(obj1), mapBlock(obj2), mapBlock(obj3)]
 
 Например:
 NSArray *arr = @[@1, @2, @3];
 NSArray *mappedArr = [arr ex_mapObjects:^id(NSNumber *obj){
    return [NSString stringWithFormat:@"%d object", obj.integerValue];
 }];
 
 mappedArr == @[@"1 object", @"2 object", @"3 object"]
 */
- (NSArray*)ex_map:(id(^)(id obj))mapBlock;

/**
 Возвращает массив из элементов, для которых filterBlock(obj) == YES
 
 Например:
 NSArray *arr = @[@1, @2, @3, @4];
 NSArray *evenArr = [arr ex_mapObjects:^BOOL(NSNumber *obj){
    return (obj.integerValue % 2 == 0);
 }];
 
 evenArr == @[@2, @4]
 */
- (NSArray*)ex_filter:(BOOL(^)(id obj))filterBlock;

/**
 Возвращает обьект, который получился суммированием всех элементов по порядку. 
 Внутрь передается функция суммирования.
 
 Например:
 NSArray *arr = @[@"Str1", @"Str2", @"Str3"];
 NSString *result = [arr ex_sum:@"Result: " withBlock:^id(NSString *sum, NSString *obj){
    return [sum stringByAppendingString:obj];
 }];
 
 result == @"Result: Str1Str2Str3" == sumBlock( sumBlock( sumBlock(init, obj1), obj2), obj3)
 
 Пример 2:
 NSNumber *result = [@[@1, @2, @3] ex_sum:@0 withBlock:^id(NSNumber *sum, NSNumber *val){
    return [NSNumber numberWithInteger:(sum.integerValue + val.integerValue)];
 }];
 result == @6
 */
- (id)ex_sum:(id)initialValue withBlock:(id(^)(id sum, id obj))sumBlock;

@end