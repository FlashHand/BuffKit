//
//  RootSplitBuff.m
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "RootSplitBuff.h"
#import "FrameBuff.h"
#import <objc/runtime.h>

@interface BFRootViewController () {
    BOOL _shouldLeftPanActive;
    BOOL _shouldRightPanActive;
}
@end

CGSize _bfGetSizeForSplitView(UIView *rootView, CGFloat angle) {
    CGSize splitSize;
    CGFloat d = BF_EYE_DISTANCE_PERSPECTIVE;
    CGFloat w = rootView.width;
    CGFloat t1 = w * rootView.width * sin(angle);
    CGFloat t2 = (d - d * cos(angle)) * w;
    CGFloat leftW = (t1 + t2) / (d + w * sin(angle));
    CGFloat leftH = (w * d) / (d + w * sin(angle));
    splitSize = CGSizeMake(leftW, leftH);
    return splitSize;
}

static BFRootViewController *rootViewController = nil;

@implementation BFRootViewController
@synthesize bfMainViewController = _bfMainViewController;
@synthesize bfLeftViewController = _bfLeftViewController;
@synthesize bfRightViewController = _bfRightViewController;
@synthesize dimView = _dimView;
@synthesize leftDelegate;
@synthesize rightDelegate;

+ (BFRootViewController *)sharedController {
    @synchronized (self) {
        if (!rootViewController) {
            rootViewController = [[super allocWithZone:NULL] init];
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
    _isRootViewContollerShowing = YES;
    self.rootBackgroundImageView = [[UIImageView alloc] init];
    [self.rootBackgroundImageView setUserInteractionEnabled:YES];
    [self.rootBackgroundImageView setBackgroundColor:[UIColor whiteColor]];
    [self.rootBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.rootBackgroundImageView];
    UIView *containerView = self.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(_rootBackgroundImageView, containerView);
    NSDictionary *metrics = @{@"margin" : @0};
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSMutableArray *constraints = [NSMutableArray array];
    NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_rootBackgroundImageView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_rootBackgroundImageView(==containerView)]" options:ops metrics:metrics views:bindings];
    [constraints addObjectsFromArray:c1];
    [constraints addObjectsFromArray:c2];
    [self.rootBackgroundImageView setImage:self.rootBackgroundPortraitImage];
    [self.view addConstraints:constraints];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isRootViewContollerShowing = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isRootViewContollerShowing = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.view.width > self.view.height) {
        [self.rootBackgroundImageView setImage:self.rootBackgroundLandscapeImage];
    }
    else {
        [self.rootBackgroundImageView setImage:self.rootBackgroundPortraitImage];
    }
    if ((self.splitStyle == BuffSplitStyleScaled) && self.isLeftShowing) {

        [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
        [self.view layoutIfNeeded];
        self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
        CATransform3D transform = CATransform3DIdentity;
        CGFloat s = self.mainScale;
        transform = CATransform3DScale(transform, s, s, 1);
        CGFloat tX = (_leftWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
        transform = CATransform3DTranslate(transform, tX, 0, 0);
        self.bfMainViewController.view.layer.transform = transform;
    }
    else if ((self.splitStyle == BuffSplitStyleScaled) && self.isRightShowing) {
        [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
        [self.view layoutIfNeeded];
        self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
        CATransform3D transform = CATransform3DIdentity;
        CGFloat s = self.mainScale;
        transform = CATransform3DScale(transform, s, s, 1);
        CGFloat tX = (_leftWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
        transform = CATransform3DTranslate(transform, -tX, 0, 0);
        self.bfMainViewController.view.layer.transform = transform;
    }
    else if ((self.splitStyle == BuffSplitStylePerspective) && self.isLeftShowing) {
        CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
        _leftWidth = leftSize.width;
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
        transform = CATransform3DRotate(transform, -self.mainRotateAngle, 0, 1, 0);
        [self _updateLeftEndConstraints];
        [self.rootBackgroundImageView layoutIfNeeded];
        [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
        [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
        [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
        self.bfMainViewController.view.layer.transform = transform;
        [self.bfMainViewController.view.layer setShouldRasterize:YES];
        [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
    }
    else if ((self.splitStyle == BuffSplitStylePerspective) && self.isRightShowing) {
        CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
        _rightWidth = rightSize.width;
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
        transform = CATransform3DRotate(transform, self.mainRotateAngle, 0, 1, 0);
        [self _updateRightEndConstraints];
        [self.rootBackgroundImageView layoutIfNeeded];
        [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
        [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
        [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
        self.bfMainViewController.view.layer.transform = transform;
        [self.bfMainViewController.view.layer setShouldRasterize:YES];
        [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
    }
}

#pragma mark - Initial configuration

- (void)applyDefault {
    _splitStyle = BuffSplitStyleCovered;
    _dimColor = [UIColor lightGrayColor];
    _dimOpacity = 0.5;
    _leftWidth = 200;
    _rightWidth = 200;
    _leftAnimationDuration = 0.3;
    _rightAnimationDuration = 0.3;
    _mainEndOffsetForLeft = 0;
    _mainEndOffsetForRight = 0;
    _mainScale = 0.8;
    _mainRotateAngle = 1;
    _shouldLeftStill = NO;
    _shouldRightStill = NO;
    mainStartConstraints = [NSMutableArray array];
    mainEndConstraints = [NSMutableArray array];
    leftStartConstraints = [NSMutableArray array];
    leftEndConstraints = [NSMutableArray array];
    rightStartConstraints = [NSMutableArray array];
    rightEndConstraints = [NSMutableArray array];
}

- (void)applyLayout {
    BOOL isStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:!isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:isStatusBarHidden];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

#pragma mark - properties' access

- (void)setBfMainViewController:(UIViewController *)bfMainViewController {
    [_bfMainViewController.view removeFromSuperview];
    [self.rootBackgroundImageView addConstraints:mainStartConstraints];
    _bfMainViewController = bfMainViewController;
    //AutoLayout
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView addSubview:self.bfMainViewController.view];
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin" : @0};
    NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    [mainStartConstraints removeAllObjects];
    [mainStartConstraints addObjectsFromArray:c1];
    [mainStartConstraints addObjectsFromArray:c2];
    [self.rootBackgroundImageView addConstraints:mainStartConstraints];
    if (!_bfLeftPan) {
        _bfLeftPan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanAction:)];
        self.bfLeftPan.edges = UIRectEdgeLeft;
        [self.bfLeftPan setDelegate:self];
        [self.bfLeftPan setEnabled:NO];
        [self.view addGestureRecognizer:self.bfLeftPan];
    }
    if (!_bfRightPan) {
        _bfRightPan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanAction:)];
        self.bfRightPan.edges = UIRectEdgeRight;
        [self.bfRightPan setDelegate:self];
        [self.bfRightPan setEnabled:NO];
        [self.view addGestureRecognizer:_bfRightPan];
    }
}

- (void)setBfLeftViewController:(UIViewController *)bfLeftViewController {
    [_bfLeftViewController.view removeFromSuperview];
    _bfLeftViewController = bfLeftViewController;
}

- (UIViewController *)bfLeftViewController {
    if (!_bfLeftViewController) {
        _bfLeftViewController = [[UIViewController alloc] init];
        [_bfLeftViewController.view setBackgroundColor:[UIColor clearColor]];
    }
    return _bfLeftViewController;
}

- (void)setBfRightViewController:(UIViewController *)bfRightViewController {
    [_bfRightViewController.view removeFromSuperview];
    _bfRightViewController = bfRightViewController;
}

- (UIViewController *)bfRightViewController {
    if (!_bfRightViewController) {
        _bfRightViewController = [[UIViewController alloc] init];
        [_bfRightViewController.view setBackgroundColor:[UIColor clearColor]];
    }
    return _bfRightViewController;
}

- (void)setRootBackgroundPortraitImage:(UIImage *)rootBackgroundPortraitImage {
    _rootBackgroundPortraitImage = rootBackgroundPortraitImage;
    [self.rootBackgroundImageView setImage:rootBackgroundPortraitImage];
}

- (void)setRootBackgroundLandscapeImage:(UIImage *)rootBackgroundLandscapeImage {
    _rootBackgroundLandscapeImage = rootBackgroundLandscapeImage;
    [self.rootBackgroundImageView setImage:rootBackgroundLandscapeImage];
}

- (void)setIsLeftShowing:(BOOL)isLeftShowing {
    _isLeftShowing = isLeftShowing;
    self.bfLeftPan.enabled = !(_isLeftShowing || _isRightShowing);
    self.bfRightPan.enabled = !(_isLeftShowing || _isRightShowing);
    if (!isLeftShowing) {
        [self.bfLeftViewController.view removeFromSuperview];
        [self.dimView removeFromSuperview];
    }
}

- (void)setIsRightShowing:(BOOL)isRightShowing {
    _isRightShowing = isRightShowing;
    self.bfLeftPan.enabled = !(_isLeftShowing || _isRightShowing);
    self.bfRightPan.enabled = !(_isLeftShowing || _isRightShowing);
    if (!isRightShowing) {
        [self.bfRightViewController.view removeFromSuperview];
        [self.dimView removeFromSuperview];
    }
}

#pragma mark Private method

- (void)addDimButton {
    [_dimView removeFromSuperview];
    _dimView = [[UIButton alloc] init];
    [_dimView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dimView setBackgroundColor:[RootSplitBuff rootViewController].dimColor];
    UIPanGestureRecognizer *dimPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dimPanAction:)];;
    UITapGestureRecognizer *dimTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimTapAction:)];
    [_dimView addGestureRecognizer:dimPan];
    [_dimView addGestureRecognizer:dimTap];
    [dimPan setDelegate:self];
    [dimTap setDelegate:self];
    [self.bfMainViewController.view addSubview:_dimView];
    UIView *mainView = self.bfMainViewController.view;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView, _dimView);
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

- (void)_updateMainStartConstraintsForLeft {
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:mainStartConstraints];
    [self.rootBackgroundImageView removeConstraints:mainEndConstraints];
    [self.rootBackgroundImageView addConstraints:mainStartConstraints];
}

- (void)_updateMainEndConstraintsForLeft {
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:mainStartConstraints];
    [self.rootBackgroundImageView removeConstraints:mainEndConstraints];
    [mainEndConstraints removeAllObjects];
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSDictionary *metrics = @{@"margin" : @(_mainEndOffsetForLeft)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:mainEndConstraints];
        }
            break;
        case BuffSplitStyleScaled: {
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            [mainStartConstraints addObjectsFromArray:c1];
            [mainStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:mainStartConstraints];

        }
            break;
        case BuffSplitStylePerspective: {
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            [mainStartConstraints addObjectsFromArray:c1];
            [mainStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:mainStartConstraints];

        }

            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
}

