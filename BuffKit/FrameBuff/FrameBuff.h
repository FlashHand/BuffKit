//
//  FrameBuff.h
//
//  Created by BoWang(r4l.xyz) on 16/5/11.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (FrameBuff)
//边界
@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;
//宽高
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

//原点和尺寸
@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;

//原点坐标
@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;

//中心坐标
@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

//中心相对原点的位置
@property(nonatomic, readonly) CGPoint midPoint;
@property(nonatomic, readonly) CGFloat midX;
@property(nonatomic, readonly) CGFloat midY;

@end

@interface CALayer (FrameBuff)
//边界
@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;
//宽高
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

//尺寸
@property(nonatomic) CGSize size;

//原点坐标(position.x,position.y,zPosition)
@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat z;

//中心相对原点的位置
@property(readonly) CGPoint midPoint;
@property(readonly) CGFloat midX;
@property(readonly) CGFloat midY;
@end

@interface UIImage (FrameBuff)
@property(readonly) CGFloat width;
@property(readonly) CGFloat height;
@end

@interface FrameBuff : NSObject
+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;

+ (CGFloat)screenScale;
@end
