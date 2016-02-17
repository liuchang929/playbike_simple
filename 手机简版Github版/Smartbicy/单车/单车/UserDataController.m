//
//  UserDataController.m
//  单车
//
//  Created by comfouriertech on 14-6-4.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "UserDataController.h"
#import "UserData.h"
#import "AFNetworking.h"
#import "CurrentAccount.h"
#import "TBActivityIndicatorView.h"
#import "TrainingModeViewController.h"
#import "MobClick.h"

#define kNumberOfAccount 4

@interface UserDataController (){
    
    CurrentAccount *currentAccount;
    
    //登录、获取信息的返回值
    int _retLogin;
    int _retInfo;
    //用户信息是否全标识量
    BOOL isInfoEmpty;
    
    //提示框
    TBActivityIndicatorView *_tbActivityIndicatorView;
    
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
    //微信用户
    NSString *_userWechat;
    NSString *_headImgURL;
}

@end

@implementation UserDataController 

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [self initWeChat];
    
    currentAccount = [CurrentAccount sharedCurrentAccount];
    
    
    //初始化TB菊花框
    [self inittBActivityIndicatorView];
    
    TBAppDelegate *appDelegate = (TBAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.delegate = self;
    
    [self getServerUrl];
    
    [_nameLabel setValue:_nameLabel.textColor forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordLabel setValue:_nameLabel.textColor forKeyPath:@"_placeholderLabel.textColor"];

}

