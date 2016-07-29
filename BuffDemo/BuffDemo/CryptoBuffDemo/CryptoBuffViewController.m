//
//  CryptoBuffViewController.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/5/10.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "CryptoBuffViewController.h"

@interface CryptoBuffViewController () <UITextViewDelegate> {
    UILabel *hexLabel;
    UILabel *origTextLabel;
}
@end

@implementation CryptoBuffViewController
@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled=YES;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id<UIGestureRecognizerDelegate> )self;
    UIButton *backButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 50)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:leftItem animated:YES];
    [self setTitle:@"CryptoBuff"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    currentMode = BuffCryptoModeECB;
    alg = 1;

    //加密算法
    UILabel  *introLabel= [[UILabel alloc] initWithFrame:CGRectMake(self.view.width / 2.0 - 150, 10 + 64, 300, 30)];
    [introLabel setText:@"以AES为例"];
    [introLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:introLabel];
    //加密模式选项
    UISegmentedControl *modeSeg = [[UISegmentedControl alloc] initWithItems:@[@"ECB", @"CBC", @"CFB", @"CTR", @"OFB", @"CFB8"]];
    [modeSeg setFrame:CGRectMake(self.view.width / 2.0 - 150, 50 + 64, 300, 30)];
    [modeSeg addTarget:self action:@selector(segAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:modeSeg];
    [modeSeg setSelectedSegmentIndex:0];

    UIButton *encodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width / 2.0 - 25-40, modeSeg.bottom + 20, 50, 40)];
    [encodeBtn setTitle:@"加密" forState:UIControlStateNormal];
    [encodeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:encodeBtn];
    [encodeBtn addTarget:self action:@selector(encodeAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width / 2.0 - 25+40, modeSeg.bottom + 20, 50, 40)];
    [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:clearBtn];
    [clearBtn addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];

    [[UITextView appearance] setTintColor:[UIColor yellowColor]];
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, encodeBtn.bottom + 20, self.view.width, self.view.height - encodeBtn.bottom - 20)];
    [textView setBackgroundColor:[UIColor blueColor]];
    [textView setTextColor:[UIColor yellowColor]];
    [textView setDelegate:self];
    [self.view addSubview:textView];

    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [textView becomeFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}
-(void)backAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark Actions

- (void)segAction:(UISegmentedControl *)sender {
        if (sender.selectedSegmentIndex < 4) {
            currentMode = sender.selectedSegmentIndex + 1;
        }
        else if (sender.selectedSegmentIndex == 4) {
            currentMode = 7;
        }
        else if (sender.selectedSegmentIndex == 5) {
            currentMode = 10;
        }
}

- (void)encodeAction:(UIButton *)sender {
    NSString *plaintText = textView.text;
    NSData *source = [plaintText dataUsingEncoding:NSUTF8StringEncoding];
    [source bfCryptoAESEncodeWithMode:currentMode iv:@"qwer1234qwer1234" key:@"qwer1234qwer1234" completion:^(NSData *cryptoData) {
        NSMutableString *cypherText = [[NSMutableString alloc] init];
        [cryptoData enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            unsigned char *dataBytes = (unsigned char *) bytes;
            for (NSInteger i = 0; i < byteRange.length; i++) {
                NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
                if ([hexStr length] == 2) {
                    [cypherText appendString:hexStr];
                } else {
                    [cypherText appendFormat:@"0%@", hexStr];
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(),^{
            [self.textView setText:cypherText];
            [self.textView endEditing:YES];
        });
        NSLog(@"PlainText:\n%@\nCypherText:\n%@", plaintText, cypherText);
        NSData *iv=[@"qwer1234qwer1234" dataUsingEncoding:BuffDefaultStringEncoding];
        NSData *key=[@"qwer1234qwer1234" dataUsingEncoding:BuffDefaultStringEncoding];
        [cryptoData bfCryptoAESBytesDecodeWithMode:currentMode iv:iv key:key completion:^(NSData *cryptoData2) {
            NSString *result= [[NSString alloc] initWithData:cryptoData2 encoding:NSUTF8StringEncoding];
            NSLog(@"%@",result);

        }];
    }];
}
-(void)clearAction:(UIButton *)sender{
    [textView setText:@""];
    [textView endEditing:YES];
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
