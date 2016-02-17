//
//  RegisterViewController.m
//  单车
//
//  Created by comfouriertech on 14-6-5.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "RegisterViewController.h"
#import "AFNetworking.h"
#import "TBActivityIndicatorView.h"
#import "CurrentAccount.h"
#import "MobClick.h"

#define kNumberOfAccount 4
#define resettime  60

@interface RegisterViewController ()<NSURLConnectionDataDelegate, UIAlertViewDelegate> {
    //提示框
    TBActivityIndicatorView *_tbActivityIndicatorView;
    
    //登录、获取信息的返回值
    int _retLogin;
    int _retInfo;
    //用户信息是否全标识量
    BOOL isInfoEmpty;
    
    
    //用户信息，用于接收服务器个人信息
    NSDictionary *_infoDictionary;
    
    NSString *_userBirthday;
    NSString *_userSex;
    NSString *_userNickName;
    NSString *_userHeight;
    NSString *_userWeight;
    NSString *_userHeadID;
    NSString *_userHRMax;
    NSString *_userName;
    NSString *_userCity;
    NSString *_userDeclaration;
    //NSString *_headimgurl;
    
    //重新获取验证码定时器
    int resetTimer;
    NSTimer * timer;
}
@end

@implementation RegisterViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    resetTimer = resettime;
    
    //初始化TB菊花框
    [self inittBActivityIndicatorView];
    
    _registerName.tintColor = [UIColor whiteColor];
    _registerPassword1.tintColor = [UIColor whiteColor];
    _registerPassword2.tintColor = [UIColor whiteColor];
    
    [_registerName setValue:_registerName.textColor forKeyPath:@"_placeholderLabel.textColor"];
    [_registerPassword1 setValue:_registerName.textColor forKeyPath:@"_placeholderLabel.textColor"];
    [_registerPassword2 setValue:_registerName.textColor forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)back:(id)sender {
    [self performSegueWithIdentifier:@"注册" sender:nil];
}
- (IBAction)haveID:(id)sender {
        [self performSegueWithIdentifier:@"我已有账号" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"注册页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"注册页面"];
}


- (IBAction)deleate:(id)sender {
    [self performSegueWithIdentifier:@"个人信息设置" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TB加载框初始化
- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"注册中"];
}

#pragma mark - 获取验证码
- (IBAction)getVerNumber:(id)sender
{
    if(![_registerName.text isEqual: @""])
    {
        _verNum.enabled = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetTime) userInfo:nil repeats:YES];
        
        NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/PhoneRegisterServlet?type=getidentynum&phone=%@", [[CurrentAccount sharedCurrentAccount] serverName],_registerName.text];
        //NSLog(@"url= %@",urlString);
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
            

            dispatch_async(dispatch_get_main_queue(), ^{
                //对服务器返回数据进行判断
                if (ifphone && status) {
                }
                else
                {
                    [self showAlertWithString:@"获取验证码失败！请输入正确的手机号码格式"];
                    [_verNum setTitle:@"重新获取" forState:UIControlStateNormal];
                }
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Error: %@",error);
            [_tbActivityIndicatorView removeFromSuperview];
            //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
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
        [_verNum setBackgroundImage:[UIImage imageNamed:@"重新获取验证码.png"] forState:UIControlStateNormal];
        NSString * titleStr = [NSString stringWithFormat:@"重新发送(%d)",resetTimer];
        [_verNum setTitle:titleStr forState:UIControlStateNormal];
    }
    else
    {
        resetTimer = resettime;
        [_verNum setBackgroundImage:[UIImage imageNamed:@"获取验证码.png"] forState:UIControlStateNormal];
        NSString * titleStr = [NSString stringWithFormat:@"重新发送"];
        [_verNum setTitle:titleStr forState:UIControlStateNormal];
        _verNum.enabled = YES;
        [timer invalidate];
    }
}





#pragma mark - 注册信息
- (IBAction)clickRegister:(UIButton *)sender
{
    //释放键盘
    [self resignKeyboard];
    
    //弹出提示框
    [self.view addSubview:_tbActivityIndicatorView];
    //获取注册信息
    NSString *name = _registerName.text;
    NSString *pwd1 = _registerPassword1.text;
    NSString *pwd2 = _registerPassword2.text;
    
    /*
     *对注册信息进行检索，判别信息是否合格
     *1.判断用户名是否为空
     *2.判断两次密码是否相同
     *3.判断密码位数是否大于等于6位
     *4.判断密码中是否包含空格
     *5.如果信息合格，get到服务器
     */
    if (name == nil) {
        [_tbActivityIndicatorView removeFromSuperview];
        [self showAlertWithString:@"请输入手机号码"];
    }else{
        if (![self isPhoneNum:name]) {
            [_tbActivityIndicatorView removeFromSuperview];
            [self showAlertWithString:@"请输入正确手机号码"];
        }else{
            if (pwd1.length == 0) {
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithString:@"请输入验证码"];
            }
            else
            {
                /*
                 *注册密码判别
                 */
                if (pwd2.length < 6) {
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithString:@"请确保密码长度大于6位"];
                }else{
                    //检索空格
                    if ([self isHasSpace:pwd1]) {
                        [_tbActivityIndicatorView removeFromSuperview];
                        [self showAlertWithString:@"密码中不能包含空格"];
                    }else{
                        
                        NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=register&username=%@&password=%@&identify=%@",[[CurrentAccount sharedCurrentAccount] serverName],name,pwd2,pwd1];
                        NSLog(@"注册url = %@", urlString);
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
                                    /*
                                     注册成功后显示：		{"ret":1,"register":"success"}
                                     用户名为空显示：		{"ret":-3 }
                                     密码为空显示：		{"ret":-4}
                                     用户名己存在：		{"ret":-6,"register":"rename"}
                                     该手机己被绑定：     {“ret”: -4 , “reg”:”rename”}
                                     
                                     
                                     验证码错误：			{"ret":-9,"rep":"…"}
                                     验证码时间过长：		{"ret":-8,"rep":"…"}
                                     注册失败，重新获取：	{"ret":-7,"register":"insert err"}
                                     */
                                    
                                case -4:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"该手机已被绑定"];
                                    break;
                                case -6:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"用户名存在"];
                                    break;
                                case -9:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"验证码错误"];
                                    break;
                                case -7:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    [self showAlertWithString:@"注册失败"];
                                    break;
                                case 1:
                                    [_tbActivityIndicatorView removeFromSuperview];
                                    
                                    //注册成功之后登陆
                                    [self registerlogin];
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


#pragma mark - 注册成功后登录
-(void)registerlogin {
    //释放键盘
    [self resignKeyboard];
    
    //弹出提示框
    [self.view addSubview:_tbActivityIndicatorView];
    //    [_indicatorView startAnimating];
    
    
    
    //获取用户输入的登录信息
    NSString *name =_registerName.text;
    NSString *pwd = _registerPassword2.text;
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=login&username=%@&password=%@", [[CurrentAccount sharedCurrentAccount] serverName],name, pwd];
    //NSLog(@"urlString = %@", urlString);
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        _retLogin = [[dictionary objectForKey:@"ret"] intValue];
        
        /*
         *return
         *用户名为空：{“ret”: -3}
         *密码为空：  {“ret”: -4}
         *登录成功：{“ret”:1,”login”:”success”}
         *登录失败：{“ret”:-5}
         */
        //对服务器返回数据进行判断
        switch (_retLogin) {
            case -3:
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithString:@"用户名为空"];
                break;
            case -4:
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithString:@"密码为空"];
                break;
            case -5:
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithString:@"注册成功，但登录失败，请重新登录"];
                break;
            case 1:
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithDelegateWithString:@"登录成功,请完善个人资料"];
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

#pragma  mark - 向单例里 保存用户注册的 userName 和 密码
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    currentAccount.userBirthday = @"";
    currentAccount.userSex = @"";
    currentAccount.userNickName = @"";
    currentAccount.userHeight = @"";
    currentAccount.userWeight = @"";
    currentAccount.userHeadID = @"";
    currentAccount.userName = @"";
    currentAccount.userPassword = @"";
    currentAccount.userCity = @"";
    currentAccount.userDeclaration = @"";
    [self performSegueWithIdentifier:@"个人信息设置" sender:nil];
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

#pragma mark - 警告框
#pragma mark 无代理
- (void)showAlertWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

#pragma mark 有代理
- (void)showAlertWithDelegateWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}
#pragma mark - 释放键盘
- (void)resignKeyboard
{
    [self.registerName resignFirstResponder];
    [self.registerPassword1 resignFirstResponder];
    [self.registerPassword2 resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //点击空白，释放键盘
    [self resignKeyboard];
}

- (IBAction)textFieldReturnEditing:(id)sender
{
    [sender resignFirstResponder];
}


@end
