//
//  BuffListViewController.m
//  BuffDemo
//
//  Created by BoWang on 16/5/5.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "BuffListViewController.h"
#import "CryptoBuffViewController.h"
#import "LBSBuffViewController.h"

@interface BuffListViewController ()

@end

@implementation BuffListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //sidebar

    buffListTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
    [buffListTableView setDelegate:self];
    [buffListTableView setDataSource:self];
    [self.view addSubview:buffListTableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"加解密(CryptoBuff.h)"];
            [cell.detailTextLabel setText:@"MD5,SHA1,SHA2,AES,DES,3DES,BLOWFISH"];
            break;
        case 1:
            [cell.textLabel setText:@"坐标纠偏(LBSBuff.h)"];
            [cell.detailTextLabel setText:@"算法来源:http://emq.googlecode.com/svn/emq/src/Algorithm/Coords/Converter.java"];
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
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightLight]];
    return label;
}
@end
