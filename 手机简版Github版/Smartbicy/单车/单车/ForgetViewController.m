//
//  ForgetViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/10/27.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "ForgetViewController.h"
#import "TBActivityIndicatorView.h"
#import "AFNetworking.h"
#import "CurrentAccount.h"

#define rettime  60
@interface ForgetViewController ()
{
    CurrentAccount * current;
    TBActivityIndicatorView *_tbActivityIndicatorView;
    
    int resetTimer;
    NSTimer * timer;
    
    BOOL resetPassword;
}

@end

@implementation ForgetViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"重置密码";
    
    //设置返回键
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    //设置placeHoler字体颜色
    [_phoneNum setValue:_phoneNum.textColor forKeyPath:@"_placeholderLabel.textColor"];
    [_varNumTextField setValue:_phoneNum.textColor forKeyPath:@"_placeholderLabel.textColor"];
    [_passWord setValue:_phoneNum.textColor forKeyPath:@"_placeholderLabel.textColor"];
    
    current = [CurrentAccount sharedCurrentAccount];
    
    resetTimer = rettime;
    resetPassword = NO;
}

-(void)back:(UIButton *) button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //点击空白，释放键盘
    [self.phoneNum resignFirstResponder];
    [self.varNumTextField resignFirstResponder];
    [self.passWord resignFirstResponder];
}

#pragma mark - 我要注册
- (IBAction)jumpToRegister:(id)sender {
    [self performSegueWithIdentifier:@"重置密码注册" sender:nil];
}

#pragma mark - 登录
- (IBAction)login:(id)sender
{
    if (resetPassword) {
        //保存偏好设置信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //1.账号
        [defaults setObject:_phoneNum.text forKey:@"account"];
        //2.密码
        [defaults setObject:_passWord.text forKey:@"pwd"];
        
        [defaults synchronize];
        [self performSegueWithIdentifier:@"重置密码登录" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"重置密码登录" sender:nil];
    }
}

//获取验证码
- (IBAction)getVarNum:(id)sender
{
    if(![_phoneNum.text isEqual: @""])
    {
        NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/PhoneRegisterServlet?type=getidentynum&phone=%@", current.serverName,_phoneNum.text];
        NSLog(@"url= %@",urlString);
        //有中文，需要转换
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *dictionary = responseObject;
            BOOL ifphone = [[dictionary objectForKey:@"ifphone"] boolValue];
            BOOL status = [[dictionary objectForKey:@"status"] boolValue];
            
            
            //NSLog(@"dic----%@", dictionary);
            /*
             *return  用户名为空：{“ret”: -3}
             *密码为空：  {“ret”: -4}
             *用户名已存在：{“ret”: -6 , “reg”:”rename”}
             *注册成功：{“ret”:1}
             *注册失败：{“ret”: -7,”register”:”insert err”}
             */
            //对服务器返回数据进行判断
            if (ifphone && status) {
                _varBtn.enabled = NO;
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetTime) userInfo:nil repeats:YES];
            }
            else
            {
                [self showAlertWithString:@"获取验证码失败！请输入正确的手机号码格式"];
                [_varBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showAlertWithString:@"网络异常"];
            
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
        
    }
    
    else
    {
        [self showAlertWithString:@"请输入手机号码"];
    }
}

//更新获取按钮上的文字
-(void)resetTime
{
    if (resetTimer--) {
        [_varBtn setBackgroundImage:[UIImage imageNamed:@"重新获验证码.png"] forState:UIControlStateNormal];
        NSString * titleStr = [NSString stringWithFormat:@"重新发送(%d)",resetTimer];
        [_varBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    else
    {
        resetTimer = rettime;
        [_varBtn setBackgroundImage:[UIImage imageNamed:@"获取验证码.png"] forState:UIControlStateNormal];
        [_varBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        _varBtn.enabled = YES;
        [timer invalidate];
    }
}

- (void)showAlertWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"注册中"];
    [self.view addSubview:_tbActivityIndicatorView];
}

#pragma mark -  确认修改密码
- (IBAction)done:(id)sender {
    
    [self inittBActivityIndicatorView];
    
    if (_phoneNum.text == nil) {
        [_tbActivityIndicatorView removeFromSuperview];
        [self showAlertWithString:@"请输入手机号码"];
    }else{
        if (![self isPhoneNum:_phoneNum.text]) {
            [_tbActivityIndicatorView removeFromSuperview];
            [self showAlertWithString:@"请输入正确手机号码"];
        }else{
            if (_varNumTextField.text.length == 0) {
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithString:@"请输入验证码"];
            }
            else
            {
                /*
                 *注册密码判别
                 */
                if (_passWord.text.length < 6) {
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithString:@"请确保密码长度大于6位"];
                }else{
                    //检索空格
                    if ([self isHasSpace:_passWord.text]) {
                        [_tbActivityIndicatorView removeFromSuperview];
                        [self showAlertWithString:@"密码中不能包含空格"];
                    }else{
                        
                        
                        
                        NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=repassword&username=%@&password=%@&identify=%@",current.serverName,_phoneNum.text, _passWord.text, _varNumTextField.text];
                        NSLog(@"忘记密码url = %@", urlString);
                        //有中文，需要转换
                        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:urlString];
                        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
                        
                        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                        op.responseSerializer = [AFJSONResponseSerializer serializer];
                        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            // NSLog(@"JSON: %@", responseObject);
                            
                            NSDictionary *dictionary = responseObject;
                            int ret = [[dictionary objectForKey:@"ret"] intValue];
                            //                            NSLog(@"ret----%d", ret);
                            /*
                             *return  用户名为空：{“ret”: -3}
                             *密码为空：  {“ret”: -4}
                             *用户名已存在：{“ret”: -6 , “reg”:”rename”}
                             *注册成功：{“ret”:1}
                             *注册失败：{“ret”: -7,”register”:”insert err”}
                             */
                            //对服务器返回数据进行判断
                            switch (ret) {
                                case -8:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"验证码时间过长"];
                                    break;
                                case -9:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"验证码错误"];
                                    break;
                                case -1:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"修改失败"];
                                    break;
                                case 1:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"修改成功，请重新登录"];
                                    resetPassword = YES;
                                    break;
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            //NSLog(@"Error: %@",error);
                            [_tbActivityIndicatorView removeFromSuperview];
                            //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
                            [self showAlertWithString:@"网络异常"];
                            
                        }];
                        [[NSOperationQueue mainQueue] addOperation:op];
                    }
                    
                }
            }
        }
    }
}

#pragma mark 检索空格
- (BOOL)isHasSpace:(NSString *)string
{
    NSString *characterTemp = nil;
    
    for (int i = 0; i <string.length; i++) {
        characterTemp = [string substringWithRange:NSMakeRange(i, 1)];
        
        if ([characterTemp isEqualToString:@" "]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isPhoneNum:(NSString *) string
{
    if(string.length == 11)
    {
        return YES;
    }
    return NO;
}
@end
