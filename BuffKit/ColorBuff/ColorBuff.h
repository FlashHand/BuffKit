//
//  ColorBuff.h
//
//  Created by BoWang on 16/5/12.
//  Copyright (c) 2016 BoWang. All rights reserved.
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

@interface UIImage (ColorBuff)
-(UIColor *)colorAtX:(NSInteger)x y:(NSInteger)y;
-(UIColor *)mainColor;
@end

@interface ColorBuff : NSObject
@end
