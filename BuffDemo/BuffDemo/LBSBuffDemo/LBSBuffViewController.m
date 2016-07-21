//
//  LBSBuffViewController.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/5/11.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "LBSBuffViewController.h"
#import <MapKit/MapKit.h>

@interface LBSBuffViewController ()

@end

@implementation LBSBuffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"LBSBuff"];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    CLLocationCoordinate2D marsLoc = bfLBSWgsToMars2(117.48711029, 30.65719177);
    NSLog(@"\nwgs84坐标：117.487110,30.657191\n转换后坐标：%f,%f\nGCJ02坐标:117.492617,30.654859", marsLoc.longitude, marsLoc.latitude);
    UIImageView *demoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 200)];
    [demoImageView setImage:[UIImage imageNamed:@"lbsbuff.jpg"]];
    [self.view addSubview:demoImageView];
    UILabel *sourceLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(0, demoImageView.bottom + 10, self.view.width, 50)];
    [sourceLabel setNumberOfLines:0];
    [sourceLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [sourceLabel setText:@"数据来源:\nhttp://www.gpsspg.com/maps.htm"];
    [self.view addSubview:sourceLabel];
    UILabel *descLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(0, sourceLabel.bottom + 10, self.view.width, 200)];
    [descLabel setNumberOfLines:0];
    [descLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [descLabel setText:@"请查看Console,上图谷歌地球是WGS84坐标系,高德腾讯谷歌地图是GCJ02坐标系,对比结果能发现转换精度到小数点后4位"];
    [descLabel sizeToFit];
    [self.view addSubview:descLabel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
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
