# BuffKit  ![license](https://img.shields.io/cocoapods/l/BuffKit.svg)

![pod version](https://img.shields.io/cocoapods/v/BuffKit.svg)

**iOS基础功能组件**

#Intro
BuffKit includes extension for foudation class or instance and provides basic features of iOS application.

#Supported features
1. [Cypher]():MD5,SHA1,SHA2,AES,DES,3DES,BLOWFISH. 
2. [Null-handler]():preventing crash when NSDictionary,NSString,NSNumber or NSArray is null.
3. [Frame-access]():access frame of UIView,CALayer and screen.
4. [Geo-coordinates-transformation](): wgs84(gps) to gcj02(china)
5. [Cell-annotation]():add a annotation bubble on top of the cell when the cell can not show all message within its bounds
6. [UIColor-extension]():getting a color instance from a hex number or a hex string.
7. [Split-view]():show highly customizable and multi-style split view with only a few lines of code.

#简介
BuffKit 包含了对Foundation框架的扩展以及iOS app的基础功能，目前主干功能已经稳定可用，很多features仍在开发中。

#支持的功能
1. [CryptoBuff]():包含了MD5,SHA1,SHA2的计算,以及对称加密：AES,DES,3DES,BLOWFISH. 
2. [NullBuff]():Null对象处理，防止NSDictionary,NSString,NSNumber,NSArray类型的指针执行Null对象导致的闪退问题。
3. [FrameBuff]():快速获取UIView,CALayer和UIScreen的尺寸信息。
4. [LBSBuff]():地球坐标转火星坐标: wgs84(gps) to gcj02(china)，精度约是小数点后4位。
5. [CellBuff]():为无法完整显示字符串的Cell提供一个标注。
6. [UIClorBuff]():通过16进制字符串或数字设置颜色，以及获取一个颜色的RGBA信息。
7. [RootSplitBuff]():显示高可自定义的左右侧边栏，支持AutoLayout横竖屏/手势/可自定义/多样式/Method-Swizzling提高兼容。

If you have any problems or suggestions,please issue me or mail me(**ralwayne@163.com**).

BuffKit is released under the MIT license.
