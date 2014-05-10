//
//  NSURLSession+jbeslkfhslf.m
//  ByteClub
//
//  Created by Alexander on 08.05.14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

#import "NSURLSession+jbeslkfhslf.h"

@implementation NSURLSession (jbeslkfhslf)

- (NSURLSessionDataTask *)JSONTaskWithURL:(NSURL *)url completionHandler:(void (^)(id JSON, NSURLResponse *response, NSError *error))completionHandler
{
    NSLog(@"%@", @"3123");
    return nil;
}
/*
- (NSURLSessionDataTask *)JSONTaskWithURL:(NSURL *)url completionHandler:(void (^)(id JSON, NSURLResponse *response, NSError *error))completionHandler
{
    return [self dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            completionHandler(nil, response, error);
            return;
        }
        
        NSError *err = nil;
        id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        completionHandler(JSON, response, err);
    }];
}*/
@end
