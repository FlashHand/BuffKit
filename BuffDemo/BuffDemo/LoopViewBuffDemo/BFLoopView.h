//
//  BFLoopView.h
//  BuffDemo
//
//  Created by BoWang on 16/7/4.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, BuffLoopViewAnimationStyle) {
    BuffLoopViewAnimationStyleLinear = 1,
    BuffLoopViewAnimationStyleLinearEasyIn = 2,
    BuffLoopViewAnimationStyleLinearEasyInOut = 3,
    BuffLoopViewAnimationStyleLinearEasyOut = 4,
    //TODO:more style
};
@interface BFLoopView : UIView <UIScrollViewDelegate>
@property(nonatomic,strong)NSArray *loopItems;
@property(nonatomic,assign)NSTimeInterval loopPeriod;
@property(nonatomic,assign)NSTimeInterval loopAnimationDuration;
@property(nonatomic,assign)BuffLoopViewAnimationStyle loopAnimationStyle;
@property(nonatomic,assign)BOOL shouldAnimation;
+(BFLoopView*)loopViewWithItems:(NSArray *)items frame:(CGRect)frame loopPeriod:(NSTimeInterval )period animationDuration:(NSTimeInterval)duration animationStyle:(BuffLoopViewAnimationStyle)style;
@end
