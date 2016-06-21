//
//  RootVCSplitBuff.m
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "RootSplitBuff.h"

@interface BFRootViewController ()
@end
CGFloat GET_ANGLE_BY_SPLIT_WIDTH(UIView *rootView,CGFloat splitWidth){
    CGFloat angle;
    CGFloat w=rootView.width;
    CGFloat w1=splitWidth;
    angle=(w-w1)/w;
    angle=acos(angle);
    return angle;
}
CGFloat GET_SHORTERHEIGHT_BY_SPLIT_WIDTH(UIView *rootView,CGFloat splitWidth){
    CGFloat shorterHeight;
    CGFloat angle=GET_ANGLE_BY_SPLIT_WIDTH(rootView,splitWidth);
    CGFloat h=rootView.width*cos(angle);
    CGFloat tanB=rootView.height/BF_EYE_DISTANCE_PERSPECTIVE/2;
    shorterHeight=2*(BF_EYE_DISTANCE_PERSPECTIVE-h)*tanB;
    return shorterHeight;
}
static BFRootViewController *rootViewController=nil;
@implementation BFRootViewController
@synthesize bfMainViewController=_bfMainViewController;
@synthesize bfLeftViewController=_bfLeftViewController;
@synthesize bfRightViewController=_bfRightViewController;
@synthesize dimView=_dimView;
@synthesize leftDelegate;
@synthesize rigtDelegate;
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
    [self.rootBackgroundImageView setImage:self.rootBackgroundPortraitImage];
    [self.view addConstraints:constraints];
    [self.rootBackgroundImageView removeFromSuperview];
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (self.view.width>self.view.height){
        [self.rootBackgroundImageView setImage:self.rootBackgroundLandscapeImage];
    }
    else{
        [self.rootBackgroundImageView setImage:self.rootBackgroundPortraitImage];
    }
    if ((self.splitStyle==BuffSplitStyleScaled||self.splitStyle==BuffSplitStylePerspective)&&self.isLeftShowing) {
        self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
        CATransform3D transform=CATransform3DIdentity;
        CGFloat s=self.mainScale;
        transform=CATransform3DScale(transform, s, s, 1);
        CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
        transform=CATransform3DTranslate(transform,tX , 0, 0);
        self.bfMainViewController.view.layer.transform=transform;

    }
    else  if ((self.splitStyle==BuffSplitStyleScaled||self.splitStyle==BuffSplitStylePerspective)&&self.isRightShowing) {
        self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
        CATransform3D transform=CATransform3DIdentity;
        CGFloat s=self.mainScale;
        transform=CATransform3DScale(transform, s, s, 1);
        CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
        transform=CATransform3DTranslate(transform,-tX , 0, 0);
        self.bfMainViewController.view.layer.transform=transform;
    }
}
#pragma mark - Initial configuration
-(void)applyDefault
{
    self.splitStyle=BuffSplitStylePerspective;
    self.dimColor=[UIColor lightGrayColor];
    self.dimOpacity=0.5;
    self.mainScale=0.8;
    self.leftWidth=200;
    self.rightWidth=200;
    self.leftAnimationDuration=0.3;
    self.rightAnimationDuration=0.3;
    self.leftStartOffset=0;
    self.rightStartOffset=0;
    self.mainEndOffsetForLeft=150;
    self.mainEndOffsetForRight=150;
    mainStartConstraints=[NSMutableArray array];
    mainEndConstraints=[NSMutableArray array];
    leftStartConstraints=[NSMutableArray array];
    leftEndConstraints=[NSMutableArray array];
    rightStartConstraints=[NSMutableArray array];
    rightEndConstraints=[NSMutableArray array];
}
-(void)applyLayout
{
    BOOL isStatusBarHidden=[UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication]setStatusBarHidden:!isStatusBarHidden];
    [[UIApplication sharedApplication]setStatusBarHidden:isStatusBarHidden];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}
