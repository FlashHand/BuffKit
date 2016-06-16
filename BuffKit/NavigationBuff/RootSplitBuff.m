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
#pragma mark - Initial configuration
-(void)applyDefault
{
    self.splitStyle=BuffSplitStyleCovered;
    self.dimColor=[UIColor lightGrayColor];
    self.dimOpacity=0.5;
    self.mainViewScale=0.8;
    self.leftWidth=200;
    self.rightWidth=200;
    self.leftAnimationDuration=0.3;
    self.rightAnimationDuration=0.3;
    //默认边缘滑动
    self.bfLeftPan=[[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanAction:)];
    ((UIScreenEdgePanGestureRecognizer *)(self.bfLeftPan)).edges=UIRectEdgeLeft;
    self.bfRightPan=[[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(rightPanAction:)];
    ((UIScreenEdgePanGestureRecognizer *)(self.bfRightPan)).edges=UIRectEdgeRight;
    [self.view addGestureRecognizer:_bfLeftPan];
    [self.view addGestureRecognizer:_bfRightPan];
    [_bfLeftPan setDelegate:self];
    [_bfRightPan setDelegate:self];
    [_bfLeftPan setEnabled:NO];
    [_bfRightPan setEnabled:NO];
}
-(void)applyLayout
{
    BOOL isStatusBarHidden=[UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication]setStatusBarHidden:!isStatusBarHidden];
    [[UIApplication sharedApplication]setStatusBarHidden:isStatusBarHidden];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.rootBackgroundImageView=[[UIImageView alloc]init];
    
}
#pragma mark - properties' access
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
    [self.bfMainViewController.view.layer setShadowColor:[UIColor whiteColor].CGColor];
    [self.bfMainViewController.view.layer setShadowOffset:CGSizeZero];
    [self.bfMainViewController.view.layer setShadowRadius:4.0];
    [self.bfMainViewController.view.layer setShadowOpacity:0.8];
    UIBezierPath *shadowPath=[UIBezierPath bezierPathWithRect:self.view.bounds]; 
    [self.bfMainViewController.view.layer setShadowPath:shadowPath.CGPath];
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
-(UIViewController *)bfRightViewController
{
    if (!_bfRightViewController) {
        _bfRightViewController=[[UIViewController alloc]init];
        [_bfRightViewController.view setBackgroundColor:[UIColor clearColor]];
    }
    return _bfRightViewController;
}
-(void)setRootBackgroundImage:(UIImage *)rootBackgroundImage
{
    _rootBackgroundImage=rootBackgroundImage;
}
-(void)setIsLeftShowing:(BOOL)isLeftShowing
{
    _isLeftShowing=isLeftShowing;
    leftPanGesture.enabled=!(_isLeftShowing||_isRightShowing);
}
-(void)setIsRightShowing:(BOOL)isRightShowing
{
    _isRightShowing=isRightShowing;
    rightPanGesture.enabled=!(_isLeftShowing||_isRightShowing);

}
#pragma mark AutoLayout
-(void)completeLeftConstraints{
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *leftView=self.bfLeftViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    [containerView removeConstraints:leftStartConstraints];
    [containerView removeConstraints:leftEndConstraints];
    [containerView addConstraints:leftEndConstraints];
}

