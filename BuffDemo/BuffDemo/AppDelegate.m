//
//  AppDelegate.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/5/3.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "AppDelegate.h"
#import "BuffListViewController.h"
#import <objc/runtime.h>
#import "BuffLeftViewController.h"
#import "BuffRightViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect screenBounds=[[UIScreen mainScreen]bounds];
    _window=[[UIWindow alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    BuffListViewController  *buffListVC=[[BuffListViewController alloc]init];
    [buffListVC setTitle:@"BuffKit"];
    UINavigationController *navi=[[UINavigationController alloc]initWithRootViewController:buffListVC];
    
    [[RootSplitBuff rootViewController]setRootBackgroundPortraitImage:[UIImage imageNamed:@"WallPaper.jpg"]];
    [[RootSplitBuff rootViewController]setRootBackgroundLandscapeImage:[UIImage imageNamed:@"WallPaper2.jpg"]];
    [[RootSplitBuff rootViewController]setBfMainViewController:navi];
    BuffLeftViewController *lvc=[[BuffLeftViewController alloc]init];
    [[RootSplitBuff rootViewController]setBfLeftViewController:lvc];
    [RootSplitBuff activeLeftPanGesture];
    BuffRightViewController *rvc=[[BuffRightViewController alloc]init];
    [[RootSplitBuff rootViewController]setBfRightViewController:rvc];
    [RootSplitBuff activeRightPanGesture];
    [[RootSplitBuff rootViewController]setSplitStyle:BuffSplitStylePerspective];
    [[RootSplitBuff rootViewController]setMainRotateAngle:1.2];
    [RootSplitBuff rootViewController].shouldLeftStill=YES;
    [RootSplitBuff rootViewController].shouldRightStill=YES;
    
    [_window setRootViewController:[RootSplitBuff rootViewController]];
    [_window makeKeyAndVisible];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