#pragma mark - properties' access
-(void)setBfMainViewController:(UIViewController *)bfMainViewController {
    [_bfMainViewController.view removeFromSuperview];
    [self.view addConstraints:mainStartConstraints];
    _bfMainViewController=bfMainViewController;
    //AutoLayout
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView addSubview:self.bfMainViewController.view];
    UIView *mainView=self.bfMainViewController.view;
    UIView *containerView=self.rootBackgroundImageView;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(mainView,containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin":@0};
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    [mainStartConstraints removeAllObjects];
    [mainStartConstraints addObjectsFromArray:c1];
    [mainStartConstraints addObjectsFromArray:c2];
    [self.view addConstraints:mainStartConstraints];
    if(!_bfLeftPan){
    _bfLeftPan=[[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanAction:)];
    self.bfLeftPan.edges=UIRectEdgeLeft;
    [self.bfLeftPan setDelegate:self];
    [self.bfLeftPan setEnabled:NO];
    [self.view addGestureRecognizer:self.bfLeftPan];
    }
    if (!_bfRightPan) {
    _bfRightPan=[[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(rightPanAction:)];
    self.bfRightPan.edges=UIRectEdgeRight;
    [self.bfRightPan setDelegate:self];
    [self.bfRightPan setEnabled:NO];
    [self.view addGestureRecognizer:_bfRightPan];
    }
    if (!_bfMainPan) {
        _bfMainPan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(rightPanAction:)];
        [self.bfMainPan setDelegate:self];
        [self.bfMainPan setEnabled:NO];
        [self.view addGestureRecognizer:self.bfMainPan];
        mainPanDirection=BuffPanDirectionNone;
    }
    
}
-(void)setBfLeftViewController:(UIViewController *)bfLeftViewController
{
    [_bfLeftViewController.view removeFromSuperview];
    _bfLeftViewController=bfLeftViewController;
}
-(UIViewController *)bfLeftViewController
{
    if (!_bfLeftViewController) {
        _bfLeftViewController=[[UIViewController alloc]init];
        [_bfLeftViewController.view setBackgroundColor:[UIColor clearColor]];
    }
    return _bfLeftViewController;
}
-(void)setBfRightViewController:(UIViewController *)bfRightViewController
{
    [_bfRightViewController.view removeFromSuperview];
    _bfRightViewController=bfRightViewController;
}
-(UIViewController *)bfRightViewController
{
    if (!_bfRightViewController) {
        _bfRightViewController=[[UIViewController alloc]init];
        [_bfRightViewController.view setBackgroundColor:[UIColor clearColor]];
    }
    return _bfRightViewController;
}
-(void)setRootBackgroundPortraitImage:(UIImage *)rootBackgroundPortraitImage
{
    _rootBackgroundPortraitImage=rootBackgroundPortraitImage;
    [self.rootBackgroundImageView setImage:rootBackgroundPortraitImage];
}
-(void)setRootBackgroundLandscapeImage:(UIImage *)rootBackgroundLandscapeImage
{
    _rootBackgroundLandscapeImage=rootBackgroundLandscapeImage;
    [self.rootBackgroundImageView setImage:rootBackgroundLandscapeImage];
}
-(void)setIsLeftShowing:(BOOL)isLeftShowing
{
    _isLeftShowing=isLeftShowing;
    self.bfMainPan.enabled=!(_isLeftShowing||_isRightShowing);
    self.bfLeftPan.enabled=!(_isLeftShowing||_isRightShowing);
    self.bfRightPan.enabled=!(_isLeftShowing||_isRightShowing);
    if (!isLeftShowing) {
        [self.bfLeftViewController.view removeFromSuperview];
        [self.dimView removeFromSuperview];
    }
}
-(void)setIsRightShowing:(BOOL)isRightShowing
{
    _isRightShowing=isRightShowing;
    self.bfMainPan.enabled=!(_isLeftShowing||_isRightShowing);
    self.bfLeftPan.enabled=!(_isLeftShowing||_isRightShowing);
    self.bfRightPan.enabled=!(_isLeftShowing||_isRightShowing);
    if (!isRightShowing) {
        [self.bfRightViewController.view removeFromSuperview];
        [self.dimView removeFromSuperview];
    }
}

#pragma mark Private method
-(void)addDimButton{
    [_dimView removeFromSuperview];
    _dimView = [[UIButton alloc] init];
    [_dimView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dimView setBackgroundColor:[RootSplitBuff rootViewController].dimColor ];
    UIPanGestureRecognizer *dimPan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dimPanAction:)];;
    UITapGestureRecognizer *dimTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dimTapAction:)];
    [_dimView addGestureRecognizer:dimPan];
    [_dimView addGestureRecognizer:dimTap];
    [dimPan setDelegate:self];
    [dimTap setDelegate:self];
    [self.bfMainViewController.view addSubview:_dimView];
    UIView *mainView=self.bfMainViewController.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView,_dimView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    dimConstraints = [NSMutableArray array];
    NSDictionary *dmetrics1 = @{@"margin" : @0};
    NSArray *dc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_dimView(==mainView)]" options:ops metrics:dmetrics1 views:bindings];
    NSArray *dc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_dimView(==mainView)]" options:ops metrics:dmetrics1 views:bindings];
    [dimConstraints addObjectsFromArray:dc1];
    [dimConstraints addObjectsFromArray:dc2];
    [_dimView setAlpha:0];
    [mainView addConstraints:dimConstraints];
}

