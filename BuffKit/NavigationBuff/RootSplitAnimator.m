//
//  RootSplitAnimator.m
//  BuffDemo
//
//  Created by 王博 on 16/6/13.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "RootSplitAnimator.h"
//    CGFloat h=tMeasure_Height_Screen/2.0;
//    CGFloat w=tMeasure_Width_Sreen/2.0;
//CGFloat sinA=(CGFloat)sin(angle);
//    CGFloat cosA=(CGFloat)cos(angle);
//    CGFloat tanA=(CGFloat)tan(angle);
//    CGFloat h2=2000.0*h/(2000.0-h*sinA);
//    CGFloat w2=2000.0*cosA*w/(2000.0-w-sinA);
//CGFloat t1=tMeasure_Width_Sreen*tMeasure_Width_Sreen*sin(angle);
//CGFloat t2=(2000.0-2000.0*cos(angle))*tMeasure_Width_Sreen;
//CGFloat leftW=(t1+t2)/(2000.0+tMeasure_Width_Sreen*sin(angle));
//    CGFloat leftH=tMeasure_Height_Screen*/(angle+(tMeasure_Width_Sreen*sin(angle)/2000));
//CGFloat leftH=(tMeasure_Height_Screen*2000)/(2000+tMeasure_Width_Sreen*sinA);
//CGSize leftSize=CGSizeMake(leftW, leftH);
//return leftSize;
@implementation RootSplitAnimator
@end

@implementation RootSplitAnimatorLeftShow
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return [RootSplitBuff rootViewController].leftAnimatorDuration;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGFloat leftWidth=[[RootSplitBuff rootViewController]leftWidth];
    UIViewController *toVC=[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC=[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
//    [containerView layoutIfNeeded];
    switch ([[RootSplitBuff rootViewController]splitStyle]) {
        case BuffSplitStyleCovered:
            
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
@end
@implementation RootSplitAnimatorLeftHide
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return [RootSplitBuff rootViewController].leftAnimatorDuration;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    
}
@end