#pragma mark Private method
-(void)setMainViewConstraints{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}
-(void)showMainViewController{
    
}
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
-(void)removeDim{
    [self.dimView removeFromSuperview];
}
#pragma mark Public method
-(void)showLeftViewController{
    NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView=self.view;
    [leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addDimButton];
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [containerView addSubview:leftView];
            //mainView约束
            mainViewStartConstraints = [NSMutableArray array];
            NSDictionary *fmetrics1 = @{@"margin" : @0};
            NSArray *fc1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:fmetrics1 views:bindings];
            NSArray *fc2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:fmetrics1 views:bindings];
            [mainViewStartConstraints addObjectsFromArray:fc1];
            [mainViewStartConstraints addObjectsFromArray:fc2];
            //leftView起始约束
            leftStartConstraints = [NSMutableArray array];
            NSDictionary *metrics1 = @{@"margin" : @(-leftWidth), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics1 views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics1 views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
            [containerView addConstraints:leftStartConstraints];
            [containerView layoutIfNeeded];
            [containerView removeConstraints:leftStartConstraints];
            //leftView结束约束
            leftEndConstraints = [NSMutableArray array];
            NSDictionary *metrics2 = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *ec1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics2 views:bindings];
            NSArray *ec2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics2 views:bindings];
            [leftEndConstraints addObjectsFromArray:ec1];
            [leftEndConstraints addObjectsFromArray:ec2];
            [containerView addConstraints:leftEndConstraints];
            //执行动画
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                
            }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
            }];
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)hideLeftViewController{
    NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView=self.view;
    [leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [containerView removeConstraints:leftEndConstraints];
            [containerView addConstraints:leftStartConstraints];
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
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)showRightViewController{
    [self presentViewController:self.bfRightViewController animated:YES completion:nil];
}
-(void)hideRightViewController{
    [self.bfRightViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)activeLeftPanGestureOnEdge:(BOOL)onEdge{
    [self.view removeGestureRecognizer:self.bfLeftPan];
    if (onEdge) {
        self.bfLeftPan=[[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanAction:)];
        ((UIScreenEdgePanGestureRecognizer *)(self.bfLeftPan)).edges=UIRectEdgeLeft;
        [self.view addGestureRecognizer:_bfLeftPan];
        [_bfLeftPan setDelegate:self];
    }
    else{
        self.bfLeftPan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanAction:)];
        [self.view addGestureRecognizer:_bfLeftPan];
        [_bfLeftPan setDelegate:self];
    }
    [self.bfLeftPan setEnabled:YES];
}
-(void)deactiveLeftPanGesture{
    [self.bfLeftPan setEnabled:NO];
}
-(void)activeRightPanGestureOnEdge:(BOOL)onEdge{
    [self.view removeGestureRecognizer:self.bfRightPan];
    if (onEdge) {
        self.bfRightPan=[[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanAction:)];
        ((UIScreenEdgePanGestureRecognizer *)(self.bfRightPan)).edges=UIRectEdgeRight;
        [self.view addGestureRecognizer:_bfRightPan];
        [_bfLeftPan setDelegate:self];
    }
    else{
        
    }
    [self.bfRightPan setEnabled:YES];
}
-(void)deactiveRightPanGesture{
    [self.bfRightPan setEnabled:NO];
}
#pragma mark - Gesture Action
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
            [self.bfLeftViewController.view setFrame:CGRectMake(-self.leftWidth, 0, self.leftWidth, self.view.height)];
            [self.view addSubview:self.bfLeftViewController.view];
            
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)leftPanGestureChanged:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    if (diffX<0) diffX=0;
    NSLog(@"%f",p.x);
    CGFloat percent=fabs(diffX*1.2/self.leftWidth);
    if (percent>1) percent=1;
    CGFloat scaledDiffX=percent*self.leftWidth;
    [_dimView setAlpha:self.dimOpacity*percent];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setFrame:CGRectMake(scaledDiffX-self.leftWidth, 0, self.leftWidth, self.view.height)];
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)leftPanGestureEnd:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    if (diffX<0) diffX=0;
    NSLog(@"%f",p.x);
    CGFloat percent=fabs(diffX*1.2/self.leftWidth);
    if (percent>0.5) {
        if (percent>1) percent=1;
        [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
            [_dimView setAlpha:self.dimOpacity];
        } completion:^(BOOL finished) {
            
        }];
    }
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
        
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}

-(void)rightPanAction:(UIPanGestureRecognizer *)gesture{
    beginPoint=[gesture locationInView:self.view];
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
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)rightPanGestureChanged:(UIPanGestureRecognizer *)gesture{
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)rightPanGestureEnd:(UIPanGestureRecognizer *)gesture{
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
        }
            break;
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
}
-(void)dimPanAction:(UIPanGestureRecognizer *)gesture{
    beginPoint=[gesture locationInView:self.view];
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
