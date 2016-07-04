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
    UIScrollView *loopView;
    NSInteger startBlockIndex;
    NSInteger currentBlockIndex;
    CGFloat lastOffSetX;
    NSTimeInterval startTimeStamp;
}
@end
@implementation BFLoopView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        shouldAnimation=NO;
        shouldFPSAimation=NO;
        self.loopPeriod=4.0;
        self.loopAnimationDuration=1.0;
        loopView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:loopView];
        [self setBackgroundColor:[UIColor whiteColor]];
        [loopView setPagingEnabled:YES];
        [loopView setContentSize:CGSizeMake(frame.size.width*(INT16_MAX+1), frame.size.height)];
        [loopView setShowsVerticalScrollIndicator:NO];
        [loopView setShowsHorizontalScrollIndicator:NO];
        [loopView setDelegate:self];
        
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
#pragma mark scrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
+(BFLoopView*)loopViewWithItems:(NSArray *)items loopPeriod:(NSTimeInterval )period animationDuration:(NSTimeInterval)duration frame:(CGRect)frame{
    BFLoopView *loopView=[[BFLoopView alloc]initWithFrame:frame];
}
@end
