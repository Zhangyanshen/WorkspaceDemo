//
//  ViewController.m
//  BookManager
//
//  Created by 张延深 on 2020/1/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "ViewController.h"
#import <BookObtain/BookObtain.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *bookLbl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BookObtainBundle.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = [[bundle resourcePath] stringByAppendingPathComponent:@"1.jpeg"];
    self.imgView.image = [UIImage imageWithContentsOfFile:imgPath];
}

- (IBAction)obtainBookInfo:(UIButton *)sender {
    Book *book = [BookObtain obtainBookWithURL:@"xxx"];
    self.bookLbl.text = [NSString stringWithFormat:@"name:%@\nprice:%.2lf\ncontent:%@", book.name, book.price, book.content];
}

@end
