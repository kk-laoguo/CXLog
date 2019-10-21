//
//  CXConsoleController.h
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXConsoleController : UIViewController

@property (nonatomic, assign) BOOL printLog;

- (void)printLog:(id)logString;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
