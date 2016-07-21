//
//  BuffLeftViewController.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/6/16.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "BuffLeftViewController.h"
@interface BuffLeftViewController ()

@end

@implementation BuffLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHex:0x1bd1a5 alpha:1]];
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
    [dismissBtn setBackgroundColor:[UIColor colorWithHex:0x1bd1a5 alpha:0.8]];
    [dismissBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [RootSplitBuff rootViewController].leftDelegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissAction:(UIButton *)sender{
    [RootSplitBuff hideLeftViewController];
}
-(void)rootSplitBuffDoPushInLeftSplitView{
    NSLog(@"rootSplitBuffDoPushInLeftSplitView");
}
-(void)rootSplitBuffWillPushInLeftSplitView{
    NSLog(@"rootSplitBuffWillPushInLeftSplitView");
}
-(void)rootSplitBuffPushingInLeftSplitView:(CGFloat)percent{
    NSLog(@"rootSplitBuffPushingInLeftSplitView:%f",percent);

}
-(void)rootSplitBuffEndPushingInLeftSplitViewAt:(CGFloat)percent{
    NSLog(@"rootSplitBuffEndPushingInLeftSplitViewAt:%f",percent);
}

-(void)rootSplitBuffDoPushOutLeftSplitView{
    NSLog(@"rootSplitBuffDoPushOutLeftSplitView");
}
-(void)rootSplitBuffWillPushOutLeftSplitView{
    NSLog(@"rootSplitBuffWillPushOutLeftSplitView");

}
-(void)rootSplitBuffPushingOutLeftSplitView:(CGFloat)percent{
    NSLog(@"rootSplitBuffPushingOutLeftSplitView:%f",percent);

}
-(void)rootSplitBuffEndPushingOutLeftSplitViewAt:(CGFloat)percent{
    NSLog(@"rootSplitBuffEndPushingOutLeftSplitViewAt:%f",percent);

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
