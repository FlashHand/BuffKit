//
//  RootVCSplitBuff.h
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BFRootViewController : UIViewController
+(BFRootViewController *)sharedController;
@property (nonatomic,strong) UIViewController *bfLeftViewController;
@property (nonatomic,strong) UIViewController *bfRightViewController;
@property (nonatomic,strong) UIViewController *bfMainViewController;
@property (nonatomic,)
@end
@interface UIViewController(RootVCSplitBuff)

@end

@interface RootVCSplitBuff : NSObject
+(UIViewController *)rootViewController;
@end
