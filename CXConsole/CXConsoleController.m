//
//  CXConsoleController.m
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import "CXConsoleController.h"
#import "CXConsoleFileManager.h"
#import "UIView+Console.h"
#import "CXConsole.h"

static const CGFloat PopoverBtnPointX = 15;

@interface CXConsoleController ()
<UITextViewDelegate,
UITextFieldDelegate,
CAAnimationDelegate> {
    
    BOOL _scrollBottomAble;
}
@property(nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSString *regexString;
@property (nonatomic, strong) UIButton *popoverBtn;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *deleBtn;
@property (nonatomic, strong) UIButton *hiddenBtn;
@property(nonatomic, assign) BOOL popoverAnimating;

@end

@implementation CXConsoleController

#pragma mark - Intial Methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CXConsoleFileManager sharedIntance] stopWatch];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.popoverAnimating) {
        return;
    }
    CGSize containerViewSize = CGSizeMake(CGRectGetWidth(self.view.bounds), MAX(100, CGRectGetHeight(self.view.bounds) / 3));
    self.containerView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - containerViewSize.height, containerViewSize.width, containerViewSize.height);
    CGFloat bottomHeight = 44 + self.containerView.cx_safeAreaInsets.bottom;
    self.searchView.cx_height = bottomHeight;
    self.searchView.cx_width = self.containerView.cx_width;
    self.searchView.cx_bottom = self.containerView.cx_height;
    self.searchTextField.frame = CGRectMake(PopoverBtnPointX, 0, self.searchView.cx_width - 60, 35);
    self.deleBtn.frame = CGRectMake(self.searchView.cx_width - 45, 0, 45, 35);
    
    self.textView.cx_top = 0;
    self.textView.cx_width = containerViewSize.width;
    self.textView.cx_height = self.searchView.cx_top;
    self.hiddenBtn.frame = CGRectMake(containerViewSize.width - 40, 15, 35, 35);
    if (_scrollBottomAble) {
        [self scrollToBottom];
    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    _scrollBottomAble = YES;
    [self pm_setupUI];
    [self pm_updateTextView];
    
    __weak __typeof(self)weakSelf = self;
    self.view.cx_hitTestBlock = ^UIView *(CGPoint point, UIEvent *event, UIView *originalView) {
        if (originalView == weakSelf.view) {
            return nil;
        }
        return originalView;
    };
    
    [[CXConsoleFileManager sharedIntance] watchLog:^(NSInteger type) {
        [weakSelf pm_updateTextView];
    }];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillSHow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)pm_setupUI {
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];;
    self.containerView.hidden = YES;
    [self.view addSubview:self.containerView];
    
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.editable = NO;
    self.textView.scrollsToTop = NO;
    self.textView.textColor = [UIColor whiteColor];
    if (@available(iOS 11, *)) {
        self.textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.containerView addSubview:self.textView];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"CXResources" withExtension:@"bundle"];
    NSBundle *targetBundle = [NSBundle bundleWithURL:url];
    
    self.popoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.popoverBtn.frame = CGRectMake(15, CGRectGetHeight(self.view.bounds) * 3.0 / 4.0, 35, 35);
    self.popoverBtn.backgroundColor = self.containerView.backgroundColor;
    self.popoverBtn.adjustsImageWhenHighlighted = NO;
    [self.popoverBtn setImage:[UIImage imageWithContentsOfFile:[targetBundle pathForResource:[NSString stringWithFormat:@"logs@2x"] ofType:@"png"]] forState:UIControlStateNormal];
    self.popoverBtn.layer.cornerRadius = CGRectGetHeight(self.popoverBtn.bounds) / 2;
    self.popoverBtn.clipsToBounds = YES;
    [self.popoverBtn addTarget:self action:@selector(handlePopoverTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.popoverBtn];
    
    UILongPressGestureRecognizer *popoverLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopverLongPressGestureRecognizer:)];
    [self.popoverBtn addGestureRecognizer:popoverLongPressGesture];
    
    UIPanGestureRecognizer *popoverPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopoverPanGestureRecognizer:)];
    [popoverPanGesture requireGestureRecognizerToFail:popoverLongPressGesture];
    [self.popoverBtn addGestureRecognizer:popoverPanGesture];
    
    self.hiddenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hiddenBtn.backgroundColor = [UIColor clearColor];
    self.hiddenBtn.adjustsImageWhenHighlighted = NO;
    [self.hiddenBtn setImage:[UIImage imageWithContentsOfFile:[targetBundle pathForResource:[NSString stringWithFormat:@"logs@2x"] ofType:@"png"]] forState:UIControlStateNormal];
    self.hiddenBtn.layer.cornerRadius = CGRectGetHeight(self.popoverBtn.bounds) / 2;
    self.hiddenBtn.clipsToBounds = YES;
    [self.hiddenBtn addTarget:self action:@selector(handlePopoverTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.hiddenBtn];
    
    self.searchView = [[UIView alloc] init];
    self.searchView.backgroundColor = [UIColor clearColor];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.containerView addSubview:self.searchView];
    
    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.placeholder = @"Search...";
    self.searchTextField.returnKeyType = UIReturnKeyDone;
    self.searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchTextField.delegate = self;
    [self.searchTextField addTarget:self action:@selector(textChange:) forControlEvents:(UIControlEventEditingChanged)];
    [self.searchView addSubview:self.searchTextField];
    
    self.deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleBtn.adjustsImageWhenHighlighted = NO;
    [self.deleBtn setImage:[UIImage imageWithContentsOfFile:[targetBundle pathForResource:@"delete@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [self.deleBtn addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:self.deleBtn];
}
#pragma mark - SearchText
- (void)textChange:(UITextField *)tf {
    self.regexString = tf.text;
    [self pm_updateTextView];
}

#pragma mark - Target Methods
- (void)handlePopoverTouchEvent:(UIButton *)button {
    
    self.popoverAnimating = YES;
    if (self.containerView.hidden) {
        CGAffineTransform scale = CGAffineTransformMakeScale(CGRectGetWidth(self.popoverBtn.frame) / CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.popoverBtn.frame) / CGRectGetHeight(self.containerView.frame));
        CGAffineTransform translation = CGAffineTransformMakeTranslation(self.popoverBtn.center.x - self.containerView.center.x, self.popoverBtn.center.y - self.containerView.center.y);
        CGAffineTransform transform = CGAffineTransformConcat(scale, translation);
        CGFloat cornerRadius = MIN(CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds));
        self.hiddenBtn.alpha = 0;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.popoverBtn.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             self.popoverAnimating = NO;
                         }];
        self.containerView.alpha = 0;
        self.containerView.hidden = NO;
        self.containerView.layer.cornerRadius = cornerRadius / 2;
        self.containerView.transform = transform;
        [UIView animateWithDuration:0.4
                              delay:0
             usingSpringWithDamping:0.69
              initialSpringVelocity:5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.containerView.alpha = 1;
                             self.containerView.transform = CGAffineTransformIdentity;
                             self.containerView.layer.cornerRadius = 0;
                         }
                         completion:^(BOOL finished) {
                             self.hiddenBtn.alpha = 1;
                             self.popoverAnimating = NO;
                         }];
    } else {
        [UIView animateWithDuration:0.4
                              delay:0
             usingSpringWithDamping:0.69
              initialSpringVelocity:5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.popoverBtn.alpha = 1;
                             self.containerView.alpha = 0;
                             [self.view endEditing:YES];
                         } completion:^(BOOL finished) {
                             self.containerView.hidden = YES;
                             self.containerView.layer.cornerRadius = 0;
                             self.containerView.transform = CGAffineTransformIdentity;
                         }];
        
    }
    
}
#pragma mark - longPress Remove
- (void)handlePopverLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CFTimeInterval duration = 0.5;
        CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scale.delegate = self;
        scale.values = @[@1.0, @1.2, @0.2];
        scale.keyTimes = @[@0.0, @(.2 / duration), @1];
        scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        scale.duration = duration;
        scale.fillMode = kCAFillModeForwards;
        scale.removedOnCompletion = NO;
        [self.popoverBtn.layer addAnimation:scale forKey:@"scale"];
    }
    
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [CXConsole hide];
    [self.popoverBtn.layer removeAnimationForKey:@"scale"];
}
- (void)pm_updateTextView {
    
    NSString *string = [[CXConsoleFileManager sharedIntance] readLog];
    if (string.length == 0) {
        return;
    }
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:string];
    if (self.regexString.length > 0) {
        NSArray *dataArray = [string componentsSeparatedByString:@"\n"];
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSString *string in dataArray) {
            if ([string containsString:self.regexString]) {
                [newArray addObject:string];
            }
        }
        attriString = [self textAttributedStringWithString:[newArray componentsJoinedByString:@"\n"]];
        self.textView.attributedText = attriString;
    } else {
        attriString = [self textAttributedStringWithString:string];
        self.textView.attributedText = attriString;
    }
    
    if (_scrollBottomAble) {
        [self scrollToBottom];
    }
    
}
#pragma mark - PanGestureRecognizer
- (void)handlePopoverPanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    CGPoint panPoint = [gesture locationInView: self.view];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.popoverAnimating = YES;
            //注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [gesture setTranslation:CGPointZero inView:self.view];
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.popoverBtn.center = CGPointMake(panPoint.x, panPoint.y);
            break;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            self.popoverAnimating = NO;
            break;
        default:
            break;
    }
}
// 富文本设置
- (NSMutableAttributedString *)textAttributedStringWithString:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    // 字号
    [attributedString addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12] range: NSMakeRange(0, attributedString.length)];
    // 字体颜色
    [attributedString addAttribute: NSForegroundColorAttributeName value:[UIColor whiteColor] range: NSMakeRange(0, attributedString.length)];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 8;
    paraStyle.paragraphSpacing = 12;
    [attributedString addAttribute: NSParagraphStyleAttributeName value:paraStyle range: NSMakeRange(0, attributedString.length)];
    return attributedString;
}

- (void)scrollToBottom {
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _scrollBottomAble = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _scrollBottomAble = YES;
}

#pragma mark - Public Methods
- (void)clear {
    self.textView.text = nil;
    self.textView.contentOffset = CGPointZero;
    [[CXConsoleFileManager sharedIntance] clearLog];
}

#pragma mark - Notification
- (void)keyboardWillSHow:(NSNotification *)notification {
    // 获取键盘高度
    self.popoverAnimating = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    NSInteger height = keyboardRect.size.height;
    self.containerView.cx_top = self.view.cx_height - height - self.containerView.cx_height;
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.containerView.cx_top = CGRectGetHeight(self.view.bounds) - self.containerView.cx_height;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}




@end
