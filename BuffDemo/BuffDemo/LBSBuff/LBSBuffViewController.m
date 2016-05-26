//
//  LBSBuffViewController.m
//  BuffDemo
//
//  Created by BoWang on 16/5/11.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "LBSBuffViewController.h"
#import <MapKit/MapKit.h>
@interface LBSBuffViewController ()

@end

@implementation LBSBuffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setHidesBackButton:NO animated:YES];
   CLLocationCoordinate2D marsLoc=bfLBSWgsToMars2(121.9055843353,30.8737192326);
    NSLog(@"\nwgs84坐标：121.9055843353,30.8737192326\n转换后坐标：%f,%f\nGCJ02坐标:121.9097200053,30.8713842226",marsLoc.longitude,marsLoc.latitude);
    
    // Do any additional setup after loading the view.
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
