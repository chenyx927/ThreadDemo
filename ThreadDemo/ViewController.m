//
//  ViewController.m
//  ThreadDemo
//
//  Created by 陈永叙 on 2018/11/1.
//  Copyright © 2018年 陈永叙. All rights reserved.
//

#import "ViewController.h"
#import "CYXOperation.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSInteger curttIndex;
@property (nonatomic, strong) UIView *actionListView;
@property (nonatomic, strong) NSArray *actionNames;
@property (nonatomic, strong) NSArray *actionNamesDesc;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, assign) NSInteger ticketSurplusCount;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) dispatch_semaphore_t semaphoreLock;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self navigationBarInit];
    [self actionListViewInit];
    self.ticketSurplusCount = 10;
    self.lock = [[NSLock alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupUI{
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.frame = CGRectMake(10, 64,[[UIScreen mainScreen] bounds].size.width-20 , 50);
    self.descLabel.textColor = [UIColor blueColor];
    self.descLabel.text = @"欢迎大家参与iOS多线程相关知识的分享";
    self.descLabel.numberOfLines = 2;
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.descLabel];
    
    self.inputView = [[UITextView alloc] init];
    self.inputView.frame = CGRectMake(10, 64+50, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height - 64-50);
    self.inputView.editable = NO;
    self.inputView.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.inputView];
}
- (void)actionDemoWithType:(NSInteger)actionType
{
    self.inputView.text = @"";
    self.ticketSurplusCount = 50;
    self.descLabel.text = self.actionNamesDesc[actionType];
    switch (actionType) {
        case 0:
        {
            [self threadCreat];
            break;
        }
        case 1:
        {
            [self threadNoSafeAction];
            break;
        }
            
        case 2:
        {
            [self threadSafeAction];
            break;
        }
        case 3:
        {
            [self asyncAndSyncCreat];
            break;
        }
        case 4:
        {
            [self syncOncurrentAction];
            break;
        }
        case 5:
        {
            [self asyncOncurrentAction];
            break;
        }
        case 6:
        {
            [self syncSerialAction];
            break;
        }
        case 7:
        {
            [self asyncSerialAction];
            break;
        }
        case 8:
        {
            [self dispatchGroup];
             break;
        }
        case 9:
        {
            [self invocationOperation];
            break;
        }
        case 10:
        {
            [self blockOperationAddExecutionBlock];
            break;
        }
        case 11:
        {
            [self addOperationToQueue];
            break;
        }
        case 12:
        {
            [self addOperationToQueueWithBlock];
            break;
        }
        case 13:
        {
            [self addDependency];
            break;
        }
        case 14:
        {
            [self operationSafe];
            break;
        }
            
        
            
        default:
            break;
    }
}
#pragma mark----------------NSThread相关-------------------
- (void)threadCreat
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(nsthreadAction:) object:@{@"name":@"alloc"}];
    [thread start];
    
    //[NSThread detachNewThreadSelector:@selector(nsthreadAction:) toTarget:self withObject:@{@"name":@"detachNewThreadSelector"}];
    
   // [self performSelectorInBackground:@selector(nsthreadAction:) withObject:@{@"name":@"performSelectorInBackground"}];
    
   // [self performSelector:@selector(nsthreadAction:) withObject:@{@"name":@"performSelector"}];
    
    //[self performSelectorOnMainThread:@selector(nsthreadAction:) withObject:@{@"name":@"performSelectorOnMainThread"} waitUntilDone:YES];
    
}

- (void)nsthreadAction:(NSDictionary *)obj
{
    for (int i = 0; i < 2; i++) {
        [self accessibilityAssistiveTechnologyFocusedIdentifiers];
        [self logInfo:[NSString stringWithFormat:@"当前所在线程信息：%@",[NSThread currentThread]]];
        if (i == 1) {
            [self performSelectorOnMainThread:@selector(threadOnMainAction:) withObject:@{@"name":@"performSelectorOnMainThread"} waitUntilDone:YES];
        }
    }
}
- (void)threadOnMainAction:(NSDictionary *)obj
{
    [self logInfo:[NSString stringWithFormat:@"从线程切回主线程：%@",[NSThread currentThread]]];
}

