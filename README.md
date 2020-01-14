# WorkspaceDemo
> 参考：[iOS使用Workspace来管理多项目](https://www.jianshu.com/p/b6c59d8ed2c9)，个人觉得这篇文章讲解的不错。

#### 前言

Workspace，工作空间，可以用来管理多个Xcode Project，像Cocoapods一样，它的常见用法是编译静态库，然后给主工程使用，但跟普通的制作`.a`和`.framework`不同的是，它不需要先打开静态库工程编译，然后将生成的`.a`或`.framework`拷贝到主工程，最后再编译主工程，这样会造成很强的割裂感。Workspace只需要编译主工程，即可将依赖的工程一同编译，体验会更好一些。

#### 制作Workspace

##### 1.新建一个Workspace项目

菜单File -> New -> Workspace，新建一个Workspace项目，如下图所示，之后会生成一个`.xcworkspace`文件，双击打开该文件，会发现什么都没有，其实Workspace就类似一个文件夹，将不同的Project放在一起编译。

![新建Workspace项目](https://upload-images.jianshu.io/upload_images/1499740-7c90ac22b6274db4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

##### 2.向Workspace添加Project

本Demo包含2个Project，一个静态库项目`BookObtain`，另一个是主工程`BookManager`，如图，`BookObtain`用来模拟从网络下载书籍信息，`BookManager`用来展示下载的书籍信息。

![Demo工程目录](https://upload-images.jianshu.io/upload_images/1499740-4544e03f02f94f99.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

`BookObtain`核心代码如下：

```

// BookObtain.h
#import <Foundation/Foundation.h>
#import "Book.h"

@interface BookObtain : NSObject

+ (Book *)obtainBookWithURL:(NSString *)urlString;

@end

// BookObtain.m
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
```
```
// Book.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Book : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, copy) NSString *content;

+ (instancetype)bookWithInfo:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END

// Book.m
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
```

完成`BookObtain`代码编写，需要在主工程引用，这时候你会发现`#import "BookObtain.h"`报错，找不到头文件。这就是静态库引用需要做的第一件事：**指定头文件路径**。

在主工程的 Build Settings -> Header Search Paths 添加一项 `${SRCROOT}/../BookObtain`，并且设置为recursive。

![指定静态库头文件](https://upload-images.jianshu.io/upload_images/1499740-5b0dd06665e67ddf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)

现在引入头文件不报错了，在主工程的`ViewController.m`中添加如下代码：

```
// 点击按钮回去书籍信息
- (IBAction)obtainBookInfo:(UIButton *)sender {
    Book *book = [BookObtain obtainBookWithURL:@"xxx"];
    self.bookLbl.text = [NSString stringWithFormat:@"name:%@\nprice:%.2lf\ncontent:%@", book.name, book.price, book.content];
}
```

编译，发现报错：

```
Undefined symbols for architecture arm64:

"_OBJC_CLASS_$_BookObtain", referenced from:

objc-class-ref in ViewController.o
```

这涉及到引用静态库的第二个问题：**添加`.a`文件**

在主工程的  Build Phases -> Link Binary With Libraries 添加 `libBookObtain.a` 文件，如下图：

![添加静态库.a文件](https://upload-images.jianshu.io/upload_images/1499740-992a923ba8c8ab55.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)

至此，Workspace管理2个Project基本就完成了。

##### 3.bundle携带资源文件

众所周知，`.a`文件是不能携带资源文件的，那如果静态库有资源文件怎么办呢？使用bundle。

在`BookObtain`工程的`TARGETS`下添加一个新的target，类型是macOS下的`Bundle`，操作如下图：

![添加bundle](https://upload-images.jianshu.io/upload_images/1499740-cca33b60a6e9e681.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)

> 注意：因为Bundle只在macOS下才有，所以创建完成之后，需要将该target的`Base SDK`从`macOS`改为`iOS`。

然后将需要添加的资源文件拖到`Bundle`中即可。

![添加资源文件到bundle](https://upload-images.jianshu.io/upload_images/1499740-3036c663e5d0b450.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

因为主工程需要使用该Bundle中的资源文件，所以需要保证该Bundle的target优先编译，修改主工程的Build选项，让该Bundle的target在主工程target之前进行编译。

![bundle优先编译](https://upload-images.jianshu.io/upload_images/1499740-f47e8469ca1484a5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)

最后，需要将该bundle编译的产物拷贝到主工程的main bundle下。

主工程的 Build Phases 左上角点击 + 号，添加一个`New Run Script Phase`，在里面添加拷贝bundle的脚本命令，如下：

```
#!/bin/sh
cp -R ${BUILT_PRODUCTS_DIR}/BookObtainBundle.bundle ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app
```

然后就可以在主工程使用该bundle中的资源文件了。

```
NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BookObtainBundle.bundle"];
NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
NSString *imgPath = [[bundle resourcePath] stringByAppendingPathComponent:@"1.jpeg"];
self.imgView.image = [UIImage imageWithContentsOfFile:imgPath];
```

#### 总结

上面的Demo讲解了Workspace的用法，主要就是用来管理多个Project，这种方式可以消除普通静态库制作的割裂感，但是它也有弊端，就是代码是暴露出来的，比较适用于企业内部不同项目间共享代码。如果你不想让别人看到你的代码，那你只能用传统的制作静态库的方式了。

[Demo地址](https://github.com/Zhangyanshen/WorkspaceDemo)

