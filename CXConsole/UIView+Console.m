//
//  UIView+console.m
//  JDLog
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 JD. All rights reserved.
//

#import "UIView+Console.h"
#import <objc/runtime.h>

CG_INLINE BOOL
HasOverrideSuperclassMethod(Class targetClass, SEL targetSelector) {
    Method method = class_getInstanceMethod(targetClass, targetSelector);
    if (!method) return NO;
    Method methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector);
    if (!methodOfSuperclass) return YES;
    return method != methodOfSuperclass;
}

/**
 *  用 block 重写某个 class 的指定方法
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做
 *  @param implementationBlock 该 block 必须返回一个 block，返回的 block 将被当成 targetSelector 的新实现，所以要在内部自己处理对 super 的调用，以及对当前调用方法的 self 的 class 的保护判断（因为如果 targetClass 的 targetSelector 是继承自父类的，targetClass 内部并没有重写这个方法，则我们这个函数最终重写的其实是父类的 targetSelector，所以会产生预期之外的 class 的影响，例如 targetClass 传进来  UIButton.class，则最终可能会影响到 UIView.class），implementationBlock 的参数里第一个为你要修改的 class，也即等同于 targetClass，第二个参数为你要修改的 selector，也即等同于 targetSelector，第三个参数是一个 block，用于获取 targetSelector 原本的实现，由于 IMP 可以直接当成 C 函数调用，所以可利用它来实现“调用 super”的效果，但由于 targetSelector 的参数个数、参数类型、返回值类型，都会影响 IMP 的调用写法，所以这个调用只能由业务自己写。
 */
CG_INLINE BOOL
OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void))) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    IMP imp = method_getImplementation(originMethod);
    BOOL hasOverride = HasOverrideSuperclassMethod(targetClass, targetSelector);
    
    // 以 block 的方式达到实时获取初始方法的 IMP 的目的，从而避免先 swizzle 了 subclass 的方法，再 swizzle superclass 的方法，会发现前者的方法调用不会触发后者 swizzle 后的版本的 bug。
    IMP (^originalIMPProvider)(void) = ^IMP(void) {
        IMP result = NULL;
        // 如果原本 class 就没人实现那个方法，则返回一个空 block，空 block 虽然没有参数列表，但在业务那边被转换成 IMP 后就算传多个参数进来也不会 crash
        if (!imp) {
            result = imp_implementationWithBlock(^(id selfObject){
                NSLog(([NSString stringWithFormat:@"%@", targetClass]), @"%@ 没有初始实现，%@\n%@", NSStringFromSelector(targetSelector), selfObject, [NSThread callStackSymbols]);
            });
        } else {
            if (hasOverride) {
                result = imp;
            } else {
                Class superclass = class_getSuperclass(targetClass);
                result = class_getMethodImplementation(superclass, targetSelector);
            }
        }
        return result;
    };
    
    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    } else {
        NSMethodSignature *methodSignature = [targetClass instanceMethodSignatureForSelector:targetSelector];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *methodSignatureStr = [methodSignature performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
#pragma clang diagnostic pop
        const char *typeEncoding = method_getTypeEncoding(originMethod) ? :methodSignatureStr.UTF8String;
        
        class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
    }
    
    return YES;
}

#define ExtendImplementationOfNonVoidMethodWithTwoArguments(_targetClass, _targetSelector, _argumentType1, _argumentType2, _returnType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
return ^_returnType (__unsafe_unretained __kindof NSObject *selfObject, _argumentType1 firstArgv, _argumentType2 secondArgv) {\
\
_returnType (*originSelectorIMP)(id, SEL, _argumentType1, _argumentType2);\
originSelectorIMP = (_returnType (*)(id, SEL, _argumentType1, _argumentType2))originalIMPProvider();\
_returnType result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);\
\
return _implementationBlock(selfObject, firstArgv, secondArgv, result);\
};\
});

@implementation UIView (Console)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.cx_hitTestBlock) {
                UIView *view = selfObject.cx_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });
    });
    
}

- (CX_HitTestBlock)cx_hitTestBlock {
    return objc_getAssociatedObject(self, @selector(cx_hitTestBlock));
}
- (void)setCx_hitTestBlock:(CX_HitTestBlock)cx_hitTestBlock {
    objc_setAssociatedObject(self, @selector(cx_hitTestBlock), cx_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIEdgeInsets)cx_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}
- (CGFloat)cx_top {
    return CGRectGetMinY(self.frame);
}
- (void)setCx_top:(CGFloat)cx_top {
    CGRect frame = self.frame;
    frame.origin.y = cx_top;
    self.frame = frame;
}
- (CGFloat)cx_left {
    return CGRectGetMinX(self.frame);
}

- (void)setCx_left:(CGFloat)cx_left {
    CGRect frame = self.frame;
    frame.origin.x = cx_left;
    self.frame = frame;
}
- (CGFloat)cx_bottom {
    return CGRectGetMaxY(self.frame);
}
- (void)setCx_bottom:(CGFloat)cx_bottom {
    CGRect frame = self.frame;
    frame.origin.y = cx_bottom - self.frame.size.height;
    self.frame = frame;
}
- (CGFloat)cx_right {
    return CGRectGetMaxX(self.frame);
}
- (void)setCx_right:(CGFloat)cx_right {
    CGRect frame = self.frame;
    frame.origin.x = cx_right - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)cx_width {
    return CGRectGetWidth(self.frame);
}
- (void)setCx_width:(CGFloat)cx_width {
    CGRect frame = self.frame;
    frame.size.width = cx_width;
    self.frame = frame;
}
- (CGFloat)cx_height {
    return CGRectGetHeight(self.frame);
}
- (void)setCx_height:(CGFloat)cx_height {
    CGRect frame = self.frame;
    frame.size.height = cx_height;
    self.frame = frame;
}


@end
