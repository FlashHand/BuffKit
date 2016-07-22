//
//  BFLoopView.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/7/4.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//
#import "NullBuff.h"
#import "FrameBuff.h"
static NSInteger _bfGetCurrentIndex(NSInteger t,NSInteger p){
    NSInteger currentIndex;
//    if (t>=0) {
        currentIndex=t%p;
//    }
//    else{
//        currentIndex=p-1+t%p;
//    }
    return currentIndex;
}
static void(^_bfAnimationFunction)(CGFloat p);
static void(^_bfIndexChanged)(NSInteger i);

@interface BFLoopView ()
{
    BOOL shouldFPSAnimation;//should trigger loop animation by the CADisplayLink instance
    NSTimer *loopTimer;//controls loop period
    UIScrollView *loopView;
    NSInteger startBlockIndex;//default 0;
    NSInteger currentBlockIndex;
    NSInteger lastBlockIndex;
    NSInteger currentBlockIndexFPS;//
    NSInteger lastBlockIndexFPS;//

    CGFloat lastOffSetX;//last contentOffset.x before contentOffset.x changed
    NSTimeInterval startTimestamp;//Timestamp of animation's beginning
    CADisplayLink *link;//controls loop animation
    NSInteger loopStartBlockIndex;
    BOOL isTap;
}
@end
@implementation BFLoopView
-(instancetype)initWithFrame:(CGRect)frame indexChanged:(void(^)(NSInteger loopIndex))indexChanged{
    self=[super initWithFrame:frame];
    if (self) {
        
        //prevent 64 y-offset by automaticallyAdjustsScrollViewInsets
        UIView *placeHolderView=[[UIView alloc]initWithFrame:CGRectZero];
        [self addSubview:placeHolderView];
        self.shouldAnimation=NO;
        isTap=YES;
        shouldFPSAnimation=NO;
        startBlockIndex=0;
        currentBlockIndexFPS=0;
        lastBlockIndex=0;
        lastBlockIndexFPS=0;
        self.loopPeriod=4.0;//Default
        self.loopAnimationDuration=1.0;//Default
        loopView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:loopView];
        [self setBackgroundColor:[UIColor whiteColor]];
        [loopView setPagingEnabled:YES];
        [loopView setBounces:NO];
        [loopView setContentSize:CGSizeMake(frame.size.width*(INT16_MAX+1), frame.size.height)];
        [loopView setShowsVerticalScrollIndicator:NO];
        [loopView setShowsHorizontalScrollIndicator:NO];
        [loopView setDirectionalLockEnabled:YES];
        [loopView setDelegate:self];
        link=[CADisplayLink displayLinkWithTarget:self selector:@selector(linkAction:)];
        startTimestamp=CACurrentMediaTime();
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        loopTimer=[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(loop) userInfo:nil repeats:YES];
        _bfIndexChanged=indexChanged;
    }
    return self;
}
-(void)setShouldAnimation:(BOOL)shouldAnimation{
    _shouldAnimation=shouldAnimation;
    [loopView setScrollEnabled:YES];
    if (_loopItems.count<2) {
        _shouldAnimation=NO;
        [loopView setScrollEnabled:NO];
    }
}
-(void)setLoopItems:(NSArray *)loopItems{
    _loopItems=loopItems;
    CGFloat initialOffsetX=floor(loopView.contentSize.width/2.0/loopView.width)*loopView.width;
    [loopView setContentOffset:CGPointMake(initialOffsetX, 0)];
    for (NSInteger i = 0; i < _loopItems.count; i++) {
        UIView *tmp=_loopItems[i];
        [tmp setFrame:CGRectMake(initialOffsetX, 0, loopView.width, loopView.height)];
        [loopView addSubview:tmp];
        initialOffsetX=initialOffsetX+loopView.width;
    }
    [loopView setScrollEnabled:YES];
    if (_loopItems.count<2) {
        _shouldAnimation=NO;
        [loopView setScrollEnabled:NO];
    }
}
-(void)setLoopAnimationStyle:(BuffLoopViewAnimationStyle)loopAnimationStyle{
    _loopAnimationStyle=loopAnimationStyle;
    switch (loopAnimationStyle) {
        case BuffLoopViewAnimationStyleLinear:
            _bfAnimationFunction=^(CGFloat p){};
            break;
        case BuffLoopViewAnimationStyleEasyIn:
            _bfAnimationFunction=^(CGFloat p){p=p*p;};
            break;
        case BuffLoopViewAnimationStyleEasyInOut:
        {
            _bfAnimationFunction=^(CGFloat p){
                if (p<0.25) {
                    p=p*p;
                }
                else if (p>=0.75){
                    p=-p*p+2*p;
                }
            };

        }
            break;
        case BuffLoopViewAnimationStyleEasyOut:
            _bfAnimationFunction=^(CGFloat p){p=-p*p+2*p;};
            break;
        default:
            break;
    }
}
#pragma mark scrollView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastOffSetX=scrollView.contentOffset.x;
    _shouldAnimation=NO;
    [loopTimer invalidate];
    loopTimer = nil;
    lastBlockIndex=floor(scrollView.contentOffset.x/loopView.width);
    isTap=NO;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    lastOffSetX=scrollView.contentOffset.x;
    loopTimer=[NSTimer scheduledTimerWithTimeInterval:self.loopPeriod target:self selector:@selector(loop) userInfo:nil repeats:YES];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSInteger tmp=0;
    if (scrollView.contentOffset.x>=lastOffSetX) {
        tmp=floor(scrollView.contentOffset.x/loopView.width);
    }
    else{
        tmp=ceil(scrollView.contentOffset.x/loopView.width);
        
    }
    if (isTap) {
        shouldFPSAnimation=YES;
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (isTap) {
        shouldFPSAnimation=YES;
    }
    isTap=YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger next;
    NSInteger t;
    if (scrollView.contentOffset.x>=lastOffSetX) {
        currentBlockIndex=floor(scrollView.contentOffset.x/loopView.width);
        t=currentBlockIndex-startBlockIndex;
        NSInteger currentIndex=_bfGetCurrentIndex(t,_loopItems.count);
        next=currentIndex==self.loopItems.count-1?0:currentIndex+1;
        UIView *view=self.loopItems[next];
        [view setFrame:CGRectMake(loopView.width*(currentBlockIndex+1), 0, loopView.width, loopView.height)];
        _bfIndexChanged(currentIndex);
    }
    else{
        currentBlockIndex=ceil(scrollView.contentOffset.x/loopView.width);
        t=currentBlockIndex-startBlockIndex;
        NSInteger currentIndex=_bfGetCurrentIndex(t,_loopItems.count);
        next=currentIndex==0?self.loopItems.count-1:currentIndex+-1;
        UIView *view=self.loopItems[next];
        [view setFrame:CGRectMake(loopView.width*(ceil(scrollView.contentOffset.x/loopView.width)-1), 0, loopView.width, loopView.height)];
        _bfIndexChanged(currentIndex);
    }
    lastOffSetX=scrollView.contentOffset.x;
}

