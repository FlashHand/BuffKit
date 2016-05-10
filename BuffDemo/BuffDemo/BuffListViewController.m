//
//  BuffListViewController.m
//  BuffDemo
//
//  Created by BoWang on 16/5/5.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "BuffListViewController.h"
#import "BuffKit.h"
@interface BuffListViewController ()

@end

@implementation BuffListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSString *str=@"5492557823faec274708eb34d263029084abe5544789340a1d3ccf6bd74774ad";
    NSData *key=[str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *sourceStr=@"21214fjafodpafa90via09dva0vava21214fjafodpafa90via09dva0vava21214fjafodpafa90via09dva0vava21214fjafodpafa90via09dva0vava";
    NSData *source=[sourceStr dataUsingEncoding:NSUTF8StringEncoding];
    [source buffCryptoAESEncodeWithMode:BuffCryptoModeECB padding:NO iv:nil key:@"1231111" completion:^(NSData *cryptoData) {
        NSString *aesStr=[[NSString alloc]initWithData:cryptoData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",aesStr);
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
