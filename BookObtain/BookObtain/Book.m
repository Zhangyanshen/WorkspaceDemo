//
//  Book.m
//  BookObtain
//
//  Created by 张延深 on 2020/1/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "Book.h"

@implementation Book

- (instancetype)initWithInfo:(NSDictionary *)info {
    if (self = [super init]) {
        self.name = info[@"name"];
        self.price = [info[@"price"] floatValue];
        self.content = info[@"content"];
    }
    return self;
}

+ (instancetype)bookWithInfo:(NSDictionary *)info {
    return [[self alloc] initWithInfo:info];
}

@end
