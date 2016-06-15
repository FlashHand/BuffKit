//
//  RootSplitAnimator.m
//  BuffDemo
//
//  Created by 王博 on 16/6/13.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "RootSplitAnimator.h"
void BFSetBackgroundImage(id <UIViewControllerContextTransitioning> transitionContext) {
    UIView *containerView=[transitionContext containerView];
    UIImageView *rootBackgroundImageView=[[RootSplitBuff rootViewController]rootBackgroundImageView];
    [rootBackgroundImageView setBackgroundColor:[UIColor whiteColor]];
    [rootBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:self.rootBackgroundImageView];
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(_rootBackgroundImageView,containerView);
    NSDictionary *metrics = @{@"margin":@0};
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSMutableArray*constraints=[NSMutableArray array];
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_rootBackgroundImageView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_rootBackgroundImageView(==containerView)]" options:ops metrics:metrics views:bindings];
    [constraints addObjectsFromArray:c1];
    [constraints addObjectsFromArray:c2];
    [self.rootBackgroundImageView setImage:self.rootBackgroundImage];
    [self.view addConstraints:constraints];
}
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
    UIView *toView=toVC.view;
    UIView *fromView=fromVC.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fromView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIButton *dimBtn=[[UIButton alloc]init];
    [dimBtn setBackgroundColor:[[UIColor greenColor] colorWithAlpha:0.5]];
//    [containerView layoutIfNeeded];
    switch ([[RootSplitBuff rootViewController]splitStyle]) {
        case BuffSplitStyleCovered:
        {
            [containerView addSubview:fromView];
            [containerView addSubview:toView];
            [toView setBackgroundColor:[UIColor greenColor]];
//            [fromView addSubview:dimBtn];
            NSDictionary *bindings=NSDictionaryOfVariableBindings(toView,fromView,containerView);
            NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
            //起始约束
            startConstraints=[NSMutableArray array];
            NSDictionary *metrics1 = @{@"margin":@(-leftWidth),@"leftWidth":@(leftWidth)};
            NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[toView(leftWidth)]" options:ops metrics:metrics1 views:bindings];
            NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[toView(==containerView)]" options:ops metrics:metrics1 views:bindings];
            [startConstraints addObjectsFromArray:c1];
            [startConstraints addObjectsFromArray:c2];
            [containerView addConstraints:startConstraints];
            [containerView layoutIfNeeded];
            [containerView removeConstraints:startConstraints];
            //结束约束
            endConstraints=[NSMutableArray array];
            NSDictionary *metrics2 = @{@"margin":@0,@"leftWidth":@(leftWidth)};
            NSArray *ec1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[toView(leftWidth)]" options:ops metrics:metrics2 views:bindings];
            NSArray *ec2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[toView(==containerView)]" options:ops metrics:metrics2 views:bindings];
            [endConstraints addObjectsFromArray:ec1];
            [endConstraints addObjectsFromArray:ec2];
            [containerView addConstraints:endConstraints];
            
            
        }
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
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
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




@implementation RootSplitAnimator
+(RootSplitAnimatorLeftShow *)leftShowAnimator
{
    return [RootSplitAnimatorLeftShow new];
}
+(RootSplitAnimatorLeftHide *)leftHideAnimator
{
    return [RootSplitAnimatorLeftHide new];
}
//+(RootSplitAnimatorRightShow *)rightShowAnimator
//{
//    return [RootSplitAnimatorRightShow new];
//}
//+(RootSplitAnimatorRightHide *)rightHideAnimator
//{
//    return [RootSplitAnimatorRightHide new];
//}
@end