- (void)threadNoSafeAction
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicketNoLockAction) object:nil];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicketNoLockAction) object:nil];
    thread.name = @"北京火车票售票窗口";
    thread1.name = @"上海火车票售票窗口";
    [thread start];
    [thread1 start];
}
- (void)threadSafeAction
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicketAction) object:nil];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTicketAction) object:nil];
    thread.name = @"北京火车票售票窗口";
    thread1.name = @"上海火车票售票窗口";
    [thread start];
    [thread1 start];
    
}

- (void)sellTicketNoLockAction
{
    while (1) {
        //如果还有票，继续售卖
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount --;
            [self logInfo:[NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]];
            [NSThread sleepForTimeInterval:0.2];
        }
        //如果已卖完，关闭售票窗口
        else {
            [self logInfo:@"所有火车票均已售完"];
            break;
        }

    }
}

- (void)sellTicketAction
{
    while (1) {
        @synchronized (self) {
            //如果还有票，继续售卖
            if (self.ticketSurplusCount > 0) {
                self.ticketSurplusCount --;
                [self logInfo:[NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]];
                [NSThread sleepForTimeInterval:0.2];
            }
            //如果已卖完，关闭售票窗口
            else {
                [self logInfo:@"所有火车票均已售完"];
                break;
            }
        }
    }
}



#pragma mark----------------GCD相关-------------------
-(void)asyncAndSyncCreat
{
    [self logInfo:@"线程测试开始-----1"];
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async( queue, ^{
        for (int i = 0; i < 2; i++) {
             [self logInfo:[NSString stringWithFormat:@"异步---%@", [NSThread currentThread]]];
        }
    });
     [self logInfo:@"线程测试中-----2"];
    
    dispatch_sync( queue, ^{
        for (int i = 0; i < 2; i++) {
            [self logInfo:[NSString stringWithFormat:@"同步---%@", [NSThread currentThread]]];
        }
    });
    [self logInfo:@"线程测试结束-----3"];
}
//同步+并发
- (void)syncOncurrentAction
{
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i++) {
           [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 4; i++) {
            [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    });
    //dispatch_get_main_queue();
    //dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    //dispatch_get_global_queue(0, 0);
    //dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
}

//异步+并发
- (void)asyncOncurrentAction
{
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
             [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    });
}

//同步+串行
- (void)syncSerialAction
{
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
              [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    });
}
//异步+串行
- (void)asyncSerialAction
{
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    });
}
//同步+主队列
- (void)syncMain
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    });
}

//异步+主队列
- (void)asyncMain
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
}

