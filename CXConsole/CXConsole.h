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
+ (void)show;
+ (void)clear;
+ (void)hide;

@end


