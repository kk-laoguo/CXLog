//
//  CXConsole.h
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXConsole : NSObject

+ (instancetype)sharedInstance;
/// 采用写文件的格式直接读取NSLog所有打印信息, 打印到控制台
+ (void)show;
/// 打印日志到控制台
/// @param logString 需要打印的日志
+ (void)printLog:(id)logString;
+ (void)clear;
+ (void)hide;

@end


