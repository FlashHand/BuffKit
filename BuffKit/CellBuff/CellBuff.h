//
// Created by BoWang(r4l.xyz) on 16/5/20.
// Copyright (c) 2016 BoWang(r4l.xyz). All rights reserved.
//

#import <Foundation/Foundation.h>

#define BF_CELL_ANNOTATION_MINWIDTH 30.0
#define BF_CELL_ANNOTATION_MINHEIGHT 30.0
#define BF_CELL_ANNOTATION_MAXHEIGHT 60.0

@class CellBuff;

@interface UITableViewCell (CellBuff)
- (void)bf_swizzled_layoutSubviews;

@property(nonatomic, strong) CellBuff *buff;
@property(nonatomic, strong) NSString *bfAnnotation;
@property(nonatomic, strong) UIButton *bfAnnotationBtn;

- (void)bf_setAnnotation:(NSString *)annotation;
@end

@interface CellBuff : NSObject
#pragma mark 列表文字详情注释
@property(nonatomic, strong) UIColor *annotationBGColor;
@property(nonatomic, strong) UIColor *annotationTextColor;
@property(nonatomic, strong) UIFont *annotationFont;
@property(nonatomic, assign) CGFloat annotationOpacity;

@end