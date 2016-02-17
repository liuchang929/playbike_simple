//
//  MyAccountViewController.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-25.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAccountViewController : UIViewController
- (IBAction)logout:(UIButton *)sender; //实现注销或者登陆后进入MiddleViewcontroller
@property (weak, nonatomic) IBOutlet UILabel *myAccountLabel;
@property (weak, nonatomic) IBOutlet UIButton *myAccountButton; //注销 或者 返回登陆界面按钮
@property (weak, nonatomic) IBOutlet UIImageView *headPhoto;
- (IBAction)back:(id)sender; //返回MianViewcontroller

@end
