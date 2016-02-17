//
//  MyAlertViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 16/1/8.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import "MyAlertViewController.h"

@interface MyAlertViewController ()

@end

@implementation MyAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [super alertControllerWithTitle:title message:message preferredStyle:preferredStyle];;
}


#pragma mark - 代码切换横屏
- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}


@end
