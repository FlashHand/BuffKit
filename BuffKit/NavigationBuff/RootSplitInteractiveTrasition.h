//
//  RootSplitInteractiveTrasition.h
//  BuffDemo
//
//  Created by 王博 on 16/6/13.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootSplitInteractiveTrasition : NSObject

@end
//左侧边缘滑动手势交互
@interface SwipeInteractiveTransitionLeft :UIPercentDrivenInteractiveTransition
@end
//右侧边缘滑动手势交互
@interface SwipeInteractiveTransitionRight :UIPercentDrivenInteractiveTransition
@end