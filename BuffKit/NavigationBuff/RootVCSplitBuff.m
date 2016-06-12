//
//  RootVCSplitBuff.m
//  BuffDemo
//
//  Created by 王博 on 16/6/7.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "RootVCSplitBuff.h"
static BFRootViewController *rootViewController=nil;
@implementation BFRootViewController
+(BFRootViewController *)sharedController{
    @synchronized (self) {
        if (!rootViewController) {
            rootViewController = [[super allocWithZone:NULL]init];
        }
    }
    return rootViewController;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedController];
}
- (instancetype)init {
    if (rootViewController) {
        return rootViewController;
    }
    self = [super init];
    return self;
}
@end
@implementation UIViewController (RootVCSplitBuff)

@end
@implementation RootVCSplitBuff
+(UIViewController *)rootViewController{
    return [BFRootViewController sharedController];
}
@end
