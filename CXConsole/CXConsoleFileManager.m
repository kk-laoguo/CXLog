//
//  CXConsoleManager.m
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import "CXConsoleFileManager.h"
#import "CXMonitorFileChange.h"

@interface CXConsoleFileManager ()
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) CXMonitorFileChange *fileChange;
@end

@implementation CXConsoleFileManager

#pragma mark - Intial Methods
+ (instancetype)sharedIntance {
    
    static CXConsoleFileManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}
+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedIntance];
}
#pragma mark - Public Methods

- (void)configuration {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    NSString *fileName = @"CXConsole.log";
    self.filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // freopen 重定向输出输出流，将log输入到文件
    freopen([self.filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([self.filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
}
- (NSString *)readLog {
    NSString *string;
    if (self.filePath) {
        string = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
    }
    return string;
}
- (void)watchLog:(void (^)(NSInteger))completeBlock {
    
    [self.fileChange watcherForPath:self.filePath block:^(NSInteger type) {
        if (completeBlock) {
            completeBlock(type);
        }
    }];
}
- (void)stopWatch {
    self.filePath = nil;
}
- (void)clearLog {
    [@"" writeToFile:self.filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (CXMonitorFileChange *)fileChange {
    if (!_fileChange) {
        _fileChange = [[CXMonitorFileChange alloc] init];
    }
    return _fileChange;
}

@end
