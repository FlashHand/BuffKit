//
//  RootSplitAnimator.h
//  BuffDemo
//
//  Created by 王博 on 16/6/13.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - Default values

#pragma mark - Animator manager
@interface RootSplitAnimator : NSObject
@end

#pragma mark - Left viewController animator
@interface RootSplitAnimatorLeftShow : NSObject<UIViewControllerAnimatedTransitioning>
@end
@interface RootSplitAnimatorLeftHide : NSObject<UIViewControllerAnimatedTransitioning>
@end
#pragma mark - Right viewController animator
@interface RootSplitAnimatorRightShow : NSObject<UIViewControllerAnimatedTransitioning>
@end
@interface RootSplitAnimatorRightHide : NSObject<UIViewControllerAnimatedTransitioning>
@end
