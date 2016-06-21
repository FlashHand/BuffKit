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
#define BF_SCALED_PAN 1.2
#define BF_HORIZON_PAN_ANGLE M_PI_4

typedef NS_ENUM(NSInteger, BuffSplitStyle) {
    BuffSplitStyleCovered = 1,
    BuffSplitStyleScaled = 2,
    BuffSplitStylePerspective =3,
    BuffSplitStyleCustom =4,
    //TODO: USING BLOCK TO SET START/END LAYOUT
    //BUT PROTOCOL IS A SAFER CHOICE
};
typedef NS_ENUM(NSInteger, BuffPanDirection) {
    BuffPanDirectionNone = 1,
    BuffPanDirectionLeft = 2,
    BuffPanDirectionRight = 3,
};
//TODO: 考虑下Observing 滑动状态
//typedef NS_ENUM(NSInteger, BuffSplitState) {
//    BuffSplitStateQueit = 1,
//    BuffSplitStateShowingLeft = 2,
//    BuffSplitStateShowingRight = 3,
//    BuffSplitStateHidingLeft = 4,
//    BuffSplitStateHidingRight = 5,
//};

@protocol RootSplitBuffDelegate<NSObject>
@optional
//显示左、右侧栏执行的协议方法
//percent为当前所处的滑动进度
-(void)rootSplitBuffWillPushInLeftSplitView;
-(void)rootSplitBuffPushingInLeftSplitView:(CGFloat)percent;
-(void)rootSplitBuffEndPushingInLeftSplitViewAt:(CGFloat)percent;

-(void)rootSplitBuffWillPushOutLeftSplitView;
-(void)rootSplitBuffPushingOutLeftSplitView:(CGFloat)percent;
-(void)rootSplitBuffEndPushingOutLeftSplitViewAt:(CGFloat)percent;

-(void)rootSplitBuffWillPushInRightSplitView;
-(void)rootSplitBuffPushingInRightSplitView:(CGFloat)percent;
-(void)rootSplitBuffEndPushingInRightSplitViewAt:(CGFloat)percent;

-(void)rootSplitBuffWillPushOutRightSplitView;
-(void)rootSplitBuffPushingOutRightSplitView:(CGFloat)percent;
-(void)rootSplitBuffEndPushingOutRightSplitViewAt:(CGFloat)percent;

@end

@interface BFRootViewController : UIViewController<UIGestureRecognizerDelegate>
{
    NSMutableArray*fullScreenConstraints;
    
    NSMutableArray *mainStartConstraints;
    NSMutableArray *mainEndConstraints;

    NSMutableArray *leftStartConstraints;
    NSMutableArray *leftEndConstraints;
    NSMutableArray *rightStartConstraints;
    NSMutableArray *rightEndConstraints;
    NSMutableArray *dimConstraints;
    
    CGPoint beginPoint;
    BuffPanDirection mainPanDirection;
    CGFloat currentWidth;
}
+ (BFRootViewController *)sharedController;
@property(nonatomic, weak) id <RootSplitBuffDelegate> delegate;

//controllers
@property(nonatomic, strong) UIViewController *bfLeftViewController;
@property(nonatomic, strong) UIViewController *bfRightViewController;
@property(nonatomic, strong) UIViewController *bfMainViewController;

//gestures
@property(nonatomic, strong,readonly) UIScreenEdgePanGestureRecognizer *bfLeftPan;
@property(nonatomic, strong,readonly) UIScreenEdgePanGestureRecognizer *bfRightPan;
@property(nonatomic, strong,readonly) UIPanGestureRecognizer *bfMainPan;

//dim button
@property(nonatomic, strong,readonly) UIView *dimView;
@property(nonatomic, assign) CGFloat dimOpacity;
@property(nonatomic, strong) UIColor *dimColor;


//侧边栏及主视图样式
@property(nonatomic, assign) BuffSplitStyle splitStyle;
@property(nonatomic, assign) CGFloat leftWidth;
@property(nonatomic, assign) CGFloat rightWidth;
@property(nonatomic, assign) CGFloat leftStartOffset;
@property(nonatomic, assign) CGFloat rightStartOffset;
//mainViewEndOffset only works for BuffSplitStyleCovered
@property(nonatomic, assign) CGFloat mainEndOffsetForLeft;
@property(nonatomic, assign) CGFloat mainEndOffsetForRight;
//mainViewScale only works for BuffSplitStyleScaled
@property(nonatomic, assign) CGFloat mainScale;



//Duration
@property(nonatomic, assign) CGFloat leftAnimationDuration;
@property(nonatomic, assign) CGFloat rightAnimationDuration;

//rootViewController backgroudImage
@property (nonatomic, strong) UIImage *rootBackgroundPortraitImage;
@property (nonatomic, strong) UIImage *rootBackgroundLandscapeImage;
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

