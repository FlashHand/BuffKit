//
//  BuffListViewController.m
//  BuffDemo
//
//  Created by BoWang(r4l.xyz) on 16/5/5.
//  Copyright © 2016年 BoWang(r4l.xyz). All rights reserved.
//

#import "BuffListViewController.h"
#import "CryptoBuffViewController.h"
#import "LBSBuffViewController.h"
#import "LoopViewController.h"
#import <objc/runtime.h>
@interface BuffListViewController ()

@end

@implementation BuffListViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    //sidebar
    _buffListTableView=[[UITableView alloc]init];
    [_buffListTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_buffListTableView];
    NSMutableArray *constraints=[NSMutableArray array];
    UIView *containerView=self.view;
    NSDictionary *bindings=NSDictionaryOfVariableBindings(_buffListTableView,containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSDictionary *metrics = @{@"margin":@0};
    NSArray *c1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_buffListTableView(==containerView)]" options:ops metrics:metrics views:bindings];
    NSArray *c2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_buffListTableView(==containerView)]" options:ops metrics:metrics views:bindings];
    [constraints addObjectsFromArray:c1];
    [constraints addObjectsFromArray:c2];
    [NSLayoutConstraint activateConstraints:constraints];
    
    [_buffListTableView setDelegate:self];
    [_buffListTableView setDataSource:self];
    
    CATransform3D t=CATransform3DIdentity;
    t.m34=-1.0/1000;
    t=CATransform3DRotate(t,1.0,0,1,0);
//    [self.navigationController.view.layer setTransform:t];
    [self.navigationController.view.layer setShouldRasterize:YES];
    [self.navigationController.view.layer setRasterizationScale:2.0];
    UIButton *leftBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [leftBtn setTitle:@"左侧" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithHex:0x1bd1a5 alpha:1] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    UIButton *rightBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [rightBtn setTitle:@"右侧" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithHex:0xf36838 alpha:1] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [self.navigationItem setRightBarButtonItem:rightItem];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Actions
-(void)leftAction:(UIButton *)sender
{
    [RootSplitBuff showLeftViewController];
}
-(void)rightAction:(UIButton *)sender
{
    [RootSplitBuff showRightViewController];

}
#pragma mark table delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    [cell.textLabel setText:@"🔜"];
    [cell.detailTextLabel setText:@""];
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"加解密(CryptoBuff.h)"];
            [cell.detailTextLabel setText:@"MD5,SHA1,SHA2,AES,DES,3DES,BLOWFISH"];
            break;
        case 1:
            [cell.textLabel setText:@"坐标纠偏(LBSBuff.h)"];
            [cell.detailTextLabel setText:@"算法来源:http://emq.googlecode.com/svn/emq/src/Algorithm/Coords/Converter.java"];
            break;
        case 2:
            [cell.textLabel setText:@"轮播图(BFLoopView.h)"];
            [cell.detailTextLabel setText:@"基于CADisplayLink+NSTimer+UIScrollView实现"];
            break;
        default:
            break;
    }
    [cell bf_setAnnotation:cell.detailTextLabel.text];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            CryptoBuffViewController *cryptoVC=[[CryptoBuffViewController alloc]init];
            [self.navigationController pushViewController:cryptoVC animated:YES];
        }
            break;
        case 1:
        {
            LBSBuffViewController *lbsVC=[[LBSBuffViewController alloc]init];
            [self.navigationController pushViewController:lbsVC animated:YES];
        }
            break;
        case 2:
        {
            LoopViewController *loopVC=[[LoopViewController alloc]init];
            [self.navigationController pushViewController:loopVC animated:YES];
        }
            break;
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.width,40)];
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setText:@"长按Cell显示注释(CellBuff)"];
    [label setTextColor:[UIColor colorWithHex:0xb35c44 alpha:1]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightLight]];
    return label;
}
@end