-(void)_updateMainStartConstraintsForLeft{
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
    [self.view addConstraints:mainStartConstraints];
}
-(void)_updateMainEndConstraintsForLeft{
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
    [mainEndConstraints removeAllObjects];
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:{
            NSDictionary *metrics = @{@"margin" : @(_mainEndOffsetForLeft)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:mainEndConstraints];
        }
            break;
        case BuffSplitStyleScaled:{
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            [mainStartConstraints addObjectsFromArray:c1];
            [mainStartConstraints addObjectsFromArray:c2];
            [self.view addConstraints:mainStartConstraints];
            
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)_updateMainStartConstraintsForRight{
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
    [self.view addConstraints:mainStartConstraints];
}
-(void)_updateMainEndConstraintsForRight{
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
    [mainEndConstraints removeAllObjects];
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:{
            NSDictionary *metrics = @{@"margin" : @(_mainEndOffsetForRight)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:mainEndConstraints];
        }
            break;
        case BuffSplitStyleScaled:{
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-0-|" options:ops metrics:nil views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:mainEndConstraints];
        }
        
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }

}
-(void)_updateLeftStartConstraints{
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:leftStartConstraints];
    [self.view removeConstraints:leftEndConstraints];
    [leftStartConstraints removeAllObjects];
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @(-leftWidth), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
            [self.view addConstraints:leftStartConstraints];
        }
            break;
        case BuffSplitStyleScaled:
        {
            NSDictionary *metrics = @{@"margin" : @(-leftWidth), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
            [self.view addConstraints:leftStartConstraints];
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)_updateLeftEndConstraints{
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:leftStartConstraints];
    [self.view removeConstraints:leftEndConstraints];
    [leftEndConstraints removeAllObjects];
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftEndConstraints addObjectsFromArray:c1];
            [leftEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:leftEndConstraints];
        }
            break;
        case BuffSplitStyleScaled:
        {
            NSDictionary *metrics = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftEndConstraints addObjectsFromArray:c1];
            [leftEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:leftEndConstraints];
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)_updateRightStartConstraints{
    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:rightStartConstraints];
    [self.view removeConstraints:rightEndConstraints];
    CGFloat rightWidth = [[RootSplitBuff rootViewController] rightWidth];
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(rightView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @(-rightWidth), @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightStartConstraints addObjectsFromArray:c1];
            [rightStartConstraints addObjectsFromArray:c2];
            [self.view addConstraints:rightStartConstraints];
        }
            break;
        case BuffSplitStyleScaled:{
            NSDictionary *metrics = @{@"margin" : @(-rightWidth), @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightStartConstraints addObjectsFromArray:c1];
            [rightStartConstraints addObjectsFromArray:c2];
            [self.view addConstraints:rightStartConstraints];
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)_updateRightEndConstraints{
    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:rightStartConstraints];
    [self.view removeConstraints:rightEndConstraints];
    [rightEndConstraints removeAllObjects];
    CGFloat rightWidth = [[RootSplitBuff rootViewController] rightWidth];
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(rightView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:rightEndConstraints];
        }
            break;
        case BuffSplitStyleScaled:{
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            [self.view addConstraints:rightEndConstraints];

        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)_clearRightConstraints{
    [self.view removeConstraints:rightStartConstraints];
    [self.view removeConstraints:rightEndConstraints];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
}
-(void)_completeLeftConstraints{
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self _updateLeftEndConstraints];
    [self.view layoutIfNeeded];
}
-(void)_completeRightConstraints{
    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self _updateRightEndConstraints];
    [self.view layoutIfNeeded];
}
-(void)_scaleMainViewForRightAt:(CGFloat)ratio{
    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
    CATransform3D transform=CATransform3DIdentity;
    CGFloat s=ratio*self.mainScale;
    transform=CATransform3DScale(transform, s, s, 1);
    CGFloat tX=(1/s)*(1-s)*self.bfMainViewController.view.width/2;
    transform=CATransform3DTranslate(transform,tX , 0, 0);
    self.bfMainViewController.view.layer.transform=transform;
}
-(void)_restoreMainViewForRightAt:(CGFloat)ratio{
    CATransform3D transform=CATransform3DIdentity;
    
    CGFloat s=self.mainScale+ratio*(1-self.mainScale);
    
    transform=CATransform3DScale(transform, s, s, 1);
    CGFloat tX=(1/self.mainScale)*(1-self.mainScale)*self.bfMainViewController.view.width/2;
    transform=CATransform3DTranslate(transform,tX-tX*ratio , 0, 0);
    self.bfMainViewController.view.layer.transform=transform;
}

