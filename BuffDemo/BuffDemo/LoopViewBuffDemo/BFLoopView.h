//
//  BFLoopView.h
//  BuffDemo
//
//  Created by BoWang on 16/7/4.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFLoopView : UIView <UIScrollViewDelegate>
@property(nonatomic,strong)NSArray *loopItems;
@property(nonatomic,assign)NSTimeInterval loopPeriod;
@property(nonatomic,assign)NSTimeInterval loopAnimationDuration;
-(void)beginLoop;
-(void)endLoop;
+(BFLoopView*)loopViewWithItems:(NSArray *)items loopPeriod:(NSTimeInterval )period animationDuration:(NSTimeInterval)duration frame:(CGRect)frame;
@end
