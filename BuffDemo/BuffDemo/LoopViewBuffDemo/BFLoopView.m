//
//  BFLoopView.m
//  BuffDemo
//
//  Created by BoWang on 16/7/4.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "BFLoopView.h"
static NSInteger _bfGetCurrentIndex(NSInteger t,NSInteger p){
    NSInteger currentIndex;
    if (t>=0) {
        currentIndex=t%p;
    }
    else{
        currentIndex=p-1+t%p;
    }
    return currentIndex;
}
@interface BFLoopView ()
{
    BOOL shouldAnimation;
    BOOL shouldFPSAimation;
    NSTimer *loopTimer;
}
@end
@implementation BFLoopView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        shouldAnimation=NO;
        shouldFPSAimation=NO;
    }
    return self;
}
-(void)beginLoop{
    
}
-(void)endLoop{
    
}
-(void)setLoopItems:(NSArray *)loopItems{
    _loopItems=loopItems;
}
@end
