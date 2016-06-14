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

//左侧滑动手势交互(或边缘滑动)
@interface PanInteractiveTransitionLeft :UIPercentDrivenInteractiveTransition
@end
//右侧滑动手势交互(或边缘滑动)
@interface PanInteractiveTransitionRight :UIPercentDrivenInteractiveTransition
@end