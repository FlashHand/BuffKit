//
//  RootVCSplitBuff.h
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BF_PERCENTAGE_SHOW_LEFT  0.5
#define BF_PERCENTAGE_SHOW_RIGHT  0.5
#define BF_SCALE_PAN 1.2

typedef NS_ENUM(NSInteger, BuffSplitStyle) {
    BuffSplitStyleCovered = 1,
    BuffSplitStylePushed = 2,
    BuffSplitStyleScaled = 3,
    BuffSplitStylePerspective =4,
};
@interface BFRootViewController : UIViewController<UIGestureRecognizerDelegate>
{
    NSMutableArray*fullScreenConstraints;
    NSMutableArray *leftConstraints;
    NSMutableArray *rightConstraints;
    
    NSMutableArray *leftStartConstraints;
    NSMutableArray *leftEndConstraints;
    NSMutableArray *mainStartConstraints;
    NSMutableArray *mainEndConstraints;
    NSMutableArray *rightStartConstraints;
    NSMutableArray *rightEndConstraints;
    NSMutableArray *dimConstraints;
    
    CGPoint beginPoint;
}
+ (BFRootViewController *)sharedController;

//controllers
@property(nonatomic, strong) UIViewController *bfLeftViewController;
@property(nonatomic, strong) UIViewController *bfRightViewController;
@property(nonatomic, strong) UIViewController *bfMainViewController;
//gestures
@property(nonatomic, strong) UIPanGestureRecognizer *bfLeftPan;
@property(nonatomic, strong) UIPanGestureRecognizer *bfRightPan;
//dim button
@property(nonatomic, strong) UIView *dimView;
//dim view 's style for the mainViewController's view
@property(nonatomic, assign) CGFloat dimOpacity;
@property(nonatomic, strong) UIColor *dimColor;
//侧边栏显示时mainView缩放情况,透视效果存在时mainViewScale为1
@property(nonatomic, assign) CGFloat mainViewScale;

//侧边栏显示风格
@property(nonatomic, assign) BuffSplitStyle splitStyle;
@property(nonatomic, assign) CGFloat leftWidth;
@property(nonatomic, assign) CGFloat rightWidth;

//Duration
@property(nonatomic, assign) CGFloat leftAnimationDuration;
@property(nonatomic, assign) CGFloat rightAnimationDuration;

//rootViewController backgroudImage
@property (nonatomic, strong) UIImage *rootBackgroundImage;
@property (nonatomic, strong) UIImageView *rootBackgroundImageView;

@property (nonatomic,assign,readonly) BOOL isLeftShowing;
@property (nonatomic,assign,readonly) BOOL isRightShowing;

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

+(void)activeLeftPanGestureOnEdge:(BOOL)onEdge;
+(void)deactiveLeftPanGesture;
+(void)activeRightPanGestureOnEdge:(BOOL)onEdge;
+(void)deactiveRightPanGesture;

@end