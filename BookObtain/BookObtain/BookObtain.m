//
//  BookObtain.m
//  BookObtain
//
//  Created by 张延深 on 2020/1/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "BookObtain.h"

@implementation BookObtain

+ (Book *)obtainBookWithURL:(NSString *)urlString {
    NSDictionary *info = @{
        @"name": @"算法导论",
        @"price": @(125.0),
        @"content": @"内容太长，xxx意思一下..."
    };
    Book *book = [Book bookWithInfo:info];
    return book;
}

@end