- (void)dispatchGroup
{
    dispatch_queue_t queue1 =  dispatch_get_global_queue(0, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group,queue1,^{
        for (int i = 0; i < 3; i++) {
          [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    });
    dispatch_group_async(group,queue1, ^{
        for (int i = 0; i < 3; i++) {
           [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    });
    
    dispatch_group_async(group,queue1, ^{
        for (int i = 0; i < 3; i++) {
           [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    });
    [self logInfo:@"如果不使用dispatch_group_notify监听的话，我就插队了"];
    dispatch_group_notify(group, queue1, ^{
         [self logInfo:@"以上执行完成后才执行这里！！！"];
    });
}

- (void)semaphoreSaleTicket
{
    self.semaphoreLock = dispatch_semaphore_create(1);
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_CONCURRENT);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_CONCURRENT);
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf semaphoreSaleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf semaphoreSaleTicketSafe];
    });
    
}

- (void)semaphoreSaleTicketSafe
{
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(self.semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {  //如果还有票，继续售卖
            self.ticketSurplusCount--;
            [self logInfo:[NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", (long)self.ticketSurplusCount, [NSThread currentThread]]];
            [NSThread sleepForTimeInterval:0.2];
        } else { //如果已卖完，关闭售票窗口
            [self logInfo:@"所有火车票均已售完"];
            // 相当于解锁
            dispatch_semaphore_signal(self.semaphoreLock);
            break;
        }
        
        // 相当于解锁
        dispatch_semaphore_signal(self.semaphoreLock);
    }
}

- (void)barrierGCD
{
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_barrier_async(queue, ^{
        
    });

    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
   

}

#pragma mark----------------NSOperation相关-------------------
- (void)invocationOperation
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationAction) object:nil];
    [operation start];
    
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        for (int i = 0; i < 2; i++) {
//            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
//            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
//        }
//    }];
//    [operation start];
}
- (void)invocationOperationAction
{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
        [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
    }
    
}
- (void)invocationOperationAction2
{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
         [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
    }
    
}

- (void)blockOperationAddExecutionBlock
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    }];
    
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    }];
    
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    }];
    
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    }];
    
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"5---%@", [NSThread currentThread]]];
        }
    }];
    
    [operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"6---%@", [NSThread currentThread]]];
        }
    }];
    [operation start];
}

- (void)addOperationToQueue
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationAction) object:nil];
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationAction2) object:nil];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    }];
    [blockOperation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    }];
    CYXOperation *cyxOperation = [[CYXOperation alloc] init];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:blockOperation];
    [queue addOperation:cyxOperation];
    
}
- (void)addOperationToQueueWithBlock
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
           [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
             [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    }];
}

- (void)addDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    }];
    [blockOperation1 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    }];
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
    }];
    NSBlockOperation *blockOperation3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
        }
    }];
    [blockOperation2 addDependency:blockOperation1];
    [blockOperation3 addDependency:blockOperation2];
    [queue addOperation:blockOperation1];
    [queue addOperation:blockOperation2];
    [queue addOperation:blockOperation3];
}

- (void)switchOperation
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"1---%@", [NSThread currentThread]]];
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"2---%@", [NSThread currentThread]]];
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
            [self logInfo:[NSString stringWithFormat:@"3---%@", [NSThread currentThread]]];
        }
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:0.2]; // 模拟耗时操作
                [self logInfo:[NSString stringWithFormat:@"4---%@", [NSThread currentThread]]];
            }
        }];
    }];
    
}

- (void)operationNotSafe
{
    NSOperationQueue *que = [[NSOperationQueue alloc] init];
    [que addOperationWithBlock:^{
        [self saleTicketNotSafe];
    }];
    [que addOperationWithBlock:^{
        [self saleTicketNotSafe];
    }];
}
- (void)operationSafe
{
    NSOperationQueue *que = [[NSOperationQueue alloc] init];
    [que addOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    [que addOperationWithBlock:^{
        [self saleTicketSafe];
    }];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            [self logInfo:[NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]]];
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        [self.lock lock];
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            [self logInfo:[NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]]];
            [NSThread sleepForTimeInterval:0.2];
        }
        
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}




- (void)logInfo:(NSString *)info
{
    if ([NSThread isMainThread]) {
        NSMutableString *currtStr = [NSMutableString stringWithString:self.inputView.text];
        [currtStr appendString:[NSString stringWithFormat:@"\n%@",info]];
        self.inputView.text = currtStr;
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMutableString *currtStr = [NSMutableString stringWithString:self.inputView.text];
            [currtStr appendString:[NSString stringWithFormat:@"\n%@",info]];
            self.inputView.text = currtStr;
        });
        
    }
    
}

#pragma mark----------------actionListViewInit-------------------
- (void)actionListViewInit{
    self.actionListView = [[UIView alloc] init];
    self.actionListView.hidden = YES;
    self.actionListView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.actionListView.backgroundColor = [UIColor blackColor];
    self.actionListView.alpha = 0.8;
    [self.view addSubview:self.actionListView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64,  [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64-40) style:UITableViewStylePlain];
    tableView.delegate        = self;
    tableView.dataSource      = self;
    tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [ self.actionListView addSubview:tableView];
    
    UIButton *surbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    surbtn.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-40, [[UIScreen mainScreen] bounds].size.width, 40);
    [self.actionListView addSubview:surbtn];
    [surbtn setTintColor:[UIColor whiteColor]];
    [surbtn setTitle:@"确定" forState:UIControlStateNormal];
    surbtn.backgroundColor = [UIColor redColor];
    [surbtn addTarget:self action:@selector(selectActionClick) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)selectActionClick
{
    self.actionListView.hidden = YES;
}
#pragma mark----------------navigationBarInit-------------------
- (void)navigationBarInit
{
    self.actionNames = @[@"NSThreadAction初始化",@"NSthreadNoSafeAction不不安全机制",@"NSthreadSafeAction安全机制",@"asyncAndSyncCreat同步和异步初始化",@"同步+并发",@"异步+并发",@"同步+串行",@"异步+串行",@"dispatch_group_notify",@"operationc初始化",@"NSBlockOperation",@"addOperationToQueue",@"addOperationToQueueWithBlock",@"addDependency",@"operation安全机制"];
    self.actionNamesDesc = @[@"NSThread基本使用",@"NSThread线程抢夺资源无安全机制下会出现资源紊乱",@"NSThread线程安全机制互斥锁使用",@"接下来我们看看在同一个队列里异步和同步的表现现象，主要查看所在线程",@"接下来我们看看同步线程和并发队列组合在一起是什么样的效果",@"接下来我们看看异步线程和并发队列组合在一起是什么样的效果",@"接下来我们看看同步线程和串行队列组合在一起是什么样的效果",@"接下来我们看看异步线程和串行队列组合在一起是什么样的效果",@"接下来我们看看GCD里面组与监听的相关知识点",@"关于NSOperation的一些初始化",@"NSBlockOperation直接添加操作,以及所在线程",@"将NSInvocationOperation或者NSBlockOperation对象添加到队列",@"直接通过NSOperationQueue的block方法添加操作",@"NSOperation对象之间添加依赖",@"Operation抢夺资源的安全机制"];
    UIView *navigationBar = [[UIView alloc] init];
    navigationBar.backgroundColor = [UIColor blueColor];
    navigationBar.alpha = 0.5;
    navigationBar.frame = CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 44);
    [self.view addSubview:navigationBar];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 100)/2, 11, 100, 20);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"demo";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navigationBar addSubview:titleLabel];
    
    UIButton *systemBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    systemBtn.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-30, 11, 20, 20);
    [systemBtn setTintColor:[UIColor whiteColor]];
    [navigationBar addSubview:systemBtn];
    [systemBtn addTarget:self action:@selector(showSelectActionView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    actionBtn.frame = CGRectMake(10, 11, 40, 20);
    [actionBtn setTintColor:[UIColor whiteColor]];
    [actionBtn setTitle:@"演示" forState:UIControlStateNormal];
    [navigationBar addSubview:actionBtn];
    [actionBtn addTarget:self action:@selector(actionDemoClick) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)actionDemoClick
{
    [self actionDemoWithType:self.curttIndex];
}

- (void)showSelectActionView
{
    self.actionListView.hidden = NO;
}

#pragma mark----------------UITableViewDelegate-------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actionNames.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cee_%ld",(long)indexPath.row];
      UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle         = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor greenColor];
        lineView.frame = CGRectMake(10, 49.5, [[UIScreen mainScreen] bounds].size.width-20, 0.5);
        [cell.contentView addSubview:lineView];
        cell.textLabel.textColor = [UIColor yellowColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = self.actionNames[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.curttIndex = indexPath.row;
    self.descLabel.text = self.actionNamesDesc[indexPath.row];
    self.actionListView.hidden = YES;
    [self actionDemoClick];
}

@end
