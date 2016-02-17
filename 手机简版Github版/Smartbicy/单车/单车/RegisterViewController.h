//
//  RegisterViewController.h
//  单车
//
//  Created by comfouriertech on 14-6-5.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *registerName;
@property (weak, nonatomic) IBOutlet UITextField *registerPassword1;
@property (weak, nonatomic) IBOutlet UITextField *registerPassword2;

- (IBAction)clickRegister:(UIButton *)sender;

- (IBAction)textFieldReturnEditing:(id)sender;
- (IBAction)back:(id)sender;

//验证按钮
@property (weak, nonatomic) IBOutlet UIButton *verNum;
- (IBAction)getVerNumber:(id)sender;

@end
