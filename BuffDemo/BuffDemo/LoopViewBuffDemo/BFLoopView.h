//
//  BFLoopView.h
//  BuffDemo
//
//  Created by BoWang on 16/7/4.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFLoopView : UIView
@property(nonatomic,strong)NSArray *loopItems;
-(void)beginLoop;
-(void)endLoop;
@end