- (void)_updateMainStartConstraintsForRight {
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:mainStartConstraints];
    [self.rootBackgroundImageView removeConstraints:mainEndConstraints];
    [self.rootBackgroundImageView addConstraints:mainStartConstraints];
}

- (void)_updateMainEndConstraintsForRight {
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:mainStartConstraints];
    [self.rootBackgroundImageView removeConstraints:mainEndConstraints];
    [mainEndConstraints removeAllObjects];
    UIView *mainView = self.bfMainViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(mainView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSDictionary *metrics = @{@"margin" : @(_mainEndOffsetForRight)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:mainEndConstraints];
        }
            break;
        case BuffSplitStyleScaled: {
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-0-|" options:ops metrics:nil views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:mainEndConstraints];
        }

            break;
        case BuffSplitStylePerspective: {
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[mainView(==containerView)]-0-|" options:ops metrics:nil views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainView(==containerView)]" options:ops metrics:nil views:bindings];
            [mainEndConstraints addObjectsFromArray:c1];
            [mainEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:mainEndConstraints];
        }

            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
}

- (void)_updateLeftStartConstraints {
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:leftStartConstraints];
    [self.rootBackgroundImageView removeConstraints:leftEndConstraints];
    [leftStartConstraints removeAllObjects];
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSDictionary *metrics = @{@"margin" : @(-leftWidth), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:leftStartConstraints];
        }
            break;
        case BuffSplitStyleScaled: {
            CGFloat startX = _shouldLeftStill ? 0 : -_leftWidth;
            NSDictionary *metrics = @{@"margin" : @(startX), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:leftStartConstraints];
        }
            break;
        case BuffSplitStylePerspective: {
            CGFloat startX = _shouldLeftStill ? 0 : -_leftWidth;
            NSDictionary *metrics = @{@"margin" : @(startX), @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftStartConstraints addObjectsFromArray:c1];
            [leftStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:leftStartConstraints];
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
}

