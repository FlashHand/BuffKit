//
//  RootVCSplitBuff.m
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "RootSplitBuff.h"
@interface BFRootViewController ()
{
    UIPercentDrivenInteractiveTransition *leftTransitionControl;
    UIPercentDrivenInteractiveTransition *rightTransitionControl;
    UIScreenEdgePanGestureRecognizer *leftEdgePanGesture;
    UIPanGestureRecognizer *leftPanGesture;
    UIScreenEdgePanGestureRecognizer *rightEdgePanGesture;
    UIPanGestureRecognizer *rightPanGesture;
}
@end
static BFRootViewController *rootViewController=nil;
@implementation BFRootViewController
@synthesize bfMainViewController=_bfMainViewController;
@synthesize bfLeftViewController=_bfLeftViewController;
@synthesize bfRightViewController=_bfRightViewController;
@synthesize dimView=_dimView;
@synthesize delegate;

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
        [self _scaleMainViewForLeftAt:1];
    }
    else  if ((self.splitStyle==BuffSplitStyleScaled||self.splitStyle==BuffSplitStylePerspective)&&self.isRightShowing) {
        [self _scaleMainViewForRightAt:1];
    }
}
#pragma mark - Initial configuration
-(void)applyDefault
{
    self.splitStyle=BuffSplitStyleScaled;
    self.dimColor=[UIColor lightGrayColor];
    self.dimOpacity=0.5;
    self.mainScale=0.8;
    self.leftWidth=200;
    self.rightWidth=200;
    self.leftAnimationDuration=0.6;
    self.rightAnimationDuration=0.6;
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
    [self.view addSubview:self.bfMainViewController.view];
    UIView *mainView=self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(mainView,containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin":@0};
    mainStartConstraints=[NSMutableArray array];
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
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
    self.bfLeftPan.enabled=!(_isLeftShowing||_isRightShowing);
    if (!isLeftShowing) {
        [self.bfLeftViewController.view removeFromSuperview];
        [self.dimView removeFromSuperview];
    }
}
-(void)setIsRightShowing:(BOOL)isRightShowing
{
    _isRightShowing=isRightShowing;
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

-(NSMutableArray *)_updateMainStartConstraintsForLeft{
    if (mainStartConstraints) {
        [mainStartConstraints removeAllObjects];
    }
    else{
        mainStartConstraints = [NSMutableArray array];
    }
    UIView *leftView = self.bfLeftViewController.view;
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @0};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainStartConstraints addObjectsFromArray:c1];
            [mainStartConstraints addObjectsFromArray:c2];
        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    return mainStartConstraints;
}
-(NSMutableArray *)_updateMainEndConstraintsForLeft{
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    return mainEndConstraints;
}
-(void)_updateLeftStartConstraints{
    [self _clearLeftConstraints];
    [leftStartConstraints removeAllObjects];
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, mainView, containerView);
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
            [self.view addConstraints:mainStartConstraints];
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
-(void)_updateLeftEndConstraints{
    [self _clearLeftConstraints];
    [leftEndConstraints removeAllObjects];
    [mainEndConstraints removeAllObjects];
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;

    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftEndConstraints addObjectsFromArray:c1];
            [leftEndConstraints addObjectsFromArray:c2];
            
            NSDictionary *metrics1 = @{@"margin" : @(_mainEndOffsetForLeft)};
            NSArray *mc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics1 views:bindings];
            NSArray *mc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics1 views:bindings];
            [mainEndConstraints addObjectsFromArray:mc1];
            [mainEndConstraints addObjectsFromArray:mc2];
            [self.view addConstraints:leftEndConstraints];
            [self.view addConstraints:mainEndConstraints];

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

            NSArray *mc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftWidth-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            NSArray *mc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainEndConstraints addObjectsFromArray:mc1];
            [mainEndConstraints addObjectsFromArray:mc2];
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
-(void)_updateRightStartConstraints{
    [self _clearRightConstraints];
    [rightStartConstraints removeAllObjects];
    CGFloat rightWidth = [[RootSplitBuff rootViewController] rightWidth];
    UIView *rightView = self.bfRightViewController.view;
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(rightView, mainView, containerView);
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
            [self.view addConstraints:mainStartConstraints];
        }
            break;
        case BuffSplitStyleScaled:{
            NSDictionary *metrics = @{@"margin" : @(-rightWidth), @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightStartConstraints addObjectsFromArray:c1];
            [rightStartConstraints addObjectsFromArray:c2];
            [self.view addConstraints:rightStartConstraints];
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
-(void)_updateRightEndConstraints{
    [self _clearRightConstraints];
    [rightEndConstraints removeAllObjects];
    [mainEndConstraints removeAllObjects];
    CGFloat rightWidth = [[RootSplitBuff rootViewController] rightWidth];
    UIView *rightView = self.bfRightViewController.view;
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(rightView, mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
        {
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            
            NSDictionary *metrics1 = @{@"margin" : @(_mainEndOffsetForRight)};
            NSArray *mc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-margin-|" options:ops metrics:metrics1 views:bindings];
            NSArray *mc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics1 views:bindings];
            [mainEndConstraints addObjectsFromArray:mc1];
            [mainEndConstraints addObjectsFromArray:mc2];
            
            [self.view addConstraints:rightEndConstraints];
            [self.view addConstraints:mainEndConstraints];
        }
            break;
        case BuffSplitStyleScaled:{
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            
            NSArray *mc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-rightWidth-|" options:ops metrics:metrics views:bindings];
            NSArray *mc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainEndConstraints addObjectsFromArray:mc1];
            [mainEndConstraints addObjectsFromArray:mc2];
            
            [self.view addConstraints:rightEndConstraints];
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
-(void)_clearLeftConstraints{
    [self.view removeConstraints:leftStartConstraints];
    [self.view removeConstraints:leftEndConstraints];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
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
-(void)_scaleMainViewForLeftAt:(CGFloat)ratio{
        self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
        CATransform3D transform=CATransform3DIdentity;
        CGFloat s=self.mainScale;
        transform=CATransform3DScale(transform, 1-(1-s)*ratio, 1-(1-s)*ratio, 1);
        CGFloat tX=(self.leftWidth-(1-s)*self.bfMainViewController.view.width)*1/s;
        transform=CATransform3DTranslate(transform,tX*ratio , 0, 0);
        self.bfMainViewController.view.layer.transform=transform;
}
-(void)_restoreMainViewForLeftAt:(CGFloat)ratio{
    CATransform3D transform=CATransform3DIdentity;

    CGFloat s=self.mainScale+ratio*(1-self.mainScale);

    transform=CATransform3DScale(transform, s, s, 1);
    CGFloat tX=-(1/self.mainScale)*(1-self.mainScale)*self.bfMainViewController.view.width/2;
    transform=CATransform3DTranslate(transform,tX-tX*ratio , 0, 0);
    self.bfMainViewController.view.layer.transform=transform;
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
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    [leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addDimButton];
    [containerView addSubview:leftView];
    
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi>li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            [self _updateLeftStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateLeftEndConstraints];
            //执行动画
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
            [self _updateLeftStartConstraints];
            
            [containerView layoutIfNeeded];
            [self _updateLeftStartConstraints];
            [self _scaleMainViewForLeftAt:0];

            [containerView layoutIfNeeded];

            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [containerView layoutIfNeeded];
                [self _scaleMainViewForLeftAt:1];
            }                completion:^(BOOL finished) {
                [self setIsLeftShowing:YES];
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
-(void)hideLeftViewController{
    if (!leftStartConstraints) {
        leftStartConstraints=[NSMutableArray array];
    }
    if (!leftEndConstraints) {
        leftEndConstraints=[NSMutableArray array];
    }
    NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView=self.view;
    [leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [containerView removeConstraints:leftEndConstraints];
            [self _updateLeftStartConstraints];
            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:0];
                
            }                completion:^(BOOL finished) {
                [_dimView removeFromSuperview];
                [leftView removeFromSuperview];
                [self setIsLeftShowing:NO];
            }];
        }
            break;
        case BuffSplitStyleScaled:{
            [containerView removeConstraints:leftEndConstraints];
            [self _updateLeftStartConstraints];
            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:0];
                [self _restoreMainViewForLeftAt:1];
                
            }                completion:^(BOOL finished) {
                [_dimView removeFromSuperview];
                [leftView removeFromSuperview];
                [self setIsLeftShowing:NO];
                [self _restoreMainViewForLeftAt:1];

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
    [rightView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addDimButton];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [containerView addSubview:rightView];
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateRightEndConstraints];
            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                
            }                completion:^(BOOL finished) {
                [self setIsRightShowing:YES];
            }];
        }
            break;
        case BuffSplitStyleScaled:{
            [containerView addSubview:rightView];
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateRightEndConstraints];
            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [self _scaleMainViewForRightAt:1];
                
            }                completion:^(BOOL finished) {
                [self setIsRightShowing:YES];
                [self _scaleMainViewForRightAt:1];
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
            //执行动画
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
            [containerView removeConstraints:rightEndConstraints];
            [self _updateRightStartConstraints];
            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:0];
                [self _restoreMainViewForRightAt:1];
                
            }                completion:^(BOOL finished) {
                [_dimView removeFromSuperview];
                [rightView removeFromSuperview];
                [self setIsRightShowing:NO];
                [self _restoreMainViewForRightAt:1];
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
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    return YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}
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
            [self.view addSubview:self.bfLeftViewController.view];
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
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfLeftViewController.view setFrame:CGRectMake(-self.leftWidth, 0, self.leftWidth, self.view.height)];
            [self.view addSubview:self.bfLeftViewController.view];
            NSInteger li=[self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi=[self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi<li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
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
    [self.delegate rootSplitBuffWillPushInLeftSplitView];
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
            [self.bfMainViewController.view setFrame:CGRectMake(percent*_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
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
    [self.delegate rootSplitBuffPushingInLeftSplitView:percent];
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
                    [self _completeLeftConstraints];

                    
                }];

            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
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
                    [self _completeLeftConstraints];
                    [self _scaleMainViewForLeftAt:1];
                }];
                
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    [self _restoreMainViewForLeftAt:1];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self _restoreMainViewForLeftAt:1];
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
    [self.delegate rootSplitBuffEndPushingInLeftSplitViewAt:percent];

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
            [self.view addSubview:self.bfRightViewController.view];

        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffWillPushInRightSplitView];
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
             [self.bfMainViewController.view setFrame:CGRectMake(-percent*_mainEndOffsetForRight, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffPushingInRightSplitView:percent];
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
                    [self.bfMainViewController.view setFrame:CGRectMake(-_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth-_rightWidth, 0, self.rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self _completeRightConstraints];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setFrame:CGRectMake(0, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth, 0, self.rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                }];
                
            }
        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffEndPushingInLeftSplitViewAt:percent];
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
        }
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffWillPushOutLeftSplitView];
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
            [self.bfMainViewController.view setFrame:CGRectMake(_mainEndOffsetForLeft-percent*_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];

        }
            break;
        case BuffSplitStyleScaled:{
            [self.bfLeftViewController.view setFrame:CGRectMake(-scaledDiffX, 0, _leftWidth, self.bfLeftViewController.view.height)];
            self.bfMainViewController.view.layer.transform=CATransform3DIdentity;
            CATransform3D transform=CATransform3DIdentity;
            CGFloat s=self.mainScale+(1-self.mainScale)*percent;
            CGFloat tX=scaledDiffX*1/s+(1/s)*self.bfMainViewController.view.width*(1-s)/2;
            transform=CATransform3DScale(transform, s, s, 1);
            transform=CATransform3DTranslate(transform,-tX, 0, 0);
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
    [self.delegate rootSplitBuffPushingOutLeftSplitView:percent];
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
                    [self.bfMainViewController.view setFrame:CGRectMake(_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];

                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self _completeLeftConstraints];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setFrame:CGRectMake(0, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];

                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled:{
            if (percent<BF_PERCENTAGE_SHOW_LEFT) {
                CATransform3D transform=CATransform3DIdentity;
                
                CGFloat s=self.mainScale+(1-self.mainScale)*percent;
                CGFloat tX=scaledDiffX*1/s-(1/s)*self.bfMainViewController.view.width*(1-s);
//                CGFloat tX=-(1/s)*self.bfMainViewController.view.width*(1-s)/2-scaledDiffX;
                transform=CATransform3DScale(transform, s, s, 1);

                transform=CATransform3DTranslate(transform,tX , 0, 0);
                self.bfMainViewController.view.layer.transform=transform;
                
//                [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//                [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//                [self _updateLeftEndConstraints];
                transform=CATransform3DIdentity;
               transform= CATransform3DScale(transform, self.mainScale, self.mainScale, 1);
                tX= -(1/s)*self.bfMainViewController.view.width*(1-s)/2;
                transform=CATransform3DTranslate(transform,tX , 0, 0);


                [UIView animateWithDuration:2+(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    self.bfMainViewController.view.layer.transform=transform;
                    [self.view layoutIfNeeded];

                } completion:^(BOOL finished) {
                    [self _completeLeftConstraints];
                    [self setIsLeftShowing:YES];
                    [self _scaleMainViewForLeftAt:1];
                }];
                
            }
            
            else {
                CATransform3D transform=CATransform3DIdentity;
                CGFloat s=self.mainScale+(1-self.mainScale)*1;
                CGFloat tX=_leftWidth*1/s+(1/s)*self.bfMainViewController.view.width*(1-s)/2;
                transform=CATransform3DScale(transform, s, s, 1);
                transform=CATransform3DTranslate(transform,-tX, 0, 0);
                [UIView animateWithDuration:2+(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    self.bfMainViewController.view.layer.transform=transform;

                } completion:^(BOOL finished) {
                    [self _updateLeftStartConstraints];
                    [self setIsLeftShowing:NO];
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
    [self.delegate rootSplitBuffEndPushingOutLeftSplitViewAt:percent];
}
-(void)dimPanForRightBegin:(UIPanGestureRecognizer *)gesture{
    beginPoint=[gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffWillPushOutRightSplitView];
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
            [self.bfMainViewController.view setFrame:CGRectMake(percent*_mainEndOffsetForLeft-_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];

        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffPushingOutRightSplitView:percent];
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
                    [self.bfMainViewController.view setFrame:CGRectMake(-_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];

                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self _completeRightConstraints];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(currentWidth, 0, self.rightWidth, self.view.height)];
                    [self.bfMainViewController.view setFrame:CGRectMake(0, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        case BuffSplitStyleCustom:
            
            break;
        default:
            break;
    }
    [self.delegate rootSplitBuffEndPushingOutRightSplitViewAt:percent];
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
