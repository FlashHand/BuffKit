//
//  BFLoopView.h
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/7/4.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, BuffLoopViewAnimationStyle) {
    //easing 算法
    //x ∈ [0,1]
    //Linear:f(x)=x
    BuffLoopViewAnimationStyleLinear = 1,
    //easyIn:f(x)=-cos(x * (M_PI/2)+1
    BuffLoopViewAnimationStyleEasyIn = 2,
    //easyInOut:f(x)=-0.5*cos(M_PI*x)+0.5
    BuffLoopViewAnimationStyleEasyInOut = 3,
    //easyOut:f(x)=sin(x * M_PI/2)
    BuffLoopViewAnimationStyleEasyOut = 4,
    //custom:使用 "-(void)setAnimationStyle:(void(^)(CGFloat p))animationFunction;"自定义切换效果。注意，必须满足f(0)=0,f(1)=1
    BuffLoopViewAnimationStyleCustom = 100,
    
};

@interface BFLoopView : UIView <UIScrollViewDelegate>
@property(nonatomic,strong)NSArray *loopItems;
@property(nonatomic,assign)NSTimeInterval loopPeriod;
@property(nonatomic,assign)NSTimeInterval loopAnimationDuration;
@property(nonatomic,assign)BuffLoopViewAnimationStyle loopAnimationStyle;
@property(nonatomic,assign)BOOL shouldAnimation;//should show loop animation .
@property(nonatomic,strong)UIPageControl *loopPageControl;
/**
 *  create a BFLoopView instance
 *
 *  @param items        array of uiviews
 *  @param frame        frame of BFLoopView
 *  @param period       period of the loop
 *  @param duration     durantion of the scrollview animation
 *  @param style        scroll animation style:linear,easyin,easyout,easyinout
 *  @param loopCallback get current index from this block
 *
 *  @return return a a BFLoopView instance
 */
+(BFLoopView*)loopViewWithItems:(NSArray *)items frame:(CGRect)frame loopPeriod:(NSTimeInterval )period animationDuration:(NSTimeInterval)duration animationStyle:(BuffLoopViewAnimationStyle)style indexChanged:(void(^)(NSInteger loopIndex))indexChanged;

-(void)setCustomAnimationStyle:(CGFloat(^)(CGFloat p))animationFunction;
@end
