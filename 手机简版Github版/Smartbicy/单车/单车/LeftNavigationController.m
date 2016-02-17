//
//  LeftNavigationController.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-15.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "LeftNavigationController.h"
#import "CurrentAccount.h"

@interface LeftNavigationController ()

@end

@implementation LeftNavigationController{
    CurrentAccount *_currentAccount;
    BOOL _isGuest;
}


//登陆的时候
- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.headImage.layer.masksToBounds = YES;
    //NSLog(@"HIGHT = %f, WIGHR = %f",self.headImage.frame.size.height,self.headImage.frame.size.width);
    self.headImage.layer.cornerRadius = self.headImage.frame.size.width/2;
    _headImage.layer.masksToBounds = YES;
    
    //载入当前账户信息
 //   [self loadCurrentAccount];
    
    //初始化用户信息
 //   [self initUserInfo];
    
    //按钮是否可点击设置
 //   [self buttonSetting];
}

//- (void)viewWillAppear:(BOOL)animated{
//    //屏幕适配布局
//    [self UILayout];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