- (void)_updateLeftEndConstraints {
    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:leftStartConstraints];
    [self.rootBackgroundImageView removeConstraints:leftEndConstraints];
    [leftEndConstraints removeAllObjects];
    CGFloat leftWidth = [[RootSplitBuff rootViewController] leftWidth];
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(leftView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSDictionary *metrics = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftEndConstraints addObjectsFromArray:c1];
            [leftEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:leftEndConstraints];
        }
            break;
        case BuffSplitStyleScaled: {
            NSDictionary *metrics = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftEndConstraints addObjectsFromArray:c1];
            [leftEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:leftEndConstraints];
        }
            break;
        case BuffSplitStylePerspective: {
            NSDictionary *metrics = @{@"margin" : @0, @"leftWidth" : @(leftWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[leftView(leftWidth)]" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[leftView(==containerView)]" options:ops metrics:metrics views:bindings];
            [leftEndConstraints addObjectsFromArray:c1];
            [leftEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:leftEndConstraints];
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
}

- (void)_updateRightStartConstraints {
    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:rightStartConstraints];
    [self.rootBackgroundImageView removeConstraints:rightEndConstraints];
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(rightView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSDictionary *metrics = @{@"margin" : @(-_rightWidth), @"rightWidth" : @(_rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightStartConstraints addObjectsFromArray:c1];
            [rightStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:rightStartConstraints];
        }
            break;
        case BuffSplitStyleScaled: {
            CGFloat startX = _shouldRightStill ? 0 : -_rightWidth;
            NSDictionary *metrics = @{@"margin" : @(startX), @"rightWidth" : @(_rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightStartConstraints addObjectsFromArray:c1];
            [rightStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:rightStartConstraints];
        }
            break;
        case BuffSplitStylePerspective: {
            CGFloat startX = _shouldRightStill ? 0 : -_rightWidth;
            NSDictionary *metrics = @{@"margin" : @(startX), @"rightWidth" : @(_rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightStartConstraints addObjectsFromArray:c1];
            [rightStartConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:rightStartConstraints];
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
}

- (void)_updateRightEndConstraints {
    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.rootBackgroundImageView removeConstraints:rightStartConstraints];
    [self.rootBackgroundImageView removeConstraints:rightEndConstraints];
    [rightEndConstraints removeAllObjects];
    CGFloat rightWidth = [[RootSplitBuff rootViewController] rightWidth];
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(rightView, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllRight | NSLayoutFormatAlignAllTop;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:rightEndConstraints];
        }
            break;
        case BuffSplitStyleScaled: {
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:rightEndConstraints];
        }
            break;
        case BuffSplitStylePerspective: {
            NSDictionary *metrics = @{@"margin" : @0, @"rightWidth" : @(rightWidth)};
            NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightView(rightWidth)]-margin-|" options:ops metrics:metrics views:bindings];
            NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[rightView(==containerView)]" options:ops metrics:metrics views:bindings];
            [rightEndConstraints addObjectsFromArray:c1];
            [rightEndConstraints addObjectsFromArray:c2];
            [self.rootBackgroundImageView addConstraints:rightEndConstraints];
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
}

- (void)_setShouldLeftPanActive:(BOOL)shouldActive {
    _shouldLeftPanActive = shouldActive;
}

- (void)_setShouldRightPanActive:(BOOL)shouldActive {
    _shouldRightPanActive = shouldActive;
}

- (BOOL)_shouldLeftPanActive {
    return _shouldLeftPanActive;
}

- (BOOL)_shouldRightPanActive {
    return _shouldRightPanActive;
}

#pragma mark Public method

- (void)showLeftViewController {
    NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    UIView *leftView = self.bfLeftViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    [leftView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addDimButton];
    [containerView addSubview:leftView];
    [leftView.layer setZPosition:0];
    [self _updateLeftStartConstraints];
    [containerView layoutIfNeeded];
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            NSInteger li = [self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi = [self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi > li) {
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
        case BuffSplitStyleScaled: {
            [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [self _updateLeftEndConstraints];
            [self _updateMainEndConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [containerView layoutIfNeeded];
                CATransform3D transform = CATransform3DIdentity;
                CGFloat s = self.mainScale;
                transform = CATransform3DScale(transform, s, s, 1);
                CGFloat tX = (_leftWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
                transform = CATransform3DTranslate(transform, tX, 0, 0);
                self.bfMainViewController.view.layer.transform = transform;
            }                completion:^(BOOL finished) {
                [containerView layoutIfNeeded];
                [self setIsLeftShowing:YES];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                CATransform3D transform = CATransform3DIdentity;
                CGFloat s = self.mainScale;
                transform = CATransform3DScale(transform, s, s, 1);
                CGFloat tX = (_leftWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
                transform = CATransform3DTranslate(transform, tX, 0, 0);
                self.bfMainViewController.view.layer.transform = transform;
            }];
        }
            break;
        case BuffSplitStylePerspective: {
            [self.bfMainViewController.view.layer setShouldRasterize:YES];
            [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
            CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _leftWidth = leftSize.width;
            [self _updateLeftStartConstraints];
            [containerView layoutIfNeeded];
            NSInteger li = [self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi = [self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi < li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, -self.mainRotateAngle, 0, 1, 0);
            [self _updateLeftEndConstraints];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
            [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
            [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [UIView animateWithDuration:self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [containerView layoutIfNeeded];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = transform;

            }                completion:^(BOOL finished) {
                [containerView layoutIfNeeded];
                [self setIsLeftShowing:YES];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = transform;
                [self.bfMainViewController.view.layer setShouldRasterize:YES];
                [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];

            }];
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffDoPushInLeftSplitView)])
        [self.leftDelegate rootSplitBuffDoPushInLeftSplitView];
}

- (void)hideLeftViewController {
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    NSTimeInterval duration = [RootSplitBuff rootViewController].leftAnimationDuration;
    UIView *containerView = self.rootBackgroundImageView;
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self _updateLeftStartConstraints];
            [self _updateMainStartConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:0];
            }                completion:^(BOOL finished) {
                [self setIsLeftShowing:NO];
            }];
        }
            break;
        case BuffSplitStyleScaled: {
            [self _updateLeftStartConstraints];
            [self _updateMainStartConstraintsForLeft];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                [_dimView setAlpha:0];
            }                completion:^(BOOL finished) {
                [self setIsLeftShowing:NO];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
            }];
        }
            break;
        case BuffSplitStylePerspective: {
            [self.bfMainViewController.view.layer setShouldRasterize:YES];
            [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
            CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _leftWidth = leftSize.width;
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, 0, 0, 1, 0);
            [self _updateLeftStartConstraints];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
            [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
            [UIView animateWithDuration:self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:0];
                [containerView layoutIfNeeded];
                [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = transform;

            }                completion:^(BOOL finished) {
                [self setIsLeftShowing:NO];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width / 2, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                [self.bfMainViewController.view.layer setShouldRasterize:NO];
                [self _updateMainStartConstraintsForLeft];
                [containerView layoutIfNeeded];
            }];
        }

            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffDoPushOutLeftSplitView)])
        [self.leftDelegate rootSplitBuffDoPushOutLeftSplitView];
}

