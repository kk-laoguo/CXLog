//
//  CXConsole.m
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import "CXConsole.h"
#import "CXConsoleController.h"
#import "UIView+Console.h"
#import "CXConsoleFileManager.h"

@interface CXConsole ()

@property(nonatomic, strong) UIWindow *consoleWindow;
@property(nonatomic, strong) CXConsoleController *controller;
@property(nonatomic, assign) BOOL printLog;

@end

@implementation CXConsole


#pragma mark - Intial Methods
+ (instancetype)sharedInstance {
    
    static CXConsole *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}
#pragma mark - Public Methods
+ (void)show {

    CXConsole *console = [CXConsole sharedInstance];
    if (!console.printLog) {
        [[CXConsoleFileManager sharedIntance] configuration];
    }
    [console initConsoleWindowIfNeeded];
    console.consoleWindow.hidden = NO;
}
+ (void)printLog:(id)logString {
    CXConsole *console = [CXConsole sharedInstance];
    console.printLog = YES;
    [CXConsole show];
    [console.controller printLog:logString];
}
+ (void)clear {
    [[CXConsole sharedInstance].controller clear];
}
+ (void)hide {
    [CXConsole sharedInstance].consoleWindow.hidden = YES;
    [[CXConsole sharedInstance].controller clear];
}

#pragma mark - Private Methods
- (void)initConsoleWindowIfNeeded {
    
    if (!_consoleWindow) {
        _consoleWindow = [[UIWindow alloc] init];
        __weak __typeof(self)weakSelf = self;
        _consoleWindow.cx_hitTestBlock = ^UIView *(CGPoint point, UIEvent *event, UIView *originalView) {
            return originalView == weakSelf.consoleWindow ? nil : originalView;
        };
        _consoleWindow.backgroundColor = nil;
        _controller = [[CXConsoleController alloc] init];
        _controller.printLog = self.printLog;
        _consoleWindow.rootViewController = _controller;
    }
}

@end
