//
//  CYXOperation.m
//  ThreadDemo
//
//  Created by 陈永叙 on 2018/11/1.
//  Copyright © 2018年 陈永叙. All rights reserved.
//

#import "CYXOperation.h"

@implementation CYXOperation
- (void)main
{
    if (!self.isCancelled) {
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"我来自继承对象---%@", [NSThread currentThread]); // 打印当前线程
        }
    }
    
}
@end
