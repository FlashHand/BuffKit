//
//  BuffListViewController.m
//  BuffDemo
//
//  Created by BoWang on 16/5/5.
//  Copyright © 2016年 BoWang. All rights reserved.
//

#import "BuffListViewController.h"
#import "CryptoBuffViewController.h"
@interface BuffListViewController ()

@end

@implementation BuffListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
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
    return 1;
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
            
        default:
            break;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CryptoBuffViewController *cryptoVC=[[CryptoBuffViewController alloc]init];
    [self.navigationController pushViewController:cryptoVC animated:YES];
}

@end
