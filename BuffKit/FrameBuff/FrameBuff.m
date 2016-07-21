//
//  FrameBuff.m
//
//  Created by BoWang(r4l.xyz) on 16/5/11.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//
#import "FrameBuff.h"

#pragma mark - UIView

@implementation UIView (FrameBuff)
#pragma mark 边界

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    self.x = left;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    self.y = top;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    self.x = right - self.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.y = bottom - self.height;
}

#pragma mark 宽高

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

#pragma mark 原点和尺寸

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    self.frame = CGRectMake(self.x, self.y, size.width, size.height);
}

#pragma mark 原点坐标

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    ;
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

#pragma mark 中心坐标

- (CGFloat)centerX {
    return self.x + self.midX;
}

- (void)setCenterX:(CGFloat)centerX {
    self.x = centerX - self.midX;
}

- (CGFloat)centerY {
    return self.y + self.midY;
}

- (void)setCenterY:(CGFloat)centerY {
    self.y = centerY - self.midY;
}

#pragma mark 中心相对于原点位置，readonly

- (CGPoint)midPoint {
    return CGPointMake(self.width / 2, self.height / 2);
}

- (CGFloat)midX {
    return self.width / 2;
}

- (CGFloat)midY {
    return self.height / 2;
}
@end

#pragma mark - CALayer

@implementation CALayer (FrameBuff)
#pragma mark 边界

- (CGFloat)left {
    return self.x - self.width / 2;
}

- (void)setLeft:(CGFloat)left {
    [self setX:left + self.width / 2];
}

- (CGFloat)top {
    return self.y - self.height / 2;
}

- (void)setTop:(CGFloat)top {
    [self setY:top + self.height / 2];
}

- (CGFloat)right {
    return self.x + self.width / 2;
}

- (void)setRight:(CGFloat)right {
    [self setX:right - self.width / 2];
}

- (CGFloat)bottom {
    return self.y + self.height / 2;
}

- (void)setBottom:(CGFloat)bottom {
    [self setY:bottom - self.height / 2];
}

#pragma mark 边界

- (CGFloat)width {
    return self.bounds.size.width;
}

- (void)setWidth:(CGFloat)width {
    [self setBounds:CGRectMake(0, 0, self.height, width)];
}

- (CGFloat)height {
    return self.bounds.size.height;
}

- (void)setHeight:(CGFloat)height {
    [self setBounds:CGRectMake(0, 0, self.width, height)];
}

- (CGSize)size {
    return self.bounds.size;
}

- (void)setSize:(CGSize)size {
    [self setBounds:CGRectMake(0, 0, size.width, size.height)];
}

#pragma mark 位置

- (CGFloat)x {
    return self.position.x;
}

- (void)setX:(CGFloat)x {
    [self setPosition:CGPointMake(x, self.y)];
}

- (CGFloat)y {
    return self.position.y;
}

- (void)setY:(CGFloat)y {
    [self setPosition:CGPointMake(self.x, y)];
}

- (CGFloat)z {
    return self.zPosition;
}

- (void)setZ:(CGFloat)z {
    [self setZPosition:z];
}

#pragma mark 中心相对于左上角的坐标

- (CGPoint)midPoint {
    return CGPointMake(self.width / 2, self.height / 2);
}


- (CGFloat)midX {
    return self.width / 2;
}

- (CGFloat)midY {
    return self.height / 2;
}

@end

@implementation UIImage (FrameBuff)
- (CGFloat)width {
    return self.size.width;
}

- (CGFloat)height {
    return self.size.height;
}

@end

@implementation FrameBuff
+ (CGFloat)screenWidth {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)screenHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat)screenScale {
    return [[UIScreen mainScreen] scale];
}

@end