#pragma mark Public method
-(void)showLeftViewController{
        NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView=self.view;
    [leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addDimButton];
//    [containerView addSubview:leftView];
//    [self _updateLeftStartConstraints];
//    [containerView layoutIfNeeded];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi>li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateLeftEndConstraints];
            [self _updateMainEndConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                
            }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
            }];
        }
            break;
        case BuffSplitStyleScaled:
        {
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi<li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateLeftEndConstraints];
            [self _updateMainEndConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [containerView layoutIfNeeded];
                CATransform3D transform=CATransform3DIdentity;
                CGFloat s=self.mainScale;
                transform=CATransform3DScale(transform, s, s, 1);
                CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
                transform=CATransform3DTranslate(transform,tX , 0, 0);
                self.bfMainViewController.view.layer.transform=transform;
            }                completion:^(BOOL finished) {
                [containerView layoutIfNeeded];
                [self setIsLeftShowing:YES];
                self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                CATransform3D transform=CATransform3DIdentity;
                CGFloat s=self.mainScale;
                transform=CATransform3DScale(transform, s, s, 1);
                CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
                transform=CATransform3DTranslate(transform,tX , 0, 0);
                self.bfMainViewController.view.layer.transform=transform;
            }];
        }
            break;
        case BuffSplitStylePerspective:{
            CATransform3D transform=CATransform3DIdentity;
            transform.m34=-1/2000;
            transform=CATransform3DRotate(transform, -0.3, 0, 1, 0);
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height/2)];
            self.bfMainViewController.view.layer.transform=transform;


            return;
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi<li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateLeftStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateLeftEndConstraints];
            [self _updateMainEndConstraintsForLeft];
            [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [containerView layoutIfNeeded];
                
            }                completion:^(BOOL finished) {
                [containerView layoutIfNeeded];
                [self setIsLeftShowing:YES];
                CATransform3D transform=CATransform3DIdentity;
                transform=CATransform3DRotate(transform, 1, 0, 1, 0);
                self.bfMainViewController.view.layer.anchorPoint=CGPointMake(1, 0.5);
                self.bfMainViewController.view.layer.transform=transform;
            }];
        }
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)hideLeftViewController{
    NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView=self.view;
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self _updateLeftStartConstraints];
            [self _updateMainStartConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:0];
            }   completion:^(BOOL finished) {
                [self setIsLeftShowing:NO];
            }];
        }
            break;
        case BuffSplitStyleScaled:{
            [self _updateLeftStartConstraints];
            [self _updateMainStartConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                [_dimView setAlpha:0];
            }                completion:^(BOOL finished) {
                [self setIsLeftShowing:NO];
                self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            }];
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)showRightViewController{
    NSTimeInterval duration = [RootSplitBuff rootViewController].rightAnimationDuration;
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView=self.view;
    [self addDimButton];
    [containerView addSubview:rightView];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateRightEndConstraints];
            [self _updateMainEndConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
            }   completion:^(BOOL finished) {
                [self setIsRightShowing:YES];
            }];
        }
            break;
        case BuffSplitStyleScaled:{
            NSInteger li=[self.view.subviews indexOfObject:self.bfRightViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi<li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateRightEndConstraints];
            [self _updateMainEndConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                CATransform3D transform=CATransform3DIdentity;
                CGFloat s=self.mainScale;
                transform=CATransform3DScale(transform, s, s, 1);
                CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
                transform=CATransform3DTranslate(transform,-tX , 0, 0);
                self.bfMainViewController.view.layer.transform=transform;
            }   completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [containerView layoutIfNeeded];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
                    transform=CATransform3DTranslate(transform,-tX , 0, 0);
                self.bfMainViewController.view.layer.transform=transform;
            }];
        }
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)hideRightViewController{
    NSTimeInterval duration = [RootSplitBuff rootViewController].rightAnimationDuration;
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView=self.view;
    [rightView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [containerView removeConstraints:rightEndConstraints];
            [self _updateRightStartConstraints];
            [self _updateMainStartConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:0];
                
            }                completion:^(BOOL finished) {
                [_dimView removeFromSuperview];
                [rightView removeFromSuperview];
                [self setIsRightShowing:NO];
            }];
        }
            break;
        case BuffSplitStyleScaled:
        {
            [self _updateRightStartConstraints];
            [self _updateMainStartConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                [_dimView setAlpha:0];
            }   completion:^(BOOL finished) {
                [self setIsRightShowing:NO];
                self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            }];
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
}
-(void)activeLeftPanGestureOnEdge:(BOOL)onEdge{
    if (onEdge) {
        self.bfLeftPan.enabled=YES;
        self.bfMainPan.enabled=NO;
    }
    else{
        self.bfLeftPan.enabled=NO;
        self.bfMainPan.enabled=YES;
    }
}
-(void)deactiveLeftPanGesture{
    self.bfLeftPan.enabled=NO;
    self.bfMainPan.enabled=NO;

}
-(void)activeRightPanGestureOnEdge:(BOOL)onEdge{
    if (onEdge) {
        self.bfRightPan.enabled=YES;
        self.bfMainPan.enabled=NO;
    }
    else{
        self.bfRightPan.enabled=NO;
        self.bfMainPan.enabled=YES;
    }
}
-(void)deactiveRightPanGesture{
    self.bfRightPan.enabled=NO;
    self.bfMainPan.enabled=NO;
}
#pragma mark - Gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isEqual:self.bfLeftPan]||[gestureRecognizer isEqual:self.bfRightPan]) {
        if ([otherGestureRecognizer  isKindOfClass:[UISwipeGestureRecognizer class]]||[otherGestureRecognizer  isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            return YES;
        }
        return NO;
    }
    //如果不进行判断dimPan会因为dimTap导致明显延迟
    if ([gestureRecognizer.view isEqual:self.dimView]&&[gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}
#pragma mark - Gesture Action
-(void)mainPanAction:(UIPanGestureRecognizer *)gesture{

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self addDimButton];
            beginPoint=[gesture locationInView:self.view];
            [self leftPanGestureBegin:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self leftPanGestureChanged:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            [self leftPanGestureEnd:gesture];
            break;
        case UIGestureRecognizerStateCancelled:
            [self hideLeftViewController];
            break;
        case UIGestureRecognizerStateFailed:
            [self hideLeftViewController];
            break;
        default:
            break;
    }
}
-(void)leftPanAction:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self addDimButton];
            [self leftPanGestureBegin:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self leftPanGestureChanged:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            [self leftPanGestureEnd:gesture];
            break;
        case UIGestureRecognizerStateCancelled:
            [self hideLeftViewController];
            break;
        case UIGestureRecognizerStateFailed:
            [self hideLeftViewController];
            break;
        default:
            break;
    }

    
}
-(void)leftPanGestureBegin:(UIPanGestureRecognizer *)gesture{
    beginPoint=[gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfLeftViewController.view setFrame:CGRectMake(-self.leftWidth, 0, self.leftWidth, self.view.height)];
            [self.rootBackgroundImageView addSubview:self.bfLeftViewController.view];
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi>li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
        }
            break;
        case BuffSplitStyleScaled:
        {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfLeftViewController.view setFrame:CGRectMake(-self.leftWidth, 0, self.leftWidth, self.view.height)];
            [self.rootBackgroundImageView addSubview:self.bfLeftViewController.view];
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi<li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateMainStartConstraintsForLeft];
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffWillPushInLeftSplitView];
}
-(void)leftPanGestureChanged:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX<0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    CGFloat scaledDiffX=percent*self.leftWidth;
    [_dimView setAlpha:self.dimOpacity*percent];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setFrame:CGRectMake(scaledDiffX-self.leftWidth, 0, self.leftWidth, self.view.height)];
            [self.bfMainViewController.view setX:percent*_mainEndOffsetForLeft];
        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfLeftViewController.view setFrame:CGRectMake(scaledDiffX-self.leftWidth, 0, self.leftWidth, self.view.height)];
            self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            CATransform3D transform=CATransform3DIdentity;
            CGFloat s=1-(1-self.mainScale)*percent;
            CGFloat tX=(1/s)*(scaledDiffX+(s-1)*self.bfMainViewController.view.width/2);
            transform=CATransform3DScale(transform, s, s, 1);
            transform=CATransform3DTranslate(transform,tX , 0, 0);
            self.bfMainViewController.view.layer.transform=transform;
            
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffPushingInLeftSplitView:percent];
}
-(void)leftPanGestureEnd:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX<0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent>BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setFrame:CGRectMake(_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];

                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self _updateLeftEndConstraints];
                    [self _updateMainEndConstraintsForLeft];
                    [self.view layoutIfNeeded];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [self.bfMainViewController.view setX:0];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForLeft];
                    [self.view layoutIfNeeded];
                    [self setIsLeftShowing:NO];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled:{
            if (percent>BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(1/s)*(self.leftWidth+(s-1)*self.bfMainViewController.view.width/2);
                    transform=CATransform3DTranslate(transform,tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self.view layoutIfNeeded];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
                    transform=CATransform3DTranslate(transform,tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                }];
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                }];
            }
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffEndPushingInLeftSplitViewAt:percent];

}

