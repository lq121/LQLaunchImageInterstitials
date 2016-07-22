//
//  ViewController.m
//  LQLaunchImageInterstitials
//
//  Created by v大夫 on 16/7/21.
//  Copyright © 2016年 LQ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.type isEqualToString:@"clcikImage"])
    {
        UIViewController *vc = [[UIViewController alloc]init];
        vc.view.backgroundColor = [UIColor orangeColor];
        vc.title = @"广告VC";
        self.type = nil;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    label.frame = CGRectMake(10, 150, [UIScreen mainScreen].bounds.size.width - 10, 80);
    label.font = [UIFont systemFontOfSize:20];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    label.text = @"欢迎使用LQLaunchImageInterstitials，有任何问题可以相互交流，使用方法请查看readMe文件.";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
