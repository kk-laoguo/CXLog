//
//  CXConsoleManager.h
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CXConsoleFileManager : NSObject

+ (instancetype)sharedIntance;

- (void)configuration;

- (NSString *)readLog;

- (void)watchLog:(void(^)(NSInteger type))completeBlock;

- (void)stopWatch;

- (void)clearLog;


@end

