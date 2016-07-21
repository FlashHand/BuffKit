//
//  BFLoopView.h
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/7/4.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, BuffLoopViewAnimationStyle) {
    BuffLoopViewAnimationStyleLinear = 1,//f(x)=x;
    BuffLoopViewAnimationStyleEasyIn = 2,//f(x)=x*x;
    BuffLoopViewAnimationStyleEasyInOut = 3,
    //step function:
    //f(x)=x*x (x<0.25);
    //f(x)=x (0.75>x>=0.25)
    //f(x)=-x*x+2*x (x>=0.75)
    BuffLoopViewAnimationStyleEasyOut = 4,//f(x)=-x*x+2*x;
    //TODO:more style
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
@end
