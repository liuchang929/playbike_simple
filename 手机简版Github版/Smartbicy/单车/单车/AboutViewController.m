//
//  AboutViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 16/1/18.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import "AboutViewController.h"
#import "CurrentAccount.h"
#import "MobClick.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"RunRunFast";
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"关于页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"关于页面"];
}

-(void)back
{
    CurrentAccount * current = [CurrentAccount sharedCurrentAccount];
    current.page = 4;
    [self performSegueWithIdentifier:@"aboutBack" sender:nil];
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
