//
//  RootSplitBuff.h
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import <Foundation/Foundation.h>

#define BF_PERCENTAGE_SHOW_LEFT  0.5
#define BF_PERCENTAGE_SHOW_RIGHT  0.5
#define BF_SCALED_PAN 1.2
#define BF_HORIZON_PAN_ANGLE M_PI_4
#define BF_EYE_DISTANCE_PERSPECTIVE 2000.0
#define BF_SPLITVIEW_ZPOSITION -1000

typedef NS_ENUM(NSInteger, BuffSplitStyle) {
    BuffSplitStyleCovered = 1,
    BuffSplitStyleScaled = 2,
    //When BuffSplitStylePerspective,leftWidth & rightWidth will not be used
    BuffSplitStylePerspective = 3,
    BuffSplitStyleCustom = 4,
    //TODO: USING BLOCK TO SET START/END LAYOUT
};
//typedef NS_ENUM(NSInteger, BuffPanDirection) {
//    BuffPanDirectionNone = 1,
//    BuffPanDirectionLeft = 2,
//    BuffPanDirectionRight = 3,
//};
//TODO: 考虑下Observing 滑动状态
//typedef NS_ENUM(NSInteger, BuffSplitState) {
//    BuffSplitStateQueit = 1,
//    BuffSplitStateShowingLeft = 2,
//    BuffSplitStateShowingRight = 3,
//    BuffSplitStateHidingLeft = 4,
//    BuffSplitStateHidingRight = 5,
//};

@protocol RootSplitBuffDelegate <NSObject>
//显示左、右侧栏执行的协议方法
//percent为当前所处的滑动进度

//Protocol methods are called when showing or hiding split view
//percent indicates how many have you pan
@optional
- (void)rootSplitBuffDoPushInLeftSplitView;

- (void)rootSplitBuffWillPushInLeftSplitView;

- (void)rootSplitBuffPushingInLeftSplitView:(CGFloat)percent;

- (void)rootSplitBuffEndPushingInLeftSplitViewAt:(CGFloat)percent;

- (void)rootSplitBuffDoPushOutLeftSplitView;

- (void)rootSplitBuffWillPushOutLeftSplitView;

- (void)rootSplitBuffPushingOutLeftSplitView:(CGFloat)percent;

- (void)rootSplitBuffEndPushingOutLeftSplitViewAt:(CGFloat)percent;

- (void)rootSplitBuffDoPushInRightSplitView;

- (void)rootSplitBuffWillPushInRightSplitView;

- (void)rootSplitBuffPushingInRightSplitView:(CGFloat)percent;

- (void)rootSplitBuffEndPushingInRightSplitViewAt:(CGFloat)percent;

- (void)rootSplitBuffDoPushOutRightSplitView;

- (void)rootSplitBuffWillPushOutRightSplitView;

- (void)rootSplitBuffPushingOutRightSplitView:(CGFloat)percent;

- (void)rootSplitBuffEndPushingOutRightSplitViewAt:(CGFloat)percent;

@end

@interface BFRootViewController : UIViewController <UIGestureRecognizerDelegate> {
    NSMutableArray *mainStartConstraints;
    NSMutableArray *mainEndConstraints;

    NSMutableArray *leftStartConstraints;
    NSMutableArray *leftEndConstraints;
    NSMutableArray *rightStartConstraints;
    NSMutableArray *rightEndConstraints;
    NSMutableArray *dimConstraints;

    CGPoint beginPoint;
}
+ (BFRootViewController *)sharedController;

@property(nonatomic, weak) id <RootSplitBuffDelegate> leftDelegate;
@property(nonatomic, weak) id <RootSplitBuffDelegate> rightDelegate;

//controllers
@property(nonatomic, strong) UIViewController *bfLeftViewController;
@property(nonatomic, strong) UIViewController *bfRightViewController;
@property(nonatomic, strong) UIViewController *bfMainViewController;

//gestures
@property(nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *bfLeftPan;
@property(nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *bfRightPan;

//dim button
@property(nonatomic, strong, readonly) UIView *dimView;
@property(nonatomic, assign) CGFloat dimOpacity;
@property(nonatomic, strong) UIColor *dimColor;


//Split view style
@property(nonatomic, assign) BuffSplitStyle splitStyle;
@property(nonatomic, assign) CGFloat leftWidth;
@property(nonatomic, assign) CGFloat rightWidth;
//mainViewEndOffset only works for BuffSplitStyleCovered
@property(nonatomic, assign) CGFloat mainEndOffsetForLeft;
@property(nonatomic, assign) CGFloat mainEndOffsetForRight;
//mainViewScale only works for BuffSplitStyleScaled
@property(nonatomic, assign) CGFloat mainScale;
@property(nonatomic, assign) CGFloat mainRotateAngle;

@property(nonatomic, assign) BOOL shouldLeftStill;
//when YES bfLeftViewController.view's origin will always be （0,0）
//when YES bfRightViewController.view's origin will always be （self.view.width-_rightWidth,0）
@property(nonatomic, assign) BOOL shouldRightStill;

//Duration
@property(nonatomic, assign) CGFloat leftAnimationDuration;
@property(nonatomic, assign) CGFloat rightAnimationDuration;

//rootViewController backgroudImage
@property(nonatomic, strong) UIImage *rootBackgroundPortraitImage;
@property(nonatomic, strong) UIImage *rootBackgroundLandscapeImage;
@property(nonatomic, strong) UIImageView *rootBackgroundImageView;


@property(nonatomic, assign, readonly) BOOL isLeftShowing;
@property(nonatomic, assign, readonly) BOOL isRightShowing;

#pragma mark - show & hide

- (void)showLeftViewController;

- (void)hideLeftViewController;

- (void)showRightViewController;

- (void)hideRightViewController;

#pragma mark for method-swizzling

@property(nonatomic, assign, readonly) BOOL isRootViewContollerShowing;
@end

@interface RootSplitBuff : NSObject

+ (BFRootViewController *)rootViewController;

+ (void)setMainViewController:(UIViewController *)mainViewController;

+ (void)setLeftViewController:(UIViewController *)leftViewController;

+ (void)setRightViewController:(UIViewController *)rightViewController;

+ (void)showLeftViewController;

+ (void)hideLeftViewController;

+ (void)showRightViewController;

+ (void)hideRightViewController;

+ (void)activeLeftPanGesture;

+ (void)deactiveLeftPanGesture;

+ (void)activeRightPanGesture;

+ (void)deactiveRightPanGesture;
@end

@interface UIViewController (RootSplitBuff)

@end