- (void)back:(id)sender {
    [self performSegueWithIdentifier:@"登录" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"登录页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"登录页面"];
}

#pragma mark - 自动登录
-(void)autoLoginFunc
{
    //轻量级数据读取
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * name = [defaults objectForKey:@"account"];
    NSString * password = [defaults objectForKey:@"pwd"];
    
    if ([name integerValue] == 0)return;
    
    //先获取用户名
    self.nameLabel.text = [defaults objectForKey:@"account"];//可以讲key定义为宏
    self.passwordLabel.text = [defaults objectForKey:@"pwd"];
    
//    //根据用户是否设置保存密码、自动登陆去进行操作
//    self.remPassword.on = [defaults boolForKey:@"pwdBtn"];
//    if (self.remPassword.on) {
//        self.passwordLabel.text = [defaults objectForKey:@"pwd"];
//    }else{
//        self.passwordLabel.text = nil;
//    }
//    self.autoLgin.on = [defaults boolForKey:@"loginBtn"];
//    if ( self.autoLgin.on) {
//        [self submitRegister:nil] ;
//    }
}

#pragma  mark - 获取服务器
- (void)getServerUrl
{
    //测试版
    //NSString *urlString = [NSString stringWithFormat:@"http://bikemeurl.duapp.com/servlet/Url?url=test"];
    //发布版
    NSString *urlString = [NSString stringWithFormat:@"http://bikemeurl.duapp.com/servlet/Url"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        
        if (ret == 1) {
            currentAccount.serverName = [dictionary objectForKey:@"url"];
            [self autoLoginFunc];
            
        }else{
            //[self showAlertWithString:@"网络异常"];
            currentAccount.serverName = @"bikeme.duapp.com";
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@", error);
        [_tbActivityIndicatorView removeFromSuperview];
        [self showAlertWithString:@"网络异常"];
        currentAccount.serverName = @"bikeme.duapp.com";
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 微信登陆
- (void)initWeChat
{
//    //判断微信有没有安装
//    if ([WXApi isWXAppInstalled]) {
//        //已经安装微信
//        self.wechatOutlet.hidden = NO;
//    }
}

- (IBAction)wechatAction:(id)sender {
    [self sendAuthRequest];
}

-(void)sendAuthRequest
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}



#pragma mark - TB加载框初始化
- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"登录中"];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //点击空白，释放键盘
    [self.nameLabel resignFirstResponder];
    [self.passwordLabel resignFirstResponder];
}

#pragma mark - 释放键盘
- (void)resignKeyboard
{
    [self.nameLabel resignFirstResponder];
    [self.passwordLabel resignFirstResponder];
}

//跳转到注册界面
- (IBAction)clickRegister:(id)sender {
    [self performSegueWithIdentifier:@"clickRegister" sender:nil];
}



//return 关闭第一响应
- (IBAction)textFieldReturnEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - 登录
- (IBAction)submitRegister:(UIButton *)sender {
    //释放键盘
    [self resignKeyboard];
    
    //弹出提示框
     [self.view addSubview:_tbActivityIndicatorView];
//    [_indicatorView startAnimating];
    
    _userData.name = _nameLabel.text;
    _userData.password = _passwordLabel.text;
    
    //获取用户输入的登录信息
    NSString *name =_nameLabel.text;
    NSString *pwd = _passwordLabel.text;
    //保存偏好设置信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //1.账号
    [defaults setObject:_nameLabel.text forKey:@"account"];
    //2.密码
    [defaults setObject:_passwordLabel.text forKey:@"pwd"];
    //3.是否自动登录
    [defaults setBool:_remPassword.on forKey:@"pwdBtn"];
    //4.是否记住密码
    [defaults setBool:_autoLgin.on forKey:@"loginBtn"];
    [defaults synchronize];

    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=login&username=%@&password=%@",currentAccount.serverName, name, pwd];
    NSLog(@"登陆 = %@", urlString);
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
                [self showAlertWithString:@"登录失败"];
                break;
            case 1:
                //如果登录成功，下载个人信息，并根据信息状况跳转视图
                [self loadInfoAndSaving];
                [_tbActivityIndicatorView removeFromSuperview];
                
                self.autoLgin.on = [defaults boolForKey:@"loginBtn"];
                [self showAlertWithDelegateWithString:@"登录成功"];
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

#pragma mark - 下载个人信息并保存本地
- (void)loadInfoAndSaving
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/PersonalInfoCheckOut",currentAccount.serverName];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        //解析数据
        _retInfo = [[dictionary objectForKey:@"ret"] intValue];
        NSArray *content = [dictionary objectForKey:@"content"];
        NSDictionary *myDictionary = [content lastObject];
        //从服务器读取个人信息读取
        _userBirthday = [myDictionary objectForKey:@"userBirthday"];
        _userSex = [myDictionary objectForKey:@"userSex"];
        _userNickName = [myDictionary objectForKey:@"userNickName"];
        _userHeight = [myDictionary objectForKey:@"userHeight"];
        _userWeight = [myDictionary objectForKey:@"userWeight"];
        _userHeadID = [myDictionary objectForKey:@"userHeadId"];
        _userHRMax = [myDictionary objectForKey:@"userHRmax"];
        _userName = [myDictionary objectForKey:@"userName"];
        _userCity = [myDictionary objectForKey:@"user_city"];
        _userDeclaration =[myDictionary objectForKey:@"user_declaration"];
        _userWechat = [myDictionary objectForKey:@"isWeChat"];
        _headImgURL = [myDictionary objectForKey:@"wechatheadurl"];
        
        //判断用户信息是否为空,从而决定跳入“信息设置”还是“欢迎”界面
        //NSLog(@"myDic --> %@", myDictionary);
        //NSLog(@"_userWeight --> %@", _userWeight);
        
        if (_userWeight == nil) {
            //NSLog(@"检测到为空");
            isInfoEmpty = YES;
        }else{
            //NSLog(@"检测非空");
            isInfoEmpty = NO;
        }
        
        /*
        if (_retInfo == -3) {
            isInfoEmpty = YES;
        }else{
            isInfoEmpty = NO;
        }
         */
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@",error);
        [_tbActivityIndicatorView removeFromSuperview];
        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        [self showAlertWithString:@"网络异常"];

        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}


#pragma mark - alertView 代理方法
#pragma mark 点击按钮后
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loginSuccess];
}

-(void)loginSuccess
{
    //非微信登陆的用户
    currentAccount.userBirthday = _userBirthday;
    currentAccount.userSex = _userSex;
    currentAccount.userNickName = _userNickName;
    currentAccount.userHeight = _userHeight;
    currentAccount.userWeight = _userWeight;
    currentAccount.userHeadID = _userHeadID;
    currentAccount.userName = _nameLabel.text;
    currentAccount.userPassword = _passwordLabel.text;
    currentAccount.userCity = _userCity;
    currentAccount.userDeclaration = _userDeclaration;
    
    currentAccount.isWeChat = _userWechat;
    currentAccount.headimgurl = _headImgURL;

    
    if (isInfoEmpty) {
        currentAccount.infoEmpty = YES;
        //如果信息空，跳入信息设置界面
        [self performSegueWithIdentifier:@"登录无信息" sender:nil];
    }else{
        //如果不空，跳入欢迎界面  trainMode
        currentAccount.infoEmpty = NO;
        [self performSegueWithIdentifier:@"trainStart" sender:nil];
    }
}


