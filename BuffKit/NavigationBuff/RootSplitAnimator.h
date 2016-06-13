//
//  RootSplitAnimator.h
//  BuffDemo
//
//  Created by 王博 on 16/6/13.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootSplitAnimator : NSObject

@end

//左侧栏动画生成器
@interface RootSplitAnimatorLeftShow : NSObject<UIViewControllerAnimatedTransitioning>
@end
@interface RootSplitAnimatorLeftHide : NSObject<UIViewControllerAnimatedTransitioning>
@end
//右侧栏动画生成器
@interface RootSplitAnimatorRightShow : NSObject<UIViewControllerAnimatedTransitioning>
@end
@interface RootSplitAnimatorRightHide : NSObject<UIViewControllerAnimatedTransitioning>
@end