- (void)showRightViewController {
    NSTimeInterval duration = [RootSplitBuff rootViewController].rightAnimationDuration;
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
    [self addDimButton];
    [containerView addSubview:rightView];
    [rightView.layer setZPosition:0];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateRightEndConstraints];
            [self _updateMainEndConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
            }                completion:^(BOOL finished) {
                [self setIsRightShowing:YES];
            }];
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            [self _updateRightEndConstraints];
            [self _updateMainEndConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                CATransform3D transform = CATransform3DIdentity;
                CGFloat s = self.mainScale;
                transform = CATransform3DScale(transform, s, s, 1);
                CGFloat tX = (_rightWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
                transform = CATransform3DTranslate(transform, -tX, 0, 0);
                self.bfMainViewController.view.layer.transform = transform;
            }                completion:^(BOOL finished) {
                [self setIsRightShowing:YES];
                [containerView layoutIfNeeded];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                CATransform3D transform = CATransform3DIdentity;
                CGFloat s = self.mainScale;
                transform = CATransform3DScale(transform, s, s, 1);
                CGFloat tX = (_rightWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
                transform = CATransform3DTranslate(transform, -tX, 0, 0);
                self.bfMainViewController.view.layer.transform = transform;
            }];
        }
            break;
        case BuffSplitStylePerspective: {
            [self.bfMainViewController.view.layer setShouldRasterize:YES];
            [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
            CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _rightWidth = rightSize.width;
            [self _updateRightStartConstraints];
            [containerView layoutIfNeeded];
            NSInteger ri = [self.view.subviews indexOfObject:self.bfRightViewController.view];
            NSInteger mi = [self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi < ri) {
                [self.view exchangeSubviewAtIndex:ri withSubviewAtIndex:mi];
            }
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, self.mainRotateAngle, 0, 1, 0);
            [self _updateRightEndConstraints];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
            [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [UIView animateWithDuration:self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity];
                [containerView layoutIfNeeded];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = transform;

            }                completion:^(BOOL finished) {
                [containerView layoutIfNeeded];
                [self setIsRightShowing:YES];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = transform;
                [self.bfMainViewController.view.layer setShouldRasterize:YES];
                [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];

            }];
        }
            break;
        case BuffSplitStyleCustom:
            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffDoPushInRightSplitView)])
        [self.rightDelegate rootSplitBuffDoPushInRightSplitView];
}

- (void)hideRightViewController {
    NSTimeInterval duration = [RootSplitBuff rootViewController].rightAnimationDuration;
    UIView *rightView = self.bfRightViewController.view;
    UIView *containerView = self.rootBackgroundImageView;
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
        case BuffSplitStyleScaled: {
            [self _updateRightStartConstraints];
            [self _updateMainStartConstraintsForRight];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [containerView layoutIfNeeded];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                [_dimView setAlpha:0];
            }                completion:^(BOOL finished) {
                [self setIsRightShowing:NO];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
            }];
        }
            break;
        case BuffSplitStylePerspective: {
            [self.bfMainViewController.view.layer setShouldRasterize:YES];
            [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
            CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _rightWidth = rightSize.width;
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, 0, 0, 1, 0);
            [self _updateRightStartConstraints];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
            [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            [UIView animateWithDuration:self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_dimView setAlpha:0];
                [containerView layoutIfNeeded];
                [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = transform;

            }                completion:^(BOOL finished) {
                [self setIsRightShowing:NO];
                [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width / 2, self.view.height / 2)];
                self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                [self.bfMainViewController.view.layer setShouldRasterize:NO];
                [self _updateMainStartConstraintsForLeft];
                [containerView layoutIfNeeded];
            }];
        }
            break;
        case BuffSplitStyleCustom:
            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffDoPushOutRightSplitView)])
        [self.rightDelegate rootSplitBuffDoPushOutRightSplitView];
}

- (void)activeLeftPanGesture {
    self.bfLeftPan.enabled = YES;
}

- (void)deactiveLeftPanGesture {
    self.bfLeftPan.enabled = NO;
}

- (void)activeRightPanGesture {
    self.bfRightPan.enabled = YES;
}

- (void)deactiveRightPanGesture {
    self.bfRightPan.enabled = NO;
}

#pragma mark - Gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:self.bfLeftPan] || [gestureRecognizer isEqual:self.bfRightPan]) {
        if ([otherGestureRecognizer.delegate isKindOfClass:[UIScrollView class]]) {
            [otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
            return NO;
        }
        return NO;
    }
    //如果不进行判断dimPan会因为dimTap导致明显延迟
    if ([gestureRecognizer.view isEqual:self.dimView] && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}


#pragma mark - Gesture Action

