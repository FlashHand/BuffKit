//
//  RootVCSplitBuff.h
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, BuffSplitStyle) {
    BuffSplitStyleCovered = 1,
    BuffSplitStylePushed = 2,
    BuffSplitStyleScaled = 3,
    BuffSplitStylePerspective =4,
};
@interface BFRootViewController : UIViewController<UIViewControllerTransitioningDelegate>
{
    NSMutableArray*fullScreenConstraints;
    NSMutableArray *leftConstraints;
    NSMutableArray *rightConstraints;
}
+ (BFRootViewController *)sharedController;

//controllers
@property(nonatomic, strong) UIViewController *bfLeftViewController;
@property(nonatomic, strong) UIViewController *bfRightViewController;
@property(nonatomic, strong) UIViewController *bfMainViewController;
//restore button
@property(nonatomic, strong) UIButton *restoreButton;

//dim view 's style for the mainViewController's view
@property(nonatomic, assign) CGFloat mainViewDimOpacity;
@property(nonatomic, strong) UIColor *mainViewDimColor;
//侧边栏显示时mainView缩放情况,透视效果存在时mainViewScale为1
@property(nonatomic, assign) CGFloat mainViewScale;
//侧边栏显示风格
@property(nonatomic, assign) BuffSplitStyle splitStyle;


@property(nonatomic, assign) CGFloat leftWidth;
@property(nonatomic, assign) CGFloat rightWidth;

//when covered mainViewController's will not move,otherwise will move for a distance that equals to leftWidth or rightWidth.
//左侧栏是否覆盖mainView
@property(nonatomic, assign) BOOL shouldLeftCovered;
//右侧栏是否覆盖mainView
@property(nonatomic, assign) BOOL shouldRightCovered;

//Duration
@property(nonatomic, assign) CGFloat leftAnimatorDuration;
@property(nonatomic, assign) CGFloat rightAnimatorDuration;

//rootViewController backgroudImage
@property (nonatomic, strong) UIImage *rootBackgroundImage;
@property (nonatomic, strong) UIImageView *rootBackgroundImageView;

//#pragma mark - show & hide
//-(void)showLeftViewController;
//-(void)hideLeftViewController;
//-(void)showRightViewController;
//-(void)hideRightViewController;

@end

@interface RootSplitBuff : NSObject
+ (BFRootViewController *)rootViewController;

+ (void)showLeftViewController;
+ (void)hideLeftViewController;
+ (void)showRightViewController;
+ (void)hideRightViewController;

-(void)activeLeftPanGestureOnEdge:(BOOL)onEdge;
-(void)deactiveLeftPanGesture;
-(void)activeRightPanGestureOnEdge:(BOOL)onEdge;
-(void)deactiveRightPanGesture;

@end