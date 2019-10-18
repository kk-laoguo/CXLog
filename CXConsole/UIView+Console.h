//
//  UIView+console.h
//  JDLog
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 JD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIView *(^CX_HitTestBlock)(CGPoint point, UIEvent *event, UIView *originalView);

@interface UIView (Console)
/**
 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
 */
@property(nonatomic, assign, readonly) UIEdgeInsets cx_safeAreaInsets;
/// 等价于 CGRectGetMinY(frame)
@property(nonatomic, assign) CGFloat cx_top;
/// 等价于 CGRectGetMinX(frame)
@property(nonatomic, assign) CGFloat cx_left;
/// 等价于 CGRectGetMaxY(frame)
@property(nonatomic, assign) CGFloat cx_bottom;
/// 等价于 CGRectGetMaxX(frame)
@property(nonatomic, assign) CGFloat cx_right;
/// 等价于 CGRectGetWidth(frame)
@property(nonatomic, assign) CGFloat cx_width;
/// 等价于 CGRectGetHeight(frame)
@property(nonatomic, assign) CGFloat cx_height;
/**
 当 hitTest:withEvent: 被调用时会调用这个 block，就不用重写方法了
 point 事件产生的 point
 event 事件
 super 的返回结果
 */
@property(nonatomic, copy) CX_HitTestBlock cx_hitTestBlock;

@end