- (void)leftPanAction:(UIPanGestureRecognizer *)gesture {
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

- (void)leftPanGestureBegin:(UIPanGestureRecognizer *)gesture {
    beginPoint = [gesture locationInView:self.view];
    [self.bfLeftViewController.view.layer setZPosition:0];
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, _leftWidth, self.view.height)];
            [self.rootBackgroundImageView addSubview:self.bfLeftViewController.view];
            NSInteger li = [self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi = [self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi > li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.rootBackgroundImageView addSubview:self.bfLeftViewController.view];
            [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
        }
            break;
        case BuffSplitStylePerspective: {
            [self.bfMainViewController.view.layer setShouldRasterize:YES];
            [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.rootBackgroundImageView addSubview:self.bfLeftViewController.view];
            CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _leftWidth = leftSize.width;
            [self.bfLeftViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            NSInteger li = [self.view.subviews indexOfObject:self.bfLeftViewController.view];
            NSInteger mi = [self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi < li) {
                [self.view exchangeSubviewAtIndex:li withSubviewAtIndex:mi];
            }
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffWillPushInLeftSplitView)])
        [self.leftDelegate rootSplitBuffWillPushInLeftSplitView];
}

- (void)leftPanGestureChanged:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX < 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _leftWidth);
    percent = percent > 1 ? 1 : percent;
    CGFloat scaledDiffX = percent * _leftWidth;
    [_dimView setAlpha:self.dimOpacity * percent];
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setFrame:CGRectMake(scaledDiffX - _leftWidth, 0, _leftWidth, self.view.height)];
            [self.bfMainViewController.view setX:percent * _mainEndOffsetForLeft];
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfLeftViewController.view setFrame:CGRectMake(_shouldLeftStill ? 0 : (scaledDiffX - _leftWidth), 0, _leftWidth, self.view.height)];
            self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
            CATransform3D transform = CATransform3DIdentity;
            CGFloat s = 1 - (1 - self.mainScale) * percent;
            CGFloat tX = (1 / s) * (scaledDiffX + (s - 1) * self.bfMainViewController.view.width / 2);
            transform = CATransform3DScale(transform, s, s, 1);
            transform = CATransform3DTranslate(transform, tX, 0, 0);
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStylePerspective: {
            CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle * percent);
            [self.bfLeftViewController.view setFrame:CGRectMake(_shouldLeftStill ? 0 : (leftSize.width - _leftWidth), 0, _leftWidth, self.view.height)];
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, -self.mainRotateAngle * percent, 0, 1, 0);
            [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity * percent];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffPushingInLeftSplitView:)])
        [self.leftDelegate rootSplitBuffPushingInLeftSplitView:percent];
}

- (void)leftPanGestureEnd:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX < 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _leftWidth);
    percent = percent > 1 ? 1 : percent;
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent > BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:(1 - percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setFrame:CGRectMake(_mainEndOffsetForLeft, 0, self.bfMainViewController.view.width, self.bfMainViewController.view.height)];
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self _updateLeftEndConstraints];
                    [self _updateMainEndConstraintsForLeft];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, _leftWidth, self.view.height)];
                    [self.bfMainViewController.view setX:0];
                    [_dimView setAlpha:0];
                }                completion:^(BOOL finished) {
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForLeft];
                    [self.view layoutIfNeeded];
                    [self setIsLeftShowing:NO];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled: {
            if (percent > BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:(1 - percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    transform = CATransform3DScale(transform, s, s, 1);
                    CGFloat tX = (1 / s) * (_leftWidth + (s - 1) * self.bfMainViewController.view.width / 2);
                    transform = CATransform3DTranslate(transform, tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self.view layoutIfNeeded];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    transform = CATransform3DScale(transform, s, s, 1);
                    CGFloat tX = (_leftWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
                    transform = CATransform3DTranslate(transform, tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                }];
            }
            else {
                [UIView animateWithDuration:(percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                }];
            }
        }
            break;
        case BuffSplitStylePerspective: {
            if (percent > BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:(1 - percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, -self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self.view layoutIfNeeded];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, -self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                    [self.bfMainViewController.view.layer setShouldRasterize:YES];
                    [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
                }];
            }
            else {
                [UIView animateWithDuration:(percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, 0, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width / 2, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.bfMainViewController.view.layer setShouldRasterize:NO];
                    [self _updateMainStartConstraintsForLeft];
                    [self.rootBackgroundImageView layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffEndPushingInLeftSplitViewAt:)])
        [self.leftDelegate rootSplitBuffEndPushingInLeftSplitViewAt:percent];
}

- (void)rightPanAction:(UIPanGestureRecognizer *)gesture {
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

- (void)rightPanGestureBegin:(UIPanGestureRecognizer *)gesture {
    beginPoint = [gesture locationInView:self.view];
    [self.bfRightViewController.view.layer setZPosition:0];
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfRightViewController.view setFrame:CGRectMake(self.view.width, 0, _rightWidth, self.view.height)];
            [self.rootBackgroundImageView addSubview:self.bfRightViewController.view];

        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.rootBackgroundImageView addSubview:self.bfRightViewController.view];
            [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
        }

            break;
        case BuffSplitStylePerspective: {
            [self.bfMainViewController.view.layer setShouldRasterize:YES];
            [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.rootBackgroundImageView addSubview:self.bfRightViewController.view];
            CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _rightWidth = rightSize.width;
            [self.bfRightViewController.view.layer setZPosition:BF_SPLITVIEW_ZPOSITION];
            NSInteger ri = [self.view.subviews indexOfObject:self.bfRightViewController.view];
            NSInteger mi = [self.view.subviews indexOfObject:self.bfMainViewController.view];
            if (mi < ri) {
                [self.view exchangeSubviewAtIndex:ri withSubviewAtIndex:mi];
            }
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffWillPushInRightSplitView)])
        [self.rightDelegate rootSplitBuffWillPushInRightSplitView];
}

- (void)rightPanGestureChanged:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX > 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _rightWidth);
    percent = percent > 1 ? 1 : percent;
    CGFloat scaledDiffX = percent * _rightWidth;
    [_dimView setAlpha:self.dimOpacity * percent];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - scaledDiffX, 0, _rightWidth, self.view.height)];
            [self.bfMainViewController.view setX:-percent * _mainEndOffsetForRight];
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width - scaledDiffX, 0, _rightWidth, self.view.height)];
            self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
            CATransform3D transform = CATransform3DIdentity;
            CGFloat s = 1 - (1 - self.mainScale) * percent;
            CGFloat tX = (1 / s) * (scaledDiffX + (s - 1) * self.bfMainViewController.view.width / 2);
            transform = CATransform3DScale(transform, s, s, 1);
            transform = CATransform3DTranslate(transform, -tX, 0, 0);
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStylePerspective: {
            CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle * percent);
            [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width - rightSize.width, 0, _rightWidth, self.view.height)];
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, self.mainRotateAngle * percent, 0, 1, 0);
            [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity * percent];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffPushingInRightSplitView:)])
        [self.rightDelegate rootSplitBuffPushingInRightSplitView:percent];
}

