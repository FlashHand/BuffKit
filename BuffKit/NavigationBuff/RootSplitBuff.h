//
//  RootVCSplitBuff.h
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFRootViewController : UIViewController
{
    NSMutableArray*fullScreenConstraints;
    NSMutableArray *leftConstraints;
    NSMutableArray *rightConstraints;
}
+ (BFRootViewController *)sharedController;

@property(nonatomic, strong) UIViewController *bfLeftViewController;
@property(nonatomic, strong) UIViewController *bfRightViewController;
@property(nonatomic, strong) UIViewController *bfMainViewController;
//mainView样式
@property(nonatomic, assign) CGFloat mainViewDimOpacity;
@property(nonatomic, strong) UIColor *mainViewDimColor;
//侧边栏显示时mainView缩放情况,透视效果存在时mainViewScale为1
@property(nonatomic, assign) CGFloat mainViewScale;
//侧边栏显示时是否应该有透视效果,covered情况下mainViewPerspective为无限大
@property(nonatomic, assign) BOOL mainViewPerspective;


@property(nonatomic, assign) CGFloat leftWidth;
@property(nonatomic, assign) CGFloat rightWidth;
//左侧栏是否覆盖mainView
@property(nonatomic, assign) BOOL shouldLeftCovered;
//右侧栏是否覆盖mainView
@property(nonatomic, assign) BOOL shouldRightCovered;

//背景
@property (nonatomic, strong)UIImage *rootBackgroundImage;
@property (nonnull,strong)UIImageView *rootBackgroundImageView;

-(void)showLeftViewController;
@end

@interface UIViewController (RootSplitBuff)

@end

@interface RootSplitBuff : NSObject
+ (BFRootViewController *)rootViewController;
@end