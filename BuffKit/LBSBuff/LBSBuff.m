//
//  LBSBuff.m
//
//  Created by BoWang(r4l.xyz) on 13-7-17.
//  Copyright © 2013年 BoWang(r4l.xyz). All rights reserved.
//

#import "LBSBuff.h"

CLLocationCoordinate2D bfLBSWgsToMars(CLLocationCoordinate2D wgsLoc) {
    CLLocationCoordinate2D marsLoc;
    //算法仅适用于中国地区，经过自己的LBS应用实际测试，转换精确度到小数点后4位。
    if (wgsLoc.longitude < 137.8347 && wgsLoc.longitude > 72.004 && wgsLoc.latitude > 0.8293 && wgsLoc.latitude < 55.8271) {
        //固定参数设置
        double kPI = 3.14159265358979324;//17位小数
        double kA = 6378245.0; //Krasovsky常数
        double kE = 0.00669342162296594323; //20位小数
        double kD = 0.66666666666666666667;//20位小数

        double x = wgsLoc.longitude - 105;
        double y = wgsLoc.latitude - 35;
        //获取经度偏移量的参考值
        double f = 300 + x + 0.2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
        f += (20 * sin(6 * kPI * x) + 20 * sin(2.0 * kPI * x)) * kD;
        f += (20 * sin(kPI * x) + 40 * sin(x / 3 * kPI)) * kD;
        f += (150 * sin(x / 12 * kPI) + 300 * sin(x / 30 * kPI)) * kD;
        //获取纬度偏移量的参考值
        double r = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
        r += (20 * sin(6 * x * kPI) + 20 * sin(2.0 * x * kPI)) * kD;
        r += (20 * sin(kPI * y) + 40 * sin(y / 3.0 * kPI)) * kD;
        r += (160 * sin(y / 12 * kPI) + 320 * sin(y * kPI / 30)) * kD;
        double ret = wgsLoc.latitude / 180 * kPI;
        double magic = sin(ret);
        magic = 1 - kE * magic * magic;
        double sqrtmagic = sqrt(magic);
        double dlon = (f * 180) / (kA / sqrtmagic * cos(ret) * kPI);
        double dlat = (r * 180) / ((kA * (1 - kE)) / (magic * sqrtmagic) * kPI);
        //进行偏移
        marsLoc.longitude = wgsLoc.longitude + dlon;
        marsLoc.latitude = wgsLoc.latitude + dlat;
    }
    else {
        marsLoc = wgsLoc;
    }
    return marsLoc;
}

CLLocationCoordinate2D bfLBSWgsToMars2(double lon, double lat) {
    CLLocationCoordinate2D wgsLoc = {lat, lon};
    return bfLBSWgsToMars(wgsLoc);
}

@implementation LBSBuff

@end