- (void)rightPanGestureEnd:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX > 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _rightWidth);
    percent = percent > 1 ? 1 : percent;
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent > BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:(1 - percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setX:-_mainEndOffsetForRight];
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self _updateRightEndConstraints];
                    [self _updateMainEndConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setX:0];
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];

            }
        }
            break;
        case BuffSplitStyleScaled: {
            if (percent > BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:(1 - percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    transform = CATransform3DScale(transform, s, s, 1);
                    CGFloat tX = (1 / s) * (_rightWidth + (s - 1) * self.bfMainViewController.view.width / 2);
                    transform = CATransform3DTranslate(transform, -tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self.view layoutIfNeeded];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    transform = CATransform3DScale(transform, s, s, 1);
                    CGFloat tX = (_rightWidth - (1 - s) * self.bfMainViewController.view.width / 2) * 1 / s;
                    transform = CATransform3DTranslate(transform, -tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                }];
            }
            else {
                [UIView animateWithDuration:(percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                }];
            }
        }

            break;
        case BuffSplitStylePerspective: {
            if (percent > BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:(1 - percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self.view layoutIfNeeded];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                    [self.bfMainViewController.view.layer setShouldRasterize:YES];
                    [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
                }];
            }
            else {
                [UIView animateWithDuration:(percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, 0, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width / 2, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.bfMainViewController.view.layer setShouldRasterize:NO];
                    [self _updateMainStartConstraintsForRight];
                    [self.rootBackgroundImageView layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffEndPushingInRightSplitViewAt:)])
        [self.rightDelegate rootSplitBuffEndPushingInRightSplitViewAt:percent];
}

- (void)dimPanAction:(UIPanGestureRecognizer *)gesture {
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
    else if (self.isRightShowing) {
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

- (void)dimPanForLeftBegin:(UIPanGestureRecognizer *)gesture {
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    beginPoint = [gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self _updateMainStartConstraintsForLeft];
            [self.view layoutIfNeeded];
        }
            break;
        case BuffSplitStylePerspective: {
            [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _leftWidth = leftSize.width;
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffWillPushOutLeftSplitView)])
        [self.leftDelegate rootSplitBuffWillPushOutLeftSplitView];
}

- (void)dimPanForLeftChanged:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX > 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _leftWidth);
    percent = percent > 1 ? 1 : percent;
    CGFloat scaledDiffX = percent * _leftWidth;
    [_dimView setAlpha:self.dimOpacity * (1 - percent)];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfLeftViewController.view setFrame:CGRectMake(-scaledDiffX, 0, _leftWidth, self.bfLeftViewController.view.height)];
            [self.bfMainViewController.view setX:_mainEndOffsetForLeft - percent * _mainEndOffsetForLeft];

        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfLeftViewController.view setFrame:CGRectMake(_shouldLeftStill ? 0 : -scaledDiffX, 0, _leftWidth, self.bfLeftViewController.view.height)];
            self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
            CATransform3D transform = CATransform3DIdentity;
            CGFloat s = self.mainScale + (1 - self.mainScale) * percent;
            CGFloat tX = (1 / s) * (_leftWidth - (1 - self.mainScale) * self.bfMainViewController.view.width / 2 - (_leftWidth - (1 - self.mainScale) * self.bfMainViewController.view.width / 2) * percent);
            transform = CATransform3DScale(transform, s, s, 1);
            transform = CATransform3DTranslate(transform, tX, 0, 0);
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStylePerspective: {
            CGSize leftSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle * (1 - percent));
            [self.bfLeftViewController.view setFrame:CGRectMake(_shouldLeftStill ? 0 : (leftSize.width - _leftWidth), 0, _leftWidth, self.view.height)];
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, -self.mainRotateAngle * (1 - percent), 0, 1, 0);
            [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity * (1 - percent)];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
            self.bfMainViewController.view.layer.transform = transform;
        }

            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffPushingOutLeftSplitView:)])
        [self.leftDelegate rootSplitBuffPushingOutLeftSplitView:percent];
}

- (void)dimPanForLeftEnd:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX > 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _leftWidth);
    percent = percent > 1 ? 1 : percent;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent < BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:percent * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, _leftWidth, self.view.height)];
                    [self.bfMainViewController.view setX:_mainEndOffsetForLeft];

                    [_dimView setAlpha:self.dimOpacity];
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self _updateMainEndConstraintsForLeft];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(1 - percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfMainViewController.view setX:0];
                    [self.bfLeftViewController.view setFrame:CGRectMake(-_leftWidth, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForLeft];
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled: {
            if (percent < BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:percent * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CATransform3D transform = CATransform3DIdentity;
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    CGFloat tX = (1 / s) * (_leftWidth - (1 - self.mainScale) * self.bfMainViewController.view.width / 2);
                    transform = CATransform3DScale(transform, s, s, 1);
                    transform = CATransform3DTranslate(transform, tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                    [_dimView setAlpha:self.dimOpacity];
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, _leftWidth, self.view.height)];
                }                completion:^(BOOL finished) {
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    transform = CATransform3DScale(transform, s, s, 1);
                    CGFloat tX = (1 / s) * (_leftWidth + (s - 1) * self.bfMainViewController.view.width / 2);
                    transform = CATransform3DTranslate(transform, tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self.view layoutIfNeeded];
                    [self setIsLeftShowing:YES];
                }];
            }
            else {
                [UIView animateWithDuration:(1 - percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.bfLeftViewController.view setFrame:CGRectMake(_shouldLeftStill ? 0 : -_leftWidth, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self _updateMainStartConstraintsForLeft];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStylePerspective: {
            if (percent < BF_PERCENTAGE_SHOW_LEFT) {
                [UIView animateWithDuration:percent * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(0, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, -self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:YES];
                    [self.bfLeftViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateLeftEndConstraints];
                    [self.view layoutIfNeeded];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, -self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }];
            }
            else {
                [UIView animateWithDuration:(1 - percent) * self.leftAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfLeftViewController.view setFrame:CGRectMake(_shouldLeftStill ? 0 : -_leftWidth, 0, _leftWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, 0, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(1, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsLeftShowing:NO];
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width / 2, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.bfMainViewController.view.layer setShouldRasterize:NO];
                    [self _updateMainStartConstraintsForLeft];
                    [self.rootBackgroundImageView layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.leftDelegate respondsToSelector:@selector(rootSplitBuffEndPushingOutLeftSplitViewAt:)])
        [self.leftDelegate rootSplitBuffEndPushingOutLeftSplitViewAt:percent];
}

- (void)dimPanForRightBegin:(UIPanGestureRecognizer *)gesture {
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
    beginPoint = [gesture locationInView:self.view];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [self _updateMainStartConstraintsForRight];
            [self.view layoutIfNeeded];
        }

            break;
        case BuffSplitStylePerspective: {
            [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle);
            _rightWidth = rightSize.width;
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffWillPushOutRightSplitView)])
        [self.rightDelegate rootSplitBuffWillPushOutRightSplitView];
}

