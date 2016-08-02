# BuffKit 

![pod version](https://img.shields.io/cocoapods/v/BuffKit.svg) ![license](https://img.shields.io/cocoapods/l/BuffKit.svg)

### 要求： iOS7.0+

#简介

这是一个功能多样、耦合度低的Kit，是依据作者自己的需要而开发，但您可以轻松地在自己的工程中使用。

BuffKit 包含了对Foundation框架的扩展以及iOS app的常用基础功能，您可以下载这个repo并通过demo查看大部分功能，目前主干功能已经稳定可用，很多features仍在开发中。

如果您需要下面大部分的功能可以选择使用
```
pod 'BuffKit'
```
或下载BuffKit并选择你需要的文件。

#支持的功能
1. [CryptoBuff]():包含了MD5,SHA1,SHA2的计算,以及对称加密：AES,DES,3DES,BLOWFISH. 
2. [NullBuff]():Null对象处理，防止NSDictionary,NSString,NSNumber,NSArray类型的指针执行Null对象导致的闪退问题。
3. [FrameBuff]():快速获取UIView,CALayer和UIScreen的尺寸信息。
4. [LBSBuff]():地球坐标转火星坐标: wgs84(gps) to gcj02(china)，精度约是小数点后4位。
5. [CellBuff]():为无法完整显示字符串的Cell提供一个标注。
6. [UIColorBuff]():通过16进制字符串或数字设置颜色，以及获取一个颜色的RGBA信息。
7. [RootSplitBuff]():显示高可自定义的左右侧边栏，支持AutoLayout横竖屏/手势/可自定义/多样式/Method-Swizzling提高兼容。
8. [LoopViewBuff]():轮播图，使用CADisplayLink实现，支持自定义动画时间函数（已包含渐入渐出）。

如果您有问题想和我交流，欢迎提出issue或发邮件(**ralwayne@163.com**).

BuffKit is released under the MIT license.
