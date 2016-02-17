//
//  RankViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 16/1/13.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import "RankViewController.h"
#import "CurrentAccount.h"
#import "AFNetworking.h"
#import "MobClick.h"

@interface RankViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self connectSerVer];
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    NSLog(@"%@,%@", [[CurrentAccount sharedCurrentAccount] userName],[[CurrentAccount sharedCurrentAccount] userPassword]);
    NSString * urlString = [NSString stringWithFormat:@"http://bikeme.duapp.com/Rank/Rank1.html?username=%@&password=%@", [[CurrentAccount sharedCurrentAccount] userName],[[CurrentAccount sharedCurrentAccount] userPassword]];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"排名页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"排名页面"];
}

#pragma mark - 用户过每过半个小时重新登录一次
-(void)connectSerVer
{
    //获取用户输入的登录信息
    NSString * name = [[CurrentAccount sharedCurrentAccount] userName];
    NSString * pwd =  [[CurrentAccount sharedCurrentAccount] userPassword];
    //NSLog(@"name = %@ pwd = %@", name, pwd);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=login&username=%@&password=%@",[[CurrentAccount sharedCurrentAccount] serverName],name, pwd];
    
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
            NSLog(@"登陆成功");
        }else{
            //账号登陆失败，帮用户进行注册、登陆
            NSLog(@"登陆失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
        //[_backgroudView removeFromSuperview];
        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        //[self showAlertWithString:@"网络异常"];
        
        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back
{
    [self performSegueWithIdentifier:@"rankBack" sender:nil];
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
