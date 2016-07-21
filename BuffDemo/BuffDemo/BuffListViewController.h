//
//  BuffListViewController.h
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/5/5.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuffListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
}
@property (nonatomic,strong)    UITableView *buffListTableView;

@end
