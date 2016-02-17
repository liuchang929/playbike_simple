//
//  MyAccountViewController.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-25.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "MyAccountViewController.h"
#import "CurrentAccount.h"
#import <AFNetworking.h>
#import "TBActivityIndicatorView.h"

@interface MyAccountViewController (){
    
    //提示框
    TBActivityIndicatorView *_tbActivityIndicatorView;
    
    //当前账户
    CurrentAccount *_currentAccount;
}


@end

@implementation MyAccountViewController
#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
//                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.myAccountButton.titleLabel setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:17.0f]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.myAccountButton.titleLabel setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:10.0f]];
    }
    [self initViewData];
    [self inittbActivityIndicatorView];
}

- (void)didReceiveMemoryWarning
{
   
    [super didReceiveMemoryWarning];
}

#pragma mark - Action
#pragma mark “返回登陆界面”按钮  我的账户界面的返回登陆界面的按钮响应事件
#pragma mark "此处是注销按钮的响应事件"
- (IBAction)logout:(UIButton *)sender {
    
    if (_currentAccount.guestAccount) {
        [self performDestinationView];
    }
    else{
        //即将开始网络服务，弹出tb菊花框， 在ViewDidLoad中已经加载完成
        [self.view addSubview:_tbActivityIndicatorView];
        
        NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=logout",[[CurrentAccount sharedCurrentAccount] serverName]];
        //有中文，需要转换
        //    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];

        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *dictionary = responseObject;
            int ret = [[dictionary objectForKey:@"ret"] intValue];
            /*
             * return
             *{“ret”: 1} 注销成功
             * {“ret”:-2}注销失败
             */
            //对服务器返回数据进行判断
            switch (ret) {
                case 1:
                    [self performDestinationView];
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithDelegateWithString:@"注销成功"];
                    break;
                case -2:
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithString:@"注销失败"];
                    break;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Error: %@",error);
            [_tbActivityIndicatorView removeFromSuperview];
            [self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
            
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    }
}

#pragma mark 返回
- (IBAction)back:(id)sender {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    [self presentViewController:(UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"] animated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TB加载框初始化
- (TBActivityIndicatorView *)inittbActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"注销中"];
    return _tbActivityIndicatorView;
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

#pragma mark - 注销后的跳转界面
- (void)performDestinationView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self presentViewController:(UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"login"] animated:YES completion:nil];
}

#pragma mark - 初始化界面UI信息
- (void)initViewData
{
    _currentAccount = [CurrentAccount sharedCurrentAccount];
    
    if (_currentAccount.guestAccount) {//游客账户
        //头像
        [self.headPhoto setImage:[UIImage imageNamed:@"guest.png"]];
        
        //未登录状态下提示语句
        self.myAccountLabel.text = @"您尚未登录，登录后可同步运动数据到云端";
        
        //未登录状态下按钮标题
        [self.myAccountButton setTitle:@"返回登录界面" forState:UIControlStateNormal];
        
    }
    
    else{//用户账户
        
        //头像
        NSString *imageName = [NSString stringWithFormat:@"head%02d.png", [_currentAccount.userHeadID intValue]];
        UIImage *headImage = [UIImage imageNamed:imageName];

        [self.headPhoto setImage:headImage];
        
        if ([_currentAccount.weChatAccount isEqualToString:@"YES"]) {
            //微信用户
            //NSLog(@"left isWeChat");
            //headName = _currentAccount.weChatImagePath;
            //NSLog(@"headName --> %@", headName);
            self.headPhoto.layer.masksToBounds = YES; //周围的白色边边
            self.headPhoto.layer.cornerRadius = self.headPhoto.frame.size.width/2; //设置圆形半径
            self.headPhoto.clipsToBounds = YES;
            self.headPhoto.image = [UIImage imageWithContentsOfFile:_currentAccount.weChatImagePath];
        }

        
        //用户名
        self.myAccountLabel.text = [NSString stringWithFormat:@"我的账户：%@", _currentAccount.userName];
    }
}


@end
