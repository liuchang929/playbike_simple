//
//  SettingViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/17.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "SettingViewController.h"
#import "AFNetworking.h"
#import "CurrentAccount.h"
#import "MobClick.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic)  UITableView *tableView;

@end

@implementation SettingViewController

//由于自动布局的原因，只有在此处才可以获得真正的宽度
- (void)viewDidLayoutSubviews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_tableView];
    
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [backImage setImage:[UIImage imageNamed:@"设置背景"]];
    [self.tableView setBackgroundView:backImage];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self connectSerVer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"设置页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"设置页面"];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 定义唯一标识
    static NSString *CellIdentifier = @"myCell";
    // 通过唯一标识创建cell实例
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    
    
    if (indexPath.row == 0) {
        //居中添加标签
//        UILabel * myLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, cell.frame.size.height)];
//        myLable.text =@"个人信息";
//        myLable.textAlignment = NSTextAlignmentCenter;
//        [cell addSubview:myLable];
        cell.textLabel.text = @"个人信息";
        cell.textLabel.font = [UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:18];
        cell.textLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView * line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 54, self.view.frame.size.width, 1)];
        [line setImage:[UIImage imageNamed:@"设置分割线.png"]];
        [cell addSubview: line];
    }
    if (indexPath.row == 1) {
//        UILabel * myLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, cell.frame.size.height)];
//        myLable.text =@"关于";
//        myLable.textAlignment = NSTextAlignmentCenter;
//        [cell addSubview:myLable];
        cell.textLabel.text = @"关于";
        cell.textLabel.font = [UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:18];
        cell.textLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView * line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 54, self.view.frame.size.width, 1)];
        [line setImage:[UIImage imageNamed:@"设置分割线.png"]];
        [cell addSubview: line];
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"意见反馈";
        cell.textLabel.font = [UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:18];
        cell.textLabel.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIImageView * line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 54, self.view.frame.size.width, 1)];
        [line setImage:[UIImage imageNamed:@"设置分割线.png"]];
        [cell addSubview: line];
    }
    if (indexPath.row == 3) {
        UILabel * myLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 56)];
        myLable.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:185.0/255.0 blue:19.0/255.0 alpha:1.0];
        myLable.text =@"退出登录";
        myLable.font = [UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:21];
        myLable.textColor = [UIColor whiteColor];//[UIColor colorWithRed:37.0/255.0 green:39.0/255.0 blue:44.0/255.0 alpha:1.0];
        myLable.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:myLable];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"个人信息" sender:nil];
    }
    else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"about" sender:nil];
    }
    else if (indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"feed" sender:nil];
    }
    else if (indexPath.row == 3) {
        [self logout];
    }
}

- (IBAction)logout {
    
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
                [self showAlertWithDelegateWithString:@"注销成功" withTag: 111];
                break;
            case -2:
                [self showAlertWithString:@"注销失败"];
                [self performSegueWithIdentifier:@"退出登录" sender:nil];
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@",error);
        [self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        [self performSegueWithIdentifier:@"退出登录" sender:nil];
        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)showAlertWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

#pragma mark 有代理
- (void)showAlertWithDelegateWithString:(NSString *)string withTag:(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    alertView.tag = tag;
    [alertView show];
}

//退出登录00

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
    currentAccount.isWeChat = @"";
    currentAccount.headimgurl = @"";
    currentAccount.page = 0;
    //保存偏好设置信息, 取消自动登录
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //4.是否记住密码
    [defaults setBool:NO forKey:@"loginBtn"];
    [defaults synchronize];
    [self performSegueWithIdentifier:@"退出登录" sender:nil];
}


@end
