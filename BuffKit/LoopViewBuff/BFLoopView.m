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
static CGFloat(^_bfAnimationFunction)(CGFloat p);
static void(^_bfIndexChanged)(NSInteger i);

@interface BFLoopView ()
{
    BOOL shouldFPSAnimation;//should trigger loop animation by the CADisplayLink instance
    NSTimer *loopTimer;//controls loop period
    UIScrollView *loopView;
    NSInteger startBlockIndex;//default 0;
    NSInteger currentBlockIndex;
    NSInteger lastBlockIndex;
    NSInteger currentBlockIndexFPS;
    NSInteger lastBlockIndexFPS;

    CGFloat lastOffSetX;//last contentOffset.x before contentOffset.x changed
    NSTimeInterval startTimestamp;//Timestamp of animation's beginning
    CADisplayLink *link;//controls loop animation

    BOOL isTap;//use this to prevent scrollview stucking
}
@end
@implementation BFLoopView
#pragma mark Life circle
-(instancetype)initWithFrame:(CGRect)frame indexChanged:(void(^)(NSInteger loopIndex))indexChanged{
    self=[super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        //prevent 64 y-offset by automaticallyAdjustsScrollViewInsets
        UIView *placeHolderView=[[UIView alloc]initWithFrame:CGRectZero];
        [self addSubview:placeHolderView];
        
        //Default settings
        self.shouldAnimation=NO;
        shouldFPSAnimation=NO;
        startBlockIndex=0;
        currentBlockIndexFPS=0;
        lastBlockIndex=0;
        lastBlockIndexFPS=0;
        self.loopPeriod=4.0;
        self.loopAnimationDuration=1.0;
        _bfAnimationFunction=^(CGFloat p){
            p=-0.5*cos(M_PI*p)+0.5;
            return p;
        };
        //scrollView
        loopView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:loopView];
        [loopView setPagingEnabled:YES];
        [loopView setBounces:NO];
        [loopView setContentSize:CGSizeMake(frame.size.width*(INT16_MAX+1), frame.size.height)];
        [loopView setShowsVerticalScrollIndicator:NO];
        [loopView setShowsHorizontalScrollIndicator:NO];
        [loopView setDirectionalLockEnabled:YES];
        [loopView setDelegate:self];
        
        //page control
        _loopPageControl = [UIPageControl new];
        [_loopPageControl setCenter:CGPointMake(self.width/2, self.height-20)];
        [_loopPageControl setBounds:CGRectMake(0, 0, self.width, 20)];
        [_loopPageControl setPageIndicatorTintColor:[UIColor colorWithWhite:1 alpha:0.5]];
        [_loopPageControl setEnabled:NO];
        [_loopPageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHex:0x4285f4 alpha:0.8]];
        [self addSubview:_loopPageControl];
        
        //callback
        _bfIndexChanged=indexChanged;
        
        isTap=YES;
    }
    return self;
}
-(void)dealloc{
    //destroy link and timer
    link.paused = YES;
    [link invalidate];
    link = nil;
    if (loopTimer.isValid) {
        [loopTimer invalidate];
        loopTimer = nil;
    }
}
#pragma mark - properties access
-(void)setShouldAnimation:(BOOL)shouldAnimation{
    _shouldAnimation=shouldAnimation;
    [loopView setScrollEnabled:YES];
    if (_loopItems.count<2) {
        _shouldAnimation=NO;
        [loopView setScrollEnabled:NO];
    }
    link.paused = YES;
    [link invalidate];
    link = nil;
    if (loopTimer.isValid) {
        [loopTimer invalidate];
        loopTimer = nil;
    }
    if (shouldAnimation) {
        //auto paging control
        shouldFPSAnimation=NO;
        link=[CADisplayLink displayLinkWithTarget:self selector:@selector(linkAction:)];
        startTimestamp=CACurrentMediaTime();
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        loopTimer=[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(loop) userInfo:nil repeats:YES];
    }
}
-(void)setLoopItems:(NSArray *)loopItems{
    _loopItems=loopItems;
    CGFloat initialOffsetX=floor(loopView.contentSize.width/2.0/loopItems.count/loopView.width)*loopView.width*loopItems.count;
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
    [_loopPageControl setNumberOfPages:loopItems.count];
}
-(void)setLoopAnimationStyle:(BuffLoopViewAnimationStyle)loopAnimationStyle{
    _loopAnimationStyle=loopAnimationStyle;
    switch (loopAnimationStyle) {
        case BuffLoopViewAnimationStyleLinear:
            _bfAnimationFunction=^(CGFloat p){return p;};
            break;
        case BuffLoopViewAnimationStyleEasyIn:
            _bfAnimationFunction=^(CGFloat p){
                p=-cos(p*M_PI/2)+1;
                return p;
            };
            break;
        case BuffLoopViewAnimationStyleEasyInOut:
        {
            _bfAnimationFunction=^(CGFloat p){
                p=-0.5*cos(M_PI*p)+0.5;
                return p;
            };
        }
            break;
        case BuffLoopViewAnimationStyleEasyOut:
            _bfAnimationFunction=^(CGFloat p){
                p=sin(p*M_PI/2);
                return p;};
            break;
        default:
            break;
    }
}
#pragma mark - ScrollView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastOffSetX=scrollView.contentOffset.x;
    shouldFPSAnimation=NO;
    [loopTimer invalidate];
    loopTimer = nil;
    lastBlockIndex=floor(scrollView.contentOffset.x/loopView.width);
    isTap=NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    lastOffSetX=scrollView.contentOffset.x;
    loopTimer=[NSTimer scheduledTimerWithTimeInterval:self.loopPeriod target:self selector:@selector(loop) userInfo:nil repeats:YES];
}
//prevent scrollView stucking
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
        [_loopPageControl setCurrentPage:currentIndex];
    }
    else{
        currentBlockIndex=ceil(scrollView.contentOffset.x/loopView.width);
        t=currentBlockIndex-startBlockIndex;
        NSInteger currentIndex=_bfGetCurrentIndex(t,_loopItems.count);
        next=currentIndex==0?self.loopItems.count-1:currentIndex+-1;
        UIView *view=self.loopItems[next];
        [view setFrame:CGRectMake(loopView.width*(ceil(scrollView.contentOffset.x/loopView.width)-1), 0, loopView.width, loopView.height)];
        _bfIndexChanged(currentIndex);
        [_loopPageControl setCurrentPage:currentIndex];
    }
    lastOffSetX=scrollView.contentOffset.x;
}
#pragma mark - Auto paging control
-(void)loop{
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
            percent=_bfAnimationFunction(percent);
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
    //destroy link and timer
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
//设置自定义页面切换动画，注意，必须满足f(0)=0,f(1)=1
-(void)setCustomAnimationStyle:(CGFloat(^)(CGFloat p))animationFunction{
    //p ∈ [0,1]
    if (_loopAnimationStyle == BuffLoopViewAnimationStyleCustom) {
        _bfAnimationFunction=animationFunction;
        if (!_bfAnimationFunction) {
            _bfAnimationFunction=^(CGFloat p){return p;};
        }
    }
}
#pragma mark creat a BFLoopView instance
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
