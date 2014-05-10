//
//  NSURLSession+jbeslkfhslf.h
//  ByteClub
//
//  Created by Alexander on 08.05.14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (jbeslkfhslf)

- (NSURLSessionDataTask *)JSONTaskWithURL:(NSURL *)url completionHandler:(void (^)(id JSON, NSURLResponse *response, NSError *error))completionHandler;

@end