#pragma mark - 微信登陆

- (void)respBegin
{
    //开始请求，弹出菊花框
    [self.view addSubview:_tbActivityIndicatorView];
}

#pragma mark 获取了微信数据，保存在currentAccount中
- (void)didGetUnion
{
    //NSLog(@"didGet");
    //下载保存微信头像
    [self saveWeChatHead];
    [self loginWithUnionid:currentAccount.unionid];
}

- (void)saveWeChatHead
{
    UIImage *headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentAccount.headimgurl]]];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // If you go to the folder below, you will find those pictures

    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir, currentAccount.unionid];
    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(headImage)];
    [data1 writeToFile:pngFilePath atomically:YES];
    
    //    NSLog(@"saving jpeg");
    //    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/test.jpeg",docDir];
    //    NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
    //    [data2 writeToFile:jpegFilePath atomically:YES];
    
}

- (void)loginWithUnionid:(NSString *)unionid
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=login&username=%@&password=%@",currentAccount.serverName, unionid, unionid];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        int retLogin = [[dictionary objectForKey:@"ret"] intValue];
        
        /*
         *return
         *用户名为空：{“ret”: -3}
         *密码为空：  {“ret”: -4}
         *登录成功：{“ret”:1,”login”:”success”}
         *登录失败：{“ret”:-5}
         */
        //对服务器返回数据进行判断
        //NSLog(@"login ret --> %d", retLogin);
        if (retLogin == 1) {
            //账户登陆成功，说明不是第一次登陆
            [self loadInfoAndSaving];
            [_tbActivityIndicatorView removeFromSuperview];
            [self showAlertWithDelegateWithString:@"登录成功"];
        }else{
            //账号登陆失败，帮用户进行注册、登陆
            [self registerWithUnionid:unionid];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@",error);
        //[_backgroudView removeFromSuperview];
        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        [self showAlertWithString:@"网络异常"];

        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    
}

- (void)registerWithUnionid:(NSString *)unionid
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=register&username=%@&password=%@", currentAccount.serverName,unionid, unionid];
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
        /*
         switch (ret) {
         case -3:
         [_backgroudView removeFromSuperview];
         [self showAlertWithString:@"用户名为空"];
         break;
         case -4:
         [_backgroudView removeFromSuperview];
         [self showAlertWithString:@"密码为空"];
         break;
         case -6:
         [_backgroudView removeFromSuperview];
         [self showAlertWithString:@"用户名已存在"];
         break;
         case -7:
         [_backgroudView removeFromSuperview];
         [self showAlertWithString:@"注册失败"];
         break;
         case 1:
         [_backgroudView removeFromSuperview];
         [self showAlertWithDelegateWithString:@"注册成功"];
         break;
         }
         */
        
        if (ret == 1) {
            //注册成功，进行登陆
            [self loginWithUnionid:unionid];
        }else{
            //注册失败
            //移除菊花框
            [_tbActivityIndicatorView removeFromSuperview];
            //提示用户网络繁忙
            [self showAlertWithString:@"网络繁忙"];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@",error);
        [_tbActivityIndicatorView removeFromSuperview];
        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        [self showAlertWithString:@"网络异常"];

        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (IBAction)remPwdBn:(id)sender {
    if (self.remPassword.isOn == NO) {
        [self.autoLgin setOn:NO animated:YES];
        
    }

}
- (IBAction)autoLoginBtn:(id)sender {
    if (self.autoLgin.isOn == YES) {
        [self.remPassword setOn:YES animated:YES];
    }
}

#pragma mark - 注册
- (IBAction)register:(id)sender {
   [self performSegueWithIdentifier:@"clickRegister" sender:nil];
}
#pragma mark - 忘记密码
- (IBAction)forgetPassWord:(id)sender {
    //[self showAlertWithString:@"该功能暂未开放"];
    [self performSegueWithIdentifier:@"forget" sender:nil];
}

@end







