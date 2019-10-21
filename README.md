### CXConsole

> iOS端日志悬浮窗，支持监听NSlog输出和手动输出日志两种方式

### 特性
- 支持悬浮窗口拖拽
- 支持检索
- 支持一键清除日志
- 支持手动、自动两种打印日志方式


### 安装
#### - `CocoaPods`导入
> `pod 'CXConsole'`

#### - 手动导入
> 将工程里CXConsole文件夹直接拖到项目即可


### 使用

- 导入头文件`#import "CXConsole.h"`**需要在设置为根视图之后。**

> 方式一：直接监听NSLog，此方式可能会导致`Xcode`控制台不打印日志。

- `CXConsole show];`

> 方式二：

- `[CXConsole printLog:@"xxxxx"];`



