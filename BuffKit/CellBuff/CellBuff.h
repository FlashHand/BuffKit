//
// Created by BoWang on 16/5/20.
// Copyright (c) 2016 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CellBuff;

@interface UITableViewCell (CellBuff)
@property (nonatomic, strong)CellBuff *buff;
@property (nonatomic, strong)NSString *bfAnnotation;
@property (nonatomic, strong)UIButton *bfAnnotationBtn;
-(void)bf_setAnnotation:(NSString *)annotation;
@end

@interface CellBuff : NSObject
#pragma mark 列表文字详情注释
@property(nonatomic, assign) CGFloat annotationMaxWidth;
@property(nonatomic, strong) UIColor *annotationBGColor;
@property(nonatomic, strong) UIColor *annotationTextColor;
@property(nonatomic, strong) UIFont *annotationFont;
@property(nonatomic, assign) CGFloat annotationOpacity;

@end