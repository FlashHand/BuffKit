//
//  ColorBuff.h
//
//  Created by BoWang(r4l.xyz) on 16/5/12.
//  Copyright (c) 2016 BoWang(r4l.xyz). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIColor (ColorBuff)
+(UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;
+(UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
-(NSString *)hexString;

-(UIColor *)colorWithAlpha:(CGFloat)alpha;

-(NSInteger)red;
-(NSInteger)green;
-(NSInteger)blue;
-(CGFloat)alpha;

-(UIColor *)reversedColor;

@end
@interface ColorBuff : NSObject
@end
