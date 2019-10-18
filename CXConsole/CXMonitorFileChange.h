//
//  CXMonitorConsole.h
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CXMonitorFileChange : NSObject

/**
监听文件变化
@param filePath 文件路径
@param block 变化类型，可以是删除、写入、更改等操作
*/
- (void)watcherForPath:(NSString *)filePath block:(void (^)(NSInteger type))block;

@end