- (void)dimPanForRightChanged:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX < 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _rightWidth);
    percent = percent > 1 ? 1 : percent;
    CGFloat scaledDiffX = percent * _rightWidth;
    [_dimView setAlpha:self.dimOpacity * (1 - percent)];
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth + scaledDiffX, 0, _rightWidth, self.bfRightViewController.view.height)];
            [self.bfMainViewController.view setX:percent * _mainEndOffsetForLeft - _mainEndOffsetForLeft];
        }
            break;
        case BuffSplitStyleScaled: {
            [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width - _rightWidth + scaledDiffX, 0, _rightWidth, self.bfRightViewController.view.height)];
            self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
            CATransform3D transform = CATransform3DIdentity;
            CGFloat s = self.mainScale + (1 - self.mainScale) * percent;
            CGFloat tX = (1 / s) * (_rightWidth - (1 - self.mainScale) * self.bfMainViewController.view.width / 2 - (_rightWidth - (1 - self.mainScale) * self.bfMainViewController.view.width / 2) * percent);
            transform = CATransform3DScale(transform, s, s, 1);
            transform = CATransform3DTranslate(transform, -tX, 0, 0);
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStylePerspective: {
            CGSize rightSize = _bfGetSizeForSplitView(self.view, self.mainRotateAngle * (1 - percent));
            [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width - rightSize.width, 0, _rightWidth, self.view.height)];
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
            transform = CATransform3DRotate(transform, self.mainRotateAngle * (1 - percent), 0, 1, 0);
            [_dimView setAlpha:[RootSplitBuff rootViewController].dimOpacity * (1 - percent)];
            [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
            [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
            self.bfMainViewController.view.layer.transform = transform;
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffPushingOutRightSplitView:)])
        [self.rightDelegate rootSplitBuffPushingOutRightSplitView:percent];
}

- (void)dimPanForRightEnd:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    CGFloat diffX = p.x - beginPoint.x;
    diffX = diffX < 0 ? 0 : diffX;
    CGFloat percent = fabs(diffX * BF_SCALED_PAN / _rightWidth);
    percent = percent > 1 ? 1 : percent;
    switch ([[RootSplitBuff rootViewController] splitStyle]) {
        case BuffSplitStyleCovered: {
            if (percent < BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:percent * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth, 0, _rightWidth, self.view.height)];
                    [self.bfMainViewController.view setX:-_mainEndOffsetForLeft];
                    [_dimView setAlpha:self.dimOpacity];
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self _updateMainEndConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                [UIView animateWithDuration:(1 - percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width, 0, _rightWidth, self.view.height)];
                    [self.bfMainViewController.view setX:0];
                    [_dimView setAlpha:0];
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateMainStartConstraintsForRight];
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleScaled: {
            if (percent < BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:percent * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CATransform3D transform = CATransform3DIdentity;
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    CGFloat tX = (1 / s) * (_rightWidth - (1 - self.mainScale) * self.bfMainViewController.view.width / 2);
                    transform = CATransform3DScale(transform, s, s, 1);
                    transform = CATransform3DTranslate(transform, -tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                    [_dimView setAlpha:self.dimOpacity];
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth, 0, _rightWidth, self.view.height)];
                }                completion:^(BOOL finished) {
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat s = self.mainScale;
                    transform = CATransform3DScale(transform, s, s, 1);
                    CGFloat tX = (1 / s) * (_rightWidth + (s - 1) * self.bfMainViewController.view.width / 2);
                    transform = CATransform3DTranslate(transform, -tX, 0, 0);
                    self.bfMainViewController.view.layer.transform = transform;
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self.view layoutIfNeeded];
                    [self setIsRightShowing:YES];

                }];
            }
            else {
                [UIView animateWithDuration:(1 - percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self _updateMainStartConstraintsForRight];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.view layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStylePerspective: {
            if (percent < BF_PERCENTAGE_SHOW_RIGHT) {
                [UIView animateWithDuration:percent * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(self.view.width - _rightWidth, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:self.dimOpacity];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:YES];
                    [self.bfRightViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [self _updateRightEndConstraints];
                    [self.view layoutIfNeeded];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, self.mainRotateAngle, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }];
            }
            else {
                [UIView animateWithDuration:(1 - percent) * self.rightAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self.bfRightViewController.view setFrame:CGRectMake(_shouldRightStill ? self.view.width - _rightWidth : self.view.width, 0, _rightWidth, self.view.height)];
                    [_dimView setAlpha:0];
                    CATransform3D transform = CATransform3DIdentity;
                    transform.m34 = -1.0 / BF_EYE_DISTANCE_PERSPECTIVE;
                    transform = CATransform3DRotate(transform, 0, 0, 1, 0);
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(0, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = transform;
                }                completion:^(BOOL finished) {
                    [self setIsRightShowing:NO];
                    [self.bfMainViewController.view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                    [self.bfMainViewController.view.layer setPosition:CGPointMake(self.view.width / 2, self.view.height / 2)];
                    self.bfMainViewController.view.layer.transform = CATransform3DIdentity;
                    [self.bfMainViewController.view.layer setShouldRasterize:NO];
                    [self _updateMainStartConstraintsForRight];
                    [self.rootBackgroundImageView layoutIfNeeded];
                }];
            }
        }
            break;
        case BuffSplitStyleCustom:

            break;
        default:
            break;
    }
    if ([self.rightDelegate respondsToSelector:@selector(rootSplitBuffEndPushingOutRightSplitViewAt:)])
        [self.rightDelegate rootSplitBuffEndPushingOutRightSplitViewAt:percent];
}

