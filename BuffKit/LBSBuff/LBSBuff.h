//
//  LBSBuff.h
//
//  Created by BoWang(r4l.xyz) on 13-7-17.
//  Copyright © 2013年 BoWang(r4l.xyz). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

CLLocationCoordinate2D bfLBSWgsToMars(CLLocationCoordinate2D wgsLoc);

CLLocationCoordinate2D bfLBSWgsToMars2(double lon, double lat);

@interface LBSBuff : NSObject

@end
