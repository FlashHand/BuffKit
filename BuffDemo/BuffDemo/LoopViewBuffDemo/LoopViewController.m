//
//  LoopViewController.m
//  BuffDemo
//
//  Created by BoWang on 16/6/28.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "LoopViewController.h"

@interface LoopViewController ()

@end

@implementation LoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSMutableArray *btnArr=[NSMutableArray new];
    for (int i=0; i<5; i++) {
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 220)];
        [btn setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [btnArr addObject:btn];
    }
    BFLoopView *bfLoopView=[BFLoopView loopViewWithItems:btnArr frame:CGRectMake(0, 100, self.view.width, 220) loopPeriod:5 animationDuration:1 animationStyle:BuffLoopViewAnimationStyleLinearEasyInOut];
    [self.view addSubview:bfLoopView];
    [bfLoopView setShouldAnimation:YES];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
}
-(void)loopViewClickAction:(UIButton *)sender{
    NSLog(@"Tag:%d",sender.tag);
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
