//
//  ColorBuff.m
//
//  Created by BoWang(r4l.xyz) on 16/5/12.
//  Copyright (c) 2016 BoWang(r4l.xyz). All rights reserved.
//

#import "ColorBuff.h"
#import "FrameBuff.h"

@implementation UIColor (ColorBuff)
+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    UIColor *hexColor;
    if (hex <= 0xFFFFFF && hex >= 0x000000) {
        hexColor = [UIColor colorWithRed:((hex & 0xFF0000) >> 16)/255.0 green:((hex & 0xFF00) >> 8)/255.0 blue:(hex & 0xFF)/255.0 alpha:alpha];
    }
    else {
        hexColor = [UIColor whiteColor];
    }
    return hexColor;

}

+ (UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    UIColor *hexColor;
    if ([hexStr hasPrefix:@"0x"]) {
        unsigned long hex = strtoul([hexStr UTF8String] , 0 , 0);
        hexColor = [UIColor colorWithHex:(NSInteger)hex alpha:alpha];
    }
    else if ([hexStr hasPrefix:@"#"]) {
        hexColor = [UIColor colorWithHexString:[@"0x" stringByAppendingString:[hexStr substringFromIndex:1]] alpha:alpha];
    }
    return hexColor;
}

- (NSString *)hexString {
    UIColor *completeColor= [[UIColor alloc] initWithCGColor:self.CGColor];
    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        completeColor=[UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }
    if(CGColorSpaceGetModel(CGColorGetColorSpace(completeColor.CGColor))!=kCGColorSpaceModelRGB){
        return @"#ffffff";
    }
    return [NSString stringWithFormat:@"#%02x%02x%02x",(int)ceil((CGColorGetComponents(completeColor.CGColor)[0]*255.0)),
            (int)ceil((CGColorGetComponents(completeColor.CGColor)[1]*255.0)),
                    (int)ceil((CGColorGetComponents(completeColor.CGColor)[2]*255.0))];
}

- (UIColor *)colorWithAlpha:(CGFloat)alpha {
    const CGFloat *components = CGColorGetComponents(self.CGColor);

    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        return [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:alpha];
    }
    return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:alpha];
}

- (NSInteger)red {

    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        return (int)ceil((CGColorGetComponents(self.CGColor)[0]*255.0));
    }
    if(CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))!=kCGColorSpaceModelRGB){
        return NSNotFound;
    }
    return (int)ceil((CGColorGetComponents(self.CGColor)[0]*255.0));
}

- (NSInteger)green {

    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        return (int)ceil((CGColorGetComponents(self.CGColor)[0]*255.0));
    }
    if(CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))!=kCGColorSpaceModelRGB){
        return NSNotFound;
    }
    return (int)ceil((CGColorGetComponents(self.CGColor)[1]*255.0));
}

- (NSInteger)blue {

    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        return (int)ceil((CGColorGetComponents(self.CGColor)[0]*255.0));
    }
    if(CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))!=kCGColorSpaceModelRGB){
        return NSNotFound;
    }
    return (int)ceil((CGColorGetComponents(self.CGColor)[2]*255.0));
}

- (CGFloat)alpha {
    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        return CGColorGetComponents(self.CGColor)[1];
    }
    if(CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))!=kCGColorSpaceModelRGB){
        return NSNotFound;
    }
    return CGColorGetComponents(self.CGColor)[3];
}

- (UIColor *)reversedColor {
    const CGFloat *components = CGColorGetComponents(self.CGColor);

    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        return [UIColor colorWithRed:1-components[0] green:1-components[0] blue:1-components[0] alpha:components[1]];
    }
    if(CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))!=kCGColorSpaceModelRGB){
        return nil;
    }
    return [UIColor colorWithRed:1-components[0] green:1-components[1] blue:1-components[2] alpha:components[1]];
}

@end

//@implementation UIImage (ColorBuff)
//- (UIColor *)colorAtX:(NSInteger)x y:(NSInteger)y {
//    if (x>=self.width||x<0||y>=self.height||y<0){
//        return nil;
//    }
//    uint32_t bitmapInfo = kCGBitmapByteOrderDefault;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL,
//            (size_t)self.width,
//            (size_t)self.height,
//            8,
//            (size_t)self.width*4,
//            colorSpace,
//            bitmapInfo);
//    const int *data = CGBitmapContextGetData (context);
//    long offset;
//    offset = 4*(y*(size_t)(self.width)+x);
//    int red = data[offset];
//    int green = data[offset+1];
//    int blue = data[offset+2];
//    int alpha =  data[offset+3];
//
//    return [UIColor colorWithRed:(CGFloat) (red / 255.0) green:(CGFloat) (green / 255.0) blue:(CGFloat) (blue / 255.0) alpha:alpha];
//}
//- (UIColor *)mainColor {
//    return nil;
//}
//@end

@implementation ColorBuff
@end
