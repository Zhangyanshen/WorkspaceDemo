//
//  Book.h
//  BookObtain
//
//  Created by 张延深 on 2020/1/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Book : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, copy) NSString *content;

+ (instancetype)bookWithInfo:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