- (void)dimTapAction:(UITapGestureRecognizer *)gesture {
    if (_isLeftShowing) {
        [RootSplitBuff hideLeftViewController];
    }
    if (_isRightShowing) {
        [RootSplitBuff hideRightViewController];
    }
}

#pragma mark - Foreground/Background Switch

- (void)willResignActive {
    [self.bfMainViewController.view.layer setShouldRasterize:NO];
}

- (void)willBecomeActive {
    if (self.splitStyle == BuffSplitStylePerspective && (self.isLeftShowing || self.isRightShowing)) {
        [self.bfMainViewController.view.layer setShouldRasterize:YES];
        [self.bfMainViewController.view.layer setRasterizationScale:[FrameBuff screenScale]];
    }
    else {
        [self.bfMainViewController.view.layer setShouldRasterize:NO];
    }
}
@end

#pragma mark - RootSplitBuff

@implementation RootSplitBuff
+ (BFRootViewController *)rootViewController {
    return [BFRootViewController sharedController];
}

#pragma mark - set split viewControllers;

+ (void)setMainViewController:(UIViewController *)mainViewController {
    [[BFRootViewController sharedController] setBfMainViewController:mainViewController];
}

+ (void)setLeftViewController:(UIViewController *)leftViewController {
    [[BFRootViewController sharedController] setBfLeftViewController:leftViewController];
}

+ (void)setRightViewController:(UIViewController *)rightViewController {
    [[BFRootViewController sharedController] setBfRightViewController:rightViewController];
}

#pragma mark - show or hide split viewControllers;

+ (void)showLeftViewController {
    [[BFRootViewController sharedController] showLeftViewController];
}

+ (void)hideLeftViewController {
    [[BFRootViewController sharedController] hideLeftViewController];
}

+ (void)showRightViewController {
    [[BFRootViewController sharedController] showRightViewController];
}

+ (void)hideRightViewController {
    [[BFRootViewController sharedController] hideRightViewController];
}

#pragma mark - active or deactive gestures

+ (void)activeLeftPanGesture {
    [[BFRootViewController sharedController] activeLeftPanGesture];
    [[BFRootViewController sharedController] _setShouldLeftPanActive:YES];
}

+ (void)deactiveLeftPanGesture {
    [[BFRootViewController sharedController] deactiveLeftPanGesture];
    [[BFRootViewController sharedController] _setShouldLeftPanActive:NO];
}

+ (void)activeRightPanGesture {
    [[BFRootViewController sharedController] activeRightPanGesture];
    [[BFRootViewController sharedController] _setShouldRightPanActive:YES];
}

+ (void)deactiveRightPanGesture {
    [[BFRootViewController sharedController] deactiveRightPanGesture];
    [[BFRootViewController sharedController] _setShouldRightPanActive:NO];
}
@end

@implementation UIViewController (RootSplitBuff)
#pragma mark UIViewController Method swizzling+forwarding 

//请注意此处Method swizzling会造成UIViewController instance's presentingViewController为[RootSplitBuff rootViewController]而不是presentViewController:animated:completion:的调用者
+ (void)load {
    static dispatch_once_t rootSplitBuffToken;
    dispatch_once(&rootSplitBuffToken, ^{
        Class class = [UIViewController class];
        SEL origSel = @selector(presentViewController:animated:completion:);
        SEL swizSel = @selector(bf_swizzled_presentViewController:animated:completion:);
        Method origMethod = class_getInstanceMethod(class, origSel);
        Method swizMethod = class_getInstanceMethod(class, swizSel);
        BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        }
        else {
            method_exchangeImplementations(origMethod, swizMethod);
        }
        Class class2 = [UIViewController class];
        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(bf_swizzled_viewDidAppear:);

        Method originalMethod = class_getInstanceMethod(class2, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class2, swizzledSelector);
        BOOL didAddMethod2 =
                class_addMethod(class2,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod2) {
            class_replaceMethod(class2,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }


//        SEL originalSelector2 = @selector(viewDidDisappear:);
//        SEL swizzledSelector2 = @selector(tjs_swizzled_viewDidDisappear:);
//        
//        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
//        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
//        BOOL didAddMethod3 =
//        class_addMethod(class,
//                        originalSelector2,
//                        method_getImplementation(swizzledMethod2),
//                        method_getTypeEncoding(swizzledMethod2));
//        
//        if (didAddMethod3) {
//            class_replaceMethod(class,
//                                swizzledSelector2,
//                                method_getImplementation(originalMethod2),
//                                method_getTypeEncoding(originalMethod2));
//        } else {
//            method_exchangeImplementations(originalMethod2, swizzledMethod2);
//        }
    });

}

- (void)bf_swizzled_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (self == [RootSplitBuff rootViewController]) {
        [self bf_swizzled_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    else {
        if ([RootSplitBuff rootViewController].isRootViewContollerShowing) {
            [[RootSplitBuff rootViewController] bf_swizzled_presentViewController:viewControllerToPresent animated:flag completion:completion];
        }
        else {
            [self bf_swizzled_presentViewController:viewControllerToPresent animated:flag completion:completion];
        }
    }
}

- (void)bf_swizzled_viewDidAppear:(BOOL)animated {
    [self bf_swizzled_viewDidAppear:animated];
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count > 1) {
            [RootSplitBuff rootViewController].bfLeftPan.enabled = NO;
            [RootSplitBuff rootViewController].bfRightPan.enabled = NO;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>) self;
        }
        else if (self.navigationController.viewControllers.count == 1) {
            [RootSplitBuff rootViewController].bfLeftPan.enabled = [[RootSplitBuff rootViewController] _shouldLeftPanActive];
            [RootSplitBuff rootViewController].bfRightPan.enabled = [[RootSplitBuff rootViewController] _shouldRightPanActive];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
}
//-(void)tjs_swizzled_viewDidDisappear:(BOOL)animated{
//    [self tjs_swizzled_viewDidDisappear:animated];
//}
@end