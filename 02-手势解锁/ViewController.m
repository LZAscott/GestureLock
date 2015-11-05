//
//  ViewController.m
//  02-手势解锁
//
//  Created by Scott_Mr on 15/11/5.
//  Copyright © 2015年 Scott_Mr. All rights reserved.
//

#import "ViewController.h"
#import "LockView.h"

@interface ViewController ()<LockViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)lockViewDidClick:(LockView *)view andPassWord:(NSString *)psd {
    NSLog(@"%@",psd);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
