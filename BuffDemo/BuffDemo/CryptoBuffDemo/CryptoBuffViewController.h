//
//  CryptoBuffViewController.h
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/5/10.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CryptoBuffViewController : UIViewController {
    BuffCryptoMode currentMode;
    NSInteger alg;//1=AES,2=DES,3=3DES,4=BLOWFISH
}
@property(nonatomic, strong) UITextView *textView;

@end
