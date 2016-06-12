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
    UIImageView *rootBackgroudImageView=[[UIImageView alloc]init];
    NSLayoutConstraint *mainViewConstraint1=[NSLayoutConstraint constraintWithItem:rootBackgroudImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    NSLayoutConstraint *mainViewConstraint2=[NSLayoutConstraint constraintWithItem:rootBackgroudImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    NSLayoutConstraint *mainViewConstraint3=[NSLayoutConstraint constraintWithItem:rootBackgroudImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    NSLayoutConstraint *mainViewConstraint4=[NSLayoutConstraint constraintWithItem:rootBackgroudImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.view addSubview:rootBackgroudImageView];
    [rootBackgroudImageView setImage:[UIImage imageNamed:@"bg.jpg"]];
}
-(void)setBfMainViewController:(UIViewController *)bfMainViewController {
    _bfMainViewController=bfMainViewController;

}

#pragma mark Private method
-(void)setMainViewConstraints{
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *mainViewConstraints=[NSLayoutConstraint constraintWithItem:self.bfMainViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
}
@end
@implementation UIViewController (RootVCSplitBuff)

@end
@implementation RootSplitBuff
+(UIViewController *)rootViewController{
    return [BFRootViewController sharedController];
}
@end
