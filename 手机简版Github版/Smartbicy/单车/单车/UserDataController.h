//
//  UserDataController.h
//  单车
//
//  Created by comfouriertech on 14-6-4.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXAPP.h"
#import "WXApi.h"
#import "TBAppDelegate.h"

@class UserData;

//@protocol UserDataControllerDelegate <NSObject>
//
//- (void)loginSuccess;
//
//@end

@interface UserDataController : UIViewController<UINavigationControllerDelegate, TBAppDelegateDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;

- (IBAction)submitRegister:(UIButton *)sender;
@property (nonatomic, strong) UserData *userData;
- (IBAction)clickRegister:(id)sender;
- (IBAction)back:(id)sender;

- (IBAction)textFieldReturnEditing:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *wechatOutlet; //微信登陆
- (IBAction)wechatAction:(id)sender;//微信登陆响应事件

@property (weak, nonatomic) IBOutlet UISwitch *remPassword;
- (IBAction)remPwdBn:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *autoLgin;
- (IBAction)autoLoginBtn:(id)sender;

@end
