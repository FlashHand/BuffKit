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
    return self;
}
- (void)viewDidLoad {
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
    [self.rootBackgroundImageView setImage:[UIImage imageNamed:@"WallPaper.jpg"]];
    [self.view addConstraints:constraints];
}
#pragma mark 设置主控制器
-(void)setBfMainViewController:(UIViewController *)bfMainViewController {
    _bfMainViewController=bfMainViewController;
    [self.bfMainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.bfMainViewController.view];
    UIView *mainView=self.bfMainViewController.view;
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(mainView,containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin":@0};
    NSMutableArray*fullScreenConstraints=[NSMutableArray array];
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[mainView(==containerView)]" options:ops metrics:metrics views:bindings];
    [fullScreenConstraints addObjectsFromArray:c1];
    [fullScreenConstraints addObjectsFromArray:c2];
    [self.view addConstraints:fullScreenConstraints];
}
#pragma mark 设置左控制器
#pragma mark 设置右控制器

#pragma mark 设置背景
-(void)setRootBackgroundImage:(UIImage *)rootBackgroundImage
{
    _rootBackgroundImage=rootBackgroundImage;
    [self.rootBackgroundImageView setImage:rootBackgroundImage];
}

#pragma mark Private method
-(void)setMainViewConstraints{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSLayoutConstraint *mainViewConstraints=[NSLayoutConstraint constraintWithItem:self.bfMainViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
}
@end
@implementation UIViewController (RootVCSplitBuff)

@end
@implementation RootSplitBuff
+(BFRootViewController *)rootViewController{
    return [BFRootViewController sharedController];
}
@end
