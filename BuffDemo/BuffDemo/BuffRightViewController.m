//
//  BuffRightViewController.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/6/16.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "BuffRightViewController.h"

@interface BuffRightViewController ()

@end

@implementation BuffRightViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHex:0xf36838 alpha:1]];
    UIView *containerView=self.view;
    UIButton *dismissBtn=[[UIButton alloc]init];
    [dismissBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:dismissBtn];
    [dismissBtn setTitle:@"dismiss" forState:UIControlStateNormal];
    NSDictionary *bindings = NSDictionaryOfVariableBindings(containerView,dismissBtn);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft;
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"margin" : @20};
    NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[dismissBtn(==100)]" options:ops metrics:metrics views:bindings];
    NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dismissBtn(20)]" options:ops metrics:metrics views:bindings];
    [constraints addObjectsFromArray:c1];
    [constraints addObjectsFromArray:c2];
    [self.view addConstraints:constraints];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dismissBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:dismissBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [dismissBtn.layer setCornerRadius:4.0];
    [dismissBtn setTitleColor:[UIColor colorWithHex:0xffffff alpha:0.8] forState:UIControlStateNormal];
    [dismissBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [RootSplitBuff rootViewController].rightDelegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissAction:(UIButton *)sender{
    [RootSplitBuff hideRightViewController];
}

-(void)rootSplitBuffDoPushInRightSplitView{
    NSLog(@"rootSplitBuffDoPushInRightSplitView");
}
-(void)rootSplitBuffWillPushInRightSplitView{
    NSLog(@"rootSplitBuffWillPushInRightSplitView");
}
-(void)rootSplitBuffPushingInRightSplitView:(CGFloat)percent{
    NSLog(@"rootSplitBuffWillPushInRightSplitView:%f",percent);
}
-(void)rootSplitBuffEndPushingInRightSplitViewAt:(CGFloat)percent{
    NSLog(@"rootSplitBuffEndPushingInRightSplitViewAt:%f",percent);
}

-(void)rootSplitBuffDoPushOutRightSplitView{
    NSLog(@"rootSplitBuffDoPushOutRightSplitView");
}
-(void)rootSplitBuffWillPushOutRightSplitView{
    NSLog(@"rootSplitBuffWillPushOutRightSplitView");
}
-(void)rootSplitBuffPushingOutRightSplitView:(CGFloat)percent{
    NSLog(@"rootSplitBuffPushingOutRightSplitView:%f",percent);
}
-(void)rootSplitBuffEndPushingOutRightSplitViewAt:(CGFloat)percent{
    NSLog(@"rootSplitBuffEndPushingOutRightSplitViewAt:%f",percent);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
