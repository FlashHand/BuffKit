//
//  CryptoBuffViewController.m
//  BuffDemo
//
//  Created by BoWang on 16/5/10.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "CryptoBuffViewController.h"

@interface CryptoBuffViewController ()<UITextViewDelegate,UIScrollViewDelegate>
{
    UILabel *hexLabel;
    UILabel *origTextLabel;
}
@end

@implementation CryptoBuffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"CryptoBuff"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIScrollView *scrollView= [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(self.view.width,self.view.height)];
    UITextView  *textView= [[UITextView alloc] initWithFrame:CGRectMake(0,0,self.view.width,200)];
    [scrollView addSubview:textView];
    [textView setDelegate:self];


    NSString *sourceStr=@"abcd1234567812345678";

    NSData *source=[sourceStr dataUsingEncoding:NSUTF8StringEncoding];

    [source bfCryptoAESEncodeWithMode:BuffCryptoModeCFB iv:@"1234567812345678" key:@"1234567812345678" completion:^(NSData *cryptoData) {
        [cryptoData bfCryptoAESDecodeWithMode:BuffCryptoModeCFB iv:@"1234567812345678" key:@"1234567812345678" completion:^(NSData *cryptoData2) {
            NSString *result = [[NSString alloc] initWithData: cryptoData2 encoding: NSUTF8StringEncoding];
            NSLog(@"%@",result);
        }];
    }];

    [self.navigationItem setHidesBackButton:NO animated:YES];
    UISegmentedControl *seg= [[UISegmentedControl alloc] initWithItems:@[@"ECB",@"CBC",@"CFB",@"CTR",@"OFB",@"CFB8"]];
    [seg setFrame:CGRectMake(20,10,300,30)];
    [self.view addSubview:seg];
    // Do any additional setup after loading the view from its nib.
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