-(void)rightPanAction:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self addDimButton];
            [self rightPanGestureBegin:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self rightPanGestureChanged:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            [self rightPanGestureEnd:gesture];
            break;
        case UIGestureRecognizerStateCancelled:
            [self hideRightViewController];
            break;
        case UIGestureRecognizerStateFailed:
            [self hideRightViewController];
            break;
        default:
            break;
    }
}
-(void)rightPanGestureBegin:(UIPanGestureRecognizer *)gesture{
    currentWidth=[[UIScreen mainScreen]bounds].size.width;
    beginPoint=[gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfRightViewController.view setFrame:CGRectMake(currentWidth, 0, self.rightWidth, self.view.height)];
            [self.rootBackgroundImageView addSubview:self.bfRightViewController.view];

        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfRightViewController.view setFrame:CGRectMake(self.rightWidth+self.view.width, 0, self.rightWidth, self.view.height)];
            [self.rootBackgroundImageView addSubview:self.bfRightViewController.view];
            NSInteger li=[self.view.subviews indexOfObject:self.bfRightViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi<li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateMainStartConstraintsForRight];
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.rigtDelegate rootSplitBuffWillPushInRightSplitView];
}
-(void)rightPanGestureChanged:(UIPanGestureRecognizer *)gesture{
    currentWidth=[[UIScreen mainScreen]bounds].size.width;
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX>0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.rightWidth);
    percent=percent>1?1:percent;
    CGFloat scaledDiffX=percent*self.rightWidth;
    [_dimView setAlpha:self.dimOpacity*percent];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setFrame:CGRectMake(currentWidth-scaledDiffX, 0, self.rightWidth, self.view.height)];
             [self.bfMainViewController.view setX:-percent*_mainEndOffsetForRight];
        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfRightViewController.view setFrame:CGRectMake(self.view.width-scaledDiffX, 0, self.rightWidth, self.view.height)];
            self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            CATransform3D transform=CATransform3DIdentity;
            CGFloat s=1-(1-self.mainScale)*percent;
            CGFloat tX=(1/s)*(scaledDiffX+(s-1)*self.bfMainViewController.view.width/2);
            transform=CATransform3DScale(transform, s, s, 1);
            transform=CATransform3DTranslate(transform,-tX , 0, 0);
            self.bfMainViewController.view.layer.transform=transform;
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.rigtDelegate rootSplitBuffPushingInRightSplitView:percent];
}
-(void)rightPanGestureEnd:(UIPanGestureRecognizer *)gesture{
    currentWidth=[[UIScreen mainScreen]bounds].size.width;
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX>0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent>BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:(1-percent)*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setX:-_mainEndOffsetForRight];
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth-_rightWidth, 0, self.rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self _updateRightEndConstraints];
                    [self _updateMainEndConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setX:0];
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth, 0, self.rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
                
            }
        }
            break;
        case BuffSplitStyleScaled:{
            if (percent>BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:(1-percent)*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width-self.rightWidth, 0, self.rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(1/s)*(self.rightWidth+(s-1)*self.bfMainViewController.view.width/2);
                    transform=CATransform3DTranslate(transform,-tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self.view layoutIfNeeded];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(self.rightWidth-(1-s)*self.bfMainViewController.view.width/2)*1/s;
                    transform=CATransform3DTranslate(transform,-tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                }];
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                }];
            }
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffEndPushingInLeftSplitViewAt:percent];
}
-(void)dimPanAction:(UIPanGestureRecognizer *)gesture{
    if (self.isLeftShowing) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                [self dimPanForLeftBegin:gesture];
                break;
            case UIGestureRecognizerStateChanged:
                [self dimPanForLeftChanged:gesture];
                break;
            case UIGestureRecognizerStateEnded:
                [self dimPanForLeftEnd:gesture];
                break;
            default:
                break;
        }
    }
    else if (self.isRightShowing){
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                [self dimPanForRightBegin:gesture];
                break;
            case UIGestureRecognizerStateChanged:
                [self dimPanForRightChanged:gesture];
                break;
            case UIGestureRecognizerStateEnded:
                [self dimPanForRightEnd:gesture];
                break;
            default:
                break;
        }
    }
}
-(void)dimPanForLeftBegin:(UIPanGestureRecognizer *)gesture{
    beginPoint=[gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self _updateMainStartConstraintsForLeft];
            [self.view layoutIfNeeded];
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffWillPushOutLeftSplitView];
}
-(void)dimPanForLeftChanged:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX>0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    CGFloat scaledDiffX=percent*self.leftWidth;
    [_dimView setAlpha:self.dimOpacity*(1-percent)];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setFrame:CGRectMake(-scaledDiffX, 0, _leftWidth, self.bfLeftViewController.view.height)];
            [self.bfMainViewController.view setX:_mainEndOffsetForLeft-percent*_mainEndOffsetForLeft];

        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfLeftViewController.view setFrame:CGRectMake(-scaledDiffX, 0, _leftWidth, self.bfLeftViewController.view.height)];
            self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            CATransform3D transform=CATransform3DIdentity;
            CGFloat s=self.mainScale+(1-self.mainScale)*percent;
            CGFloat tX=(1/s)*(self.leftWidth-(1-self.mainScale)*self.bfMainViewController.view.width/2-(self.leftWidth-(1-self.mainScale)*self.bfMainViewController.view.width/2)*percent);
            transform=CATransform3DScale(transform, s, s, 1);
            transform=CATransform3DTranslate(transform,tX , 0, 0);
            self.bfMainViewController.view.layer.transform=transform;
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffPushingOutLeftSplitView:percent];
}
-(void)dimPanForLeftEnd:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX>0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    CGFloat scaledDiffX=percent*self.leftWidth;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent<BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:percent*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                    [self.bfMainViewController.view setX:_mainEndOffsetForLeft];

                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self _updateMainEndConstraintsForLeft];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setX:0];
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForLeft];
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled:{
            if (percent<BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:percent*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CATransform3D transform=CATransform3DIdentity;
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    CGFloat tX=(1/s)*(self.leftWidth-(1-self.mainScale)*self.bfMainViewController.view.width/2);
                    transform=CATransform3DScale(transform, s, s, 1);
                    transform=CATransform3DTranslate(transform,tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                    [_dimView setAlpha:self.dimOpacity];
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                } completion:^(BOOL finished) {
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(1/s)*(self.leftWidth+(s-1)*self.bfMainViewController.view.width/2);
                    transform=CATransform3DTranslate(transform,tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self.view layoutIfNeeded];
                    [self setIsLeftShowing:YES];

                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self _updateMainStartConstraintsForLeft];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.leftDelegate rootSplitBuffEndPushingOutLeftSplitViewAt:percent];
}
-(void)dimPanForRightBegin:(UIPanGestureRecognizer *)gesture{
    beginPoint=[gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self _updateMainStartConstraintsForRight];
            [self.view layoutIfNeeded];
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.rigtDelegate rootSplitBuffWillPushOutRightSplitView];
}
-(void)dimPanForRightChanged:(UIPanGestureRecognizer *)gesture{
    currentWidth=[[UIScreen mainScreen]bounds].size.width;
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX<0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.rightWidth);
    percent=percent>1?1:percent;
    CGFloat scaledDiffX=percent*self.rightWidth;
    [_dimView setAlpha:self.dimOpacity*(1-percent)];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setFrame:CGRectMake(currentWidth-_rightWidth+scaledDiffX, 0, _rightWidth, self.bfRightViewController.view.height)];
            [self.bfMainViewController.view setX:percent*_mainEndOffsetForLeft-_mainEndOffsetForLeft];
        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfRightViewController.view setFrame:CGRectMake(currentWidth-_rightWidth+scaledDiffX, 0, _rightWidth, self.bfRightViewController.view.height)];
            self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            CATransform3D transform=CATransform3DIdentity;
            CGFloat s=self.mainScale+(1-self.mainScale)*percent;
            CGFloat tX=(1/s)*(self.rightWidth-(1-self.mainScale)*self.bfMainViewController.view.width/2-(self.rightWidth-(1-self.mainScale)*self.bfMainViewController.view.width/2)*percent);
            transform=CATransform3DScale(transform, s, s, 1);
            transform=CATransform3DTranslate(transform,-tX , 0, 0);
            self.bfMainViewController.view.layer.transform=transform;
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.rigtDelegate rootSplitBuffPushingOutRightSplitView:percent];
}
-(void)dimPanForRightEnd:(UIPanGestureRecognizer *)gesture{
    currentWidth=[[UIScreen mainScreen]bounds].size.width;
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX<0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALED_PAN/self.rightWidth);
    percent=percent>1?1:percent;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent<BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:percent*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth-_rightWidth, 0, self.rightWidth, self.view.height)];
                    [self.bfMainViewController.view setX:-_mainEndOffsetForLeft];

                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self _updateMainEndConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth, 0, self.rightWidth, self.view.height)];
                    [self.bfMainViewController.view setX:0];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled:{
            if (percent<BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:percent*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CATransform3D transform=CATransform3DIdentity;
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    CGFloat tX=(1/s)*(self.rightWidth-(1-self.mainScale)*self.bfMainViewController.view.width/2);
                    transform=CATransform3DScale(transform, s, s, 1);
                    transform=CATransform3DTranslate(transform,-tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                    [_dimView setAlpha:self.dimOpacity];
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width-self.rightWidth, 0, self.rightWidth, self.view.height)];
                } completion:^(BOOL finished) {
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    CATransform3D transform=CATransform3DIdentity;
                    CGFloat s=self.mainScale;
                    transform=CATransform3DScale(transform, s, s, 1);
                    CGFloat tX=(1/s)*(self.rightWidth+(s-1)*self.bfMainViewController.view.width/2);
                    transform=CATransform3DTranslate(transform,-tX , 0, 0);
                    self.bfMainViewController.view.layer.transform=transform;
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self.view layoutIfNeeded];
                    [self setIsRightShowing:YES];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self _updateMainStartConstraintsForRight];
                    self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
                    [self.view layoutIfNeeded];
                }];
            }
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.rigtDelegate rootSplitBuffEndPushingOutRightSplitViewAt:percent];
}
-(void)dimTapAction:(UITapGestureRecognizer *)gesture{
    if (_isLeftShowing) {
        [RootSplitBuff hideLeftViewController];
    }
    if (_isRightShowing) {
        [RootSplitBuff hideRightViewController];
    }
}

@end
#pragma mark - RootSplitBuff
@implementation RootSplitBuff
+(BFRootViewController *)rootViewController{
    return [BFRootViewController sharedController];
}
#pragma mark - show or hide side viewController;
+(void)showLeftViewController{
    [[BFRootViewController sharedController]showLeftViewController];
}
+(void)hideLeftViewController{
    [[BFRootViewController sharedController]hideLeftViewController];
}
+(void)showRightViewController{
    [[BFRootViewController sharedController]showRightViewController];
}
+(void)hideRightViewController{
    [[BFRootViewController sharedController]hideRightViewController];
}
#pragma mark - active or deactive gestures
+(void)activeLeftPanGestureOnEdge:(BOOL)onEdge{
    [[BFRootViewController sharedController]activeLeftPanGestureOnEdge:onEdge];
}
+(void)deactiveLeftPanGesture{
    [[BFRootViewController sharedController]deactiveLeftPanGesture];
}
+(void)activeRightPanGestureOnEdge:(BOOL)onEdge{
    [[BFRootViewController sharedController]activeRightPanGestureOnEdge:onEdge];
}
+(void)deactiveRightPanGesture{
    [[BFRootViewController sharedController]deactiveRightPanGesture];
}
@end