-(void)loop{
    _shouldAnimation=YES;
    startTimestamp=CACurrentMediaTime();
    shouldFPSAnimation=YES;
    lastBlockIndexFPS=floor(loopView.contentOffset.x/loopView.width);
    lastBlockIndex=floor(loopView.contentOffset.x/loopView.width);
}
-(void)linkAction:(CADisplayLink *)sender{
    if (_shouldAnimation) {
        if (shouldFPSAnimation) {
            __block CGFloat percent=(sender.timestamp-startTimestamp)/_loopAnimationDuration;
            percent=percent>=1?1:percent;
            //style:
            _bfAnimationFunction(percent);
            currentBlockIndexFPS=floor(loopView.contentOffset.x/loopView.width);
            if (currentBlockIndexFPS>lastBlockIndexFPS) {
                NSInteger tmp=currentBlockIndexFPS;
                currentBlockIndexFPS=lastBlockIndexFPS;
                lastBlockIndexFPS=tmp;
                percent=1;
            }
            [loopView setContentOffset:CGPointMake(loopView.width*(currentBlockIndexFPS+percent), 0)];
            if (percent==1) {
                shouldFPSAnimation=NO;
            }
        }
    }
    //release link and loopTimer
    if (!(self.superview)) {
        link.paused = YES;
        [link invalidate];
        link = nil;
        if (loopTimer.isValid) {
            [loopTimer invalidate];
            loopTimer = nil;
        }
    }
}
-(void)dealloc{
    link.paused = YES;
    [link invalidate];
    link = nil;
    if (loopTimer.isValid) {
        [loopTimer invalidate];
        loopTimer = nil;
    }
}
+(BFLoopView*)loopViewWithItems:(NSArray *)items frame:(CGRect)frame loopPeriod:(NSTimeInterval )period animationDuration:(NSTimeInterval)duration animationStyle:(BuffLoopViewAnimationStyle)style indexChanged:(void(^)(NSInteger loopIndex))indexChanged{
    BFLoopView *loopView=[[BFLoopView alloc]initWithFrame:frame indexChanged:indexChanged];
    [loopView setLoopItems:items];
    [loopView setLoopAnimationDuration:duration];
    [loopView setLoopPeriod:period];
    if (!indexChanged) {
        indexChanged=^(NSInteger loopIndex){};
    }
    loopView.loopAnimationStyle=style;
    
    return loopView;
}

@end
