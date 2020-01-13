//
//  BookObtain.h
//  BookObtain
//
//  Created by 张延深 on 2020/1/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface BookObtain : NSObject

+ (Book *)obtainBookWithURL:(NSString *)urlString;

@end
