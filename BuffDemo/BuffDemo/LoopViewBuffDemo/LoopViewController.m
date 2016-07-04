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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)displayLinkAction:(id)sender{
    NSLog(@"%f",CACurrentMediaTime());
}
-(void)dealloc{
    
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
