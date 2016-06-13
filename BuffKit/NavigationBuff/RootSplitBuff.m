//
//  RootVCSplitBuff.m
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "RootSplitBuff.h"
static BFRootViewController *rootViewController=nil;
@implementation BFRootViewController
@synthesize bfMainViewController=_bfMainViewController;
@synthesize bfLeftViewController=_bfLeftViewController;
@synthesize bfRightViewController=_bfRightViewController;
+(BFRootViewController *)sharedController{
    @synchronized (self) {
        if (!rootViewController) {
            rootViewController = [[super allocWithZone:NULL]init];
        }
    }
    return rootViewController;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedController];
}
- (instancetype)init {
    if (rootViewController) {
        return rootViewController;
    }
    self = [super init];
    [self applyDefault];
    [self applyLayout];
    return self;
}
- (void)viewDidLoad {
    
}
-(void)applyDefault
{
    self.mainViewPerspective=NO;
    self.mainViewDimColor=[UIColor clearColor];
    self.mainViewDimOpacity=0.5;
    self.mainViewScale=0.8;
    self.leftWidth=200;
    self.rightWidth=200;
    self.shouldLeftCovered=NO;
    self.shouldRightCovered=NO;
}
-(void)applyLayout
{
    BOOL isStatusBarHidden=[UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication]setStatusBarHidden:!isStatusBarHidden];
    [[UIApplication sharedApplication]setStatusBarHidden:isStatusBarHidden];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.rootBackgroundImageView=[[UIImageView alloc]init];
    [self.rootBackgroundImageView setBackgroundColor:[UIColor whiteColor]];
    [self.rootBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.rootBackgroundImageView];
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(_rootBackgroundImageView,containerView);
    NSDictionary *metrics = @{@"margin":@0};
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSMutableArray*constraints=[NSMutableArray array];
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_rootBackgroundImageView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_rootBackgroundImageView(==containerView)]" options:ops metrics:metrics views:bindings];
    [constraints addObjectsFromArray:c1];
    [constraints addObjectsFromArray:c2];
    [self.rootBackgroundImageView setImage:self.rootBackgroundImage];
    [self.view addConstraints:constraints];
}
#pragma mark 主控制器Access
-(void)setBfMainViewController:(UIViewController *)bfMainViewController {
    [_bfMainViewController.view removeFromSuperview];
    [NSLayoutConstraint deactivateConstraints:fullScreenConstraints];
    _bfMainViewController=bfMainViewController;
    //AutoLayout
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.bfMainViewController.view];
    UIView *mainView=self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(mainView,containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin":@0};
    fullScreenConstraints=[NSMutableArray array];
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    [fullScreenConstraints addObjectsFromArray:c1];
    [fullScreenConstraints addObjectsFromArray:c2];
    [NSLayoutConstraint activateConstraints:fullScreenConstraints];
    //添加阴影
//    [self.bfMainViewController.view.layer setShadowColor:[UIColor whiteColor].CGColor];
//    [self.bfMainViewController.view.layer setShadowOffset:CGSizeZero];
//    [self.bfMainViewController.view.layer setShadowRadius:4.0];
//    [self.bfMainViewController.view.layer setShadowOpacity:0.8];
//    UIBezierPath *shadowPath=[UIBezierPath bezierPathWithRect:self.view.bounds];
//    [self.bfMainViewController.view.layer setShadowPath:shadowPath.CGPath];
}
#pragma mark 左控制器Access
-(void)setBfLeftViewController:(UIViewController *)bfLeftViewController
{
    [_bfLeftViewController.view removeFromSuperview];
    _bfLeftViewController=bfLeftViewController;
}
-(UIViewController *)bfLeftViewController
{
    if (!_bfLeftViewController) {
        _bfLeftViewController=[[UIViewController alloc]init];
        [_bfLeftViewController.view setBackgroundColor:[UIColor whiteColor]];
    }
    return _bfLeftViewController;
}
#pragma mark 右控制器Access
-(UIViewController *)bfRightViewController
{
    if (!_bfRightViewController) {
        _bfRightViewController=[[UIViewController alloc]init];
        [_bfRightViewController.view setBackgroundColor:[UIColor whiteColor]];
    }
    return _bfRightViewController;
}
#pragma mark 设置背景
-(void)setRootBackgroundImage:(UIImage *)rootBackgroundImage
{
    _rootBackgroundImage=rootBackgroundImage;
    [self.rootBackgroundImageView setImage:_rootBackgroundImage];
}
#pragma mark AutoLayout
-(void)updateLeftConstraints{
    [NSLayoutConstraint deactivateConstraints:leftConstraints];
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *leftView=_bfLeftViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(leftView,containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin":@0,@"leftWidth":@(self.leftWidth)};
    leftConstraints=[NSMutableArray array];
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(==leftWidth)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
    [leftConstraints addObjectsFromArray:c1];
    [leftConstraints addObjectsFromArray:c2];
    [NSLayoutConstraint activateConstraints:leftConstraints];
}

#pragma mark Private method
-(void)setMainViewConstraints{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

#pragma mark Public method
-(void)willShowLeftViewController{
    if (self.shouldLeftCovered) {
    }
}
-(void)showLeftViewController{
    if (self.shouldLeftCovered) {
        [_bfLeftViewController.view setWidth:self.leftWidth];
    }
}
@end
@implementation UIViewController (RootVCSplitBuff)

@end
@implementation RootSplitBuff
+(BFRootViewController *)rootViewController{
    return [BFRootViewController sharedController];
}
+(void)showLeftViewController{
    
}
+(void)hideLeftViweController{
    
}
+(void)showRightViewController{
    
}
+(void)hideRightViewController{
    
}
@end
