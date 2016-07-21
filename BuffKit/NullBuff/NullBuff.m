//
// NullBuff.h
//
// Created by BoWang(r4l.xyz) on 16/5/16.
// Copyright (c) 2016 BoWang(r4l.xyz). All rights reserved.
//

#import "NullBuff.h"
#import <objc/runtime.h>

@implementation NSNull (NullBuff)
- (id)forwardingTargetForSelector:(SEL)aSelector {
    //处理NSNumber,NSString,NSArray,NSDictionary
    NSArray *supporttedTypes = @[@"NSNumber" , @"NSString" , @"NSArray" , @"NSDictionary"];
    for (NSUInteger i = 0; i < 4; ++i) {
        Method m = class_getInstanceMethod(NSClassFromString(supporttedTypes[i]) , aSelector);
        const char *returnType = method_copyReturnType(m);
        if (returnType) {
            free((void *)returnType);
            switch (i) {
                case 0:
                    return @(0);
                case 1:
                    return @"";
                case 2:
                    return @[];
                case 3:
                    return @{};
                default:
                    break;
            }
        }
    }
    return [super forwardingTargetForSelector:aSelector];
}
@end

@implementation NullBuff {

}
@end