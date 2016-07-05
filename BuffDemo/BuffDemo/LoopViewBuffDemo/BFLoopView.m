//
//  BFLoopView.m
//  BuffDemo
//
//  Created by BoWang on 16/7/4.
//  Copyright © 2016年 BoWang. All rights reserved.
//
#import "BFLoopView.h"
#import "NullBuff.h"
#import "FrameBuff.h"
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
    BOOL shouldFPSAnimation;
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
        self.shouldAnimation=NO;
        shouldFPSAnimation=NO;
        self.loopPeriod=4.0;//Default
        self.loopAnimationDuration=1.0;//Default
        loopView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:loopView];
        [self setBackgroundColor:[UIColor whiteColor]];
        [loopView setPagingEnabled:YES];
        [loopView setContentSize:CGSizeMake(frame.size.width*(INT16_MAX+1), frame.size.height)];
        [loopView setShowsVerticalScrollIndicator:NO];
        [loopView setShowsHorizontalScrollIndicator:NO];
        [loopView setDelegate:self];
        CADisplayLink *link=[CADisplayLink displayLinkWithTarget:self selector:@selector(linkAction:)];
        startTimeStamp=CACurrentMediaTime();
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        loopTimer=[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(loop) userInfo:nil repeats:YES];
    }
    return self;
}
-(void)setShouldAnimation:(BOOL)shouldAnimation{
    _shouldAnimation=shouldAnimation;
    if (self.loopItems.count>0) {
    
    }
    
}
-(void)setLoopItems:(NSArray *)loopItems{
    _loopItems=loopItems;
    
}
#pragma mark scrollView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastOffSetX=scrollView.contentOffset.x;
    self.shouldAnimation=NO;
    [loopTimer invalidate];
    loopTimer = nil;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    lastOffSetX=scrollView.contentOffset.x;
    loopTimer=[NSTimer scheduledTimerWithTimeInterval:self.loopPeriod target:self selector:@selector(loop) userInfo:nil repeats:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger next;
    NSInteger t;
    if (scrollView.contentOffset.x>=lastOffSetX) {
        currentBlockIndex=floor(scrollView.contentOffset.x/320);
        t=currentBlockIndex-startBlockIndex;
        NSInteger currentIndex=_bfGetCurrentIndex(t,3);
        next=currentIndex==self.loopItems.count-1?0:currentIndex+1;
        UIView *view=self.loopItems[next];
        [view setFrame:CGRectMake(320*(floor(scrollView.contentOffset.x/320)+1), 0, 320, 200)];
    }
    else{
        currentBlockIndex=ceil(scrollView.contentOffset.x/320);
        t=currentBlockIndex-startBlockIndex;
        NSInteger currentIndex=_bfGetCurrentIndex(t,3);
        next=currentIndex==0?self.loopItems.count-1:currentIndex+-1;
        UIView *view=self.loopItems[next];
        [view setFrame:CGRectMake(320*(ceil(scrollView.contentOffset.x/320)-1), 0, 320, 200)];
    }
    lastOffSetX=scrollView.contentOffset.x;
}
-(void)loop{
    startTimeStamp=CACurrentMediaTime();
    shouldFPSAnimation=YES;
}
-(void)linkAction:(CADisplayLink *)sender{
    if (shouldFPSAnimation) {
        CGFloat percent=(sender.timestamp-startTimeStamp)/1.0;
        percent=percent>=1?1:percent;
            [loopView setContentOffset:CGPointMake(320*(floor(loopView.contentOffset.x/320)+percent), 0)];
        if (percent==1) {
            shouldFPSAnimation=NO;
        }
    }
}
+(BFLoopView*)loopViewWithItems:(NSArray *)items frame:(CGRect)frame loopPeriod:(NSTimeInterval )period animationDuration:(NSTimeInterval)duration animationStyle:(BuffLoopViewAnimationStyle)style{    BFLoopView *loopView=[[BFLoopView alloc]initWithFrame:frame];
    [loopView setLoopItems:items];
    return loopView;
}
-(void)dealloc{
    
}
@end
