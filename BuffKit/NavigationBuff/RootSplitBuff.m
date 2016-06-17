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
    self.bfLeftPan.enabled=!(_isLeftShowing||_isRightShowing);
}
-(void)setIsRightShowing:(BOOL)isRightShowing
{
    _isRightShowing=isRightShowing;
    self.bfRightPan.enabled=!(_isLeftShowing||_isRightShowing);

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
-(NSMutableArray *)_updateMainStartConstraintsForLeft{
    if (mainStartConstraints) {
        [mainStartConstraints removeAllObjects];
    }
    else{
        mainStartConstraints = [NSMutableArray array];
    }
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
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
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
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
        case BuffSplitStylePushed:
            
            break;
        case BuffSplitStyleScaled:
            
            break;
        case BuffSplitStylePerspective:
            
            break;
        default:
            break;
    }
    return mainEndConstraints;
}
-(NSMutableArray *)_updateLeftStartConstraints{
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
            NSDictionary *metrics1 = @{@"margin" : @(-leftWidth), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics1 views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics1 views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
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
    return leftStartConstraints;
}
-(NSMutableArray *)_updateLeftEndConstraints{
    if (leftEndConstraints) {
        [leftEndConstraints removeAllObjects];
    }
    else{
        leftEndConstraints = [NSMutableArray array];
    }
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
    return leftEndConstraints;
}
-(NSMutableArray *)_updateRightStartConstraints{
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
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
    return rightStartConstraints;
}
-(NSMutableArray *)_updateRightEndConstraints{
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered:
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
    return rightEndConstraints;
}
-(void)_clearLeftConstraints{
    [self.view removeConstraints:leftStartConstraints];
    [self.view removeConstraints:leftEndConstraints];
    [self.view removeConstraints:mainStartConstraints];
    [self.view removeConstraints:mainEndConstraints];
}
-(void)_clearRightCOnstraints{
    
}
-(void)_completeLeftConstraints{
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[self _updateLeftEndConstraints]];
    [self.view layoutIfNeeded];
}
#pragma mark Public method
-(void)showLeftViewController{
    if (!leftStartConstraints) {
        leftStartConstraints=[NSMutableArray array];
    }
    if (!leftEndConstraints) {
        leftEndConstraints=[NSMutableArray array];
    }
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
            [self _clearLeftConstraints];
            [containerView addConstraints:[self _updateLeftStartConstraints]];
            [containerView layoutIfNeeded];
            [containerView removeConstraints:leftStartConstraints];
            [containerView addConstraints:[self _updateLeftEndConstraints]];
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
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [containerView removeConstraints:leftEndConstraints];
            [containerView addConstraints:[self _updateLeftStartConstraints]];
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
    diffX = diffX<0?0:diffX;
    NSLog(@"%f",p.x);
    CGFloat percent=fabs(diffX*BF_SCALE_PAN/self.leftWidth);
    percent=percent>1?1:percent;
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
    diffX = diffX<0?0:diffX;
    NSLog(@"%f",p.x);
    CGFloat percent=fabs(diffX*BF_SCALE_PAN/self.leftWidth);
    percent=percent>1?1:percent;

    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent>BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self _clearLeftConstraints];
                    [self _completeLeftConstraints];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self removeDim];
                    [self.bfLeftViewController.view removeFromSuperview];
                }];
                
            }
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
                [self dimPanForRightEnd:gesture];
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
-(void)dimPanForLeftChanged:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX>0?0:diffX;
    CGFloat percent=fabs(diffX*BF_SCALE_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    CGFloat scaledDiffX=percent*self.leftWidth;
    [_dimView setAlpha:self.dimOpacity*(1-percent)];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSLog(@"%f",p.x);
            [self.bfLeftViewController.view setFrame:CGRectMake(-scaledDiffX, 0, _leftWidth, self.bfLeftViewController.view.height)];
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
-(void)dimPanForLeftEnd:(UIPanGestureRecognizer *)gesture{
    CGPoint p=[gesture locationInView:self.view];
    CGFloat diffX=p.x-beginPoint.x;
    diffX = diffX>0?0:diffX;
    NSLog(@"%f",diffX);
    CGFloat percent=fabs(diffX*BF_SCALE_PAN/self.leftWidth);
    percent=percent>1?1:percent;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent<BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:percent*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self _clearLeftConstraints];
                    [self _completeLeftConstraints];
                    
                }];
            }
            else {
                [UIView animateWithDuration:(1-percent)*self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, self.leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self removeDim];
                    [self.bfLeftViewController.view removeFromSuperview];
                }];
            }
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
-(void)dimPanForRightBegin:(UIPanGestureRecognizer *)gesture{
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
-(void)dimPanForRightChanged:(UIPanGestureRecognizer *)gesture{
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
-(void)dimPanForRightEnd:(UIPanGestureRecognizer *)gesture{
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
