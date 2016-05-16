//
// Created by BoWang on 16/5/16.
// Copyright (c) 2016 BoWang. All rights reserved.
//

#import "NullBuff.h"
#import <objc/runtime.h>

@implementation NSNull (NullBuff)
- (id)forwardingTargetForSelector:(SEL)aSelector {
    //处理NSNumber,NSString,NSArray,NSDictionary
    NSArray *supporttedTypes = @[@"NSNumber" , @"NSString" , @"NSArray" , @"NSDictionary"];
    for (int i = 0; i < 4; ++i) {
        Method m = class_getInstanceMethod(NSClassFromString(supporttedTypes[i]) , aSelector);
        const char *returnType = method_copyReturnType(m);
        if (returnType) {
            NSString *returnTypeStr = [[NSString alloc] initWithCString:returnType encoding:NSUTF8StringEncoding];
            switch (i) {
                case 0:
                    return @(0);
                    break;
                case 1:
                    return @"";
                    break;
                case 2:
                    return @[];
                    break;
                case 3:
                    return @{};
                    break;
                default:
                    break;
            }
        }
        free(returnType);

    }
    return [super forwardingTargetForSelector:aSelector];
}
@end

@implementation NullBuff {

}
@end