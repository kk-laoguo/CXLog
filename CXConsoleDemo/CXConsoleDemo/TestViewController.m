//
//  TestViewController.m
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import "TestViewController.h"

#import "CXConsole.h"

@interface TestViewController () {
    NSTimer *_timer;
}

@end

@implementation TestViewController

- (void)dealloc {
    NSLog(@"------->%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"------->%s", __func__);
}

- (IBAction)startPrintLog:(id)sender {
   
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(log) userInfo:nil repeats:YES];
}

- (IBAction)stopPrintLog:(id)sender {
    
    [_timer invalidate];
    _timer = nil;

}

- (void)log {
    long i = random();
    NSLog(@"%ld",i);
    NSLog(@"%@",self);
    [CXConsole printLog:@"NSString log"];
}


@end
