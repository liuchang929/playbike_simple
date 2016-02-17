//
//  WeekPlanViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/20.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "WeekPlanViewController.h"
#import "CurrentAccount.h"
#import "AFNetworking.h"
#import "TBActivityIndicatorView.h"
#import "MobClick.h"

@interface  WeekPlanViewController()
{
    CurrentAccount * currentAccount;
    //TB菊花框
    TBActivityIndicatorView *_tbActivityIndicatorView;
}
@end

@implementation WeekPlanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
//                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];

    [self connectSerVer];

    [self inittBActivityIndicatorView];
    //先隐藏周计划
    _planView.hidden = YES;
    //用户先不能输入
    _aimText.enabled = NO;
    
    _aimPicker = [[UIPickerView alloc] init];
    _aimPicker.dataSource = self;
    _aimPicker.delegate = self;
    [_aimText setInputView:_aimPicker];
    
    
    currentAccount = [CurrentAccount sharedCurrentAccount];
    _dataChoose = [[NSArray alloc] initWithObjects:@"0",@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100",@"110",@"120",@"130",@"140",@"150", nil];
    
    
    [self loadWeekPlanRestart];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"周计划页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"周计划页面"];
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


#pragma mark - TB加载框初始化
- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"获取中"];
}

//计算今天星期几
-(NSInteger)weekNow:(NSDate*)date
{
    NSInteger week;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps = [calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit) fromDate:date];
    /*
     周日： 1
     周一： 2
     */
    week = [comps weekday];
    return week;
}

//计算两个日期之间的天数之差
-(int)dateSub:(NSDate*) now setTime:(NSDate*) setTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlag = NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlag fromDate:setTime toDate:now options:0];
    int days = [components day];
    return days;
}


#pragma mark - 获取周计划的相关数据

//获取周计划是否需要重置
- (void)loadWeekPlanRestart
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/WeekPlan?type=lastdate",currentAccount.serverName];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"获取设置周计划的日期: %@", responseObject);
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        if (ret == 1) {
            
            [self.view addSubview:_tbActivityIndicatorView];
            
            //获取上次设置周计划的时间
            currentAccount.lastWeekPlanDate = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"lastdate"]];
            NSDate * now = [NSDate date];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"yyyyMMdd"];
            
            //把 NSString::currentAccount.lastWeekPlanDate -> NSDate
            NSDate *lastWeekDate = [formatter dateFromString:currentAccount.lastWeekPlanDate];
            int distanceNextMonday = 0; //差多少天一周
            /*
             计算星期几设置的， 并且计算出距离下一个星期一还需要多长时间
             重新开始计数，
             只要当前时间与上一次保存数据的时间相差一个星期，但不超过两个星期就更新数据
             */
            switch ([self weekNow:lastWeekDate]) {
                case 1:
                    distanceNextMonday = 1;
                    break;
                case 2:
                    distanceNextMonday = 7;
                    break;
                case 3:
                    distanceNextMonday = 6;
                    break;
                case 4:
                    distanceNextMonday = 5;
                    break;
                case 5:
                    distanceNextMonday = 4;
                    break;
                case 6:
                    distanceNextMonday = 3;
                    break;
                case 7:
                    distanceNextMonday = 2;
                    break;
            }
            int daySub = [self dateSub:now setTime:lastWeekDate];
            //NSLog(@"daySub = %d",daySub);
            /*
             用户在下个星期的每一天都是可以更新数据的
             */
            if (  daySub > distanceNextMonday -1 && daySub < 8 && daySub != 0 )
            {
                NSLog(@"下一周更新周计划了！");
                //该是更新周计划的时间了
                currentAccount.restartWeekPlan = YES;
                //想服务器发送更新周计划
                [self restartWeekPlan];
            }
            //如果不用更新周计划的话，重新获取数据
            else
            {
                [self loadWeekPlanData];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error网络异常: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

//重置周计划
- (void)restartWeekPlan
{
    NSDate * date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * dateStr = [formatter stringFromDate:date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/WeekPlan?type=restart&date=%@",currentAccount.serverName,dateStr];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"重置周计划 JSON: %@", responseObject);
        NSDictionary *dictionary = responseObject;
        if ([[dictionary objectForKey:@"ret"] intValue] == 1) {
            [self loadWeekPlanData];
            NSLog(@"重置周计划实现完成");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error网络异常: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}



//获取周计划公里数
- (void)loadWeekPlanData
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/WeekPlan?type=gettarget",currentAccount.serverName];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"获取周计划公里数 JSON: %@", responseObject);
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        if (ret == 1) {
            currentAccount.aimText = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"target"]];
            
            //判断用户是否设置了周计划
            if ([currentAccount.aimText intValue] != 0) {
                currentAccount.setWeekPlan = YES;
                
                //用户设置了周计划之后才会获取相关的数据(本周完成，上周完成，近五周百分比)
                [self loadWeekPlanDoneData];
                [self loadWeekPlanDone];
                [self loadWeekPlanDonePercent];
                
                
            }
            // 用户没有设置周计划，隐藏响应的周计划标蓝
            else if([currentAccount.aimText intValue] == 0 )
            {
                currentAccount.setWeekPlan = NO;
                [_tbActivityIndicatorView removeFromSuperview];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showSettingAlert];
//                });
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error网络异常: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

//获取周计划完成公里数
- (void)loadWeekPlanDoneData
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/WeekPlan?type=gettotal",currentAccount.serverName];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"获取周计划完成公里数 JSON: %@", responseObject);
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        if (ret == 1) {
            currentAccount.doneText = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"total"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error网络异常: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

//获取前一周的完成量
- (void)loadWeekPlanDone
{
    NSString *urlString = [NSString stringWithFormat:@"Http://%@/servlet/WeekPlan?type=getlasttotal",currentAccount.serverName];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取前五周的完成百分比 JSON: %@", responseObject);
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        if (ret == 1) {
            NSString * precent = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"donerate"]];
            //NSLog(@"precent = %@",precent);
            if (precent) {
                //NSLog(@"precent = %@",precent);
                currentAccount.lastWeekDone = [NSString stringWithFormat:@"%f",[precent floatValue]];
            }
            else
            {
                currentAccount.lastWeekDone = @"0.0";
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error网络异常: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}


//获取前五周的完成百分比
- (void)loadWeekPlanDonePercent
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/WeekPlan?type=donerate",currentAccount.serverName];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"获取前五周的完成百分比 JSON: %@", responseObject);
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        if (ret == 1) {
            NSString * precent = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"donerate"]];
            
            if (precent) {
                
                currentAccount.lastWeekPercent = [NSString stringWithFormat:@"%0.0f%%",[precent floatValue] * 100.00];
            }
            else
            {
                currentAccount.lastWeekPercent = @"0%";
            }
            // NSLog(@"currentAccount.lastWeekPercent = %@",currentAccount.lastWeekPercent);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createUI];
            });
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error网络异常: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}




#pragma mark - 开始显示周计划数据
-(void)createUI
{
    [_tbActivityIndicatorView removeFromSuperview];
    _aimText.enabled = NO;
    
    if ([currentAccount.aimText intValue]) {
        
        _planView.hidden = NO;
        //开始显示周计划数据
        //NSLog(@"%@,%@,%@",currentAccount.aimText,currentAccount.doneText,currentAccount.remainText);
        _aimText.text = [NSString stringWithFormat:@"%d",[currentAccount.aimText intValue]/1000];
        _doneText.text = [NSString stringWithFormat:@"%0.1f",[currentAccount.doneText floatValue]/1000.0];
        _donePercent.text = [NSString stringWithFormat:@"%1.0f%%",([currentAccount.doneText floatValue] / [currentAccount.aimText floatValue])*100.0];
        // NSLog(@"currentAccount.lastWeekPercent = %@",currentAccount.lastWeekPercent);
        _lastWeekDone.text = [NSString stringWithFormat:@"%0.1f",[currentAccount.lastWeekDone floatValue]/1000.0];
        _lastWeekPercent.text = currentAccount.lastWeekPercent;
    }
    else
    {
        _planView.hidden = YES;
        
    }
}

#pragma mark- 设置pickView数据
//一共多少列
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//每列对应多少行
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataChoose count];
}
//每列每行对应显示的数据是什么
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_dataChoose objectAtIndex:row];
}
//设置每行的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;
{
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *stringText = [self pickerView:pickerView titleForRow:row forComponent:component];
    UILabel *stringLabel = [[UILabel alloc] init];
    stringLabel.font = [UIFont systemFontOfSize:25.0];
    stringLabel.text = stringText;
    stringLabel.textAlignment = NSTextAlignmentCenter;
    return stringLabel;
}

#pragma mark 当选择时
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    NSLog(@"选择");
    if (pickerView == _aimPicker) {
        _aimText.text = _dataChoose[row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark- 将用户设定的数据持久化 (保存/重置)
-(void)upload:(NSString *)string
{
    string = [NSString stringWithFormat:@"%d",[string intValue]*1000];
    NSDate * date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * dateStr = [formatter stringFromDate:date];
    //NSLog(@"now = %@",dateStr);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/WeekPlan?type=setplan&target=%@&date=%@",currentAccount.serverName,string,dateStr];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        
        if(ret == 1)
        {
            UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"提示" message:@"周计划设定成功！" delegate:nil cancelButtonTitle:@"确定"otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"提示" message:@"网络不好，周计划设定失败！" delegate:nil cancelButtonTitle:@"确定"otherButtonTitles: nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView * alert =[[UIAlertView alloc] initWithTitle:@"提示" message:@"网络不好，周计划设定失败！" delegate:nil cancelButtonTitle:@"确定"otherButtonTitles: nil];
        [alert show];
        NSLog(@"Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark -保存按钮
- (IBAction)settingWeekPlan:(id)sender
{
    UIButton * btn = (UIButton *) sender;
    //编辑周计划
    if([btn.titleLabel.text isEqualToString:@"编辑"])
    {
       
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        _aimText.enabled = YES;
        [_aimText becomeFirstResponder];
    }
    
    //保存周计划
    else if([btn.titleLabel.text isEqualToString:@"保存"])
    {
        [self.view endEditing:YES];
        [_saveBtn setTitle:@"编辑" forState:UIControlStateNormal];
        //存储数据
        NSString * aimText = _aimText.text;
        [self upload:aimText];
        
        if([currentAccount.aimText intValue]== 0)
        {
            [self.view addSubview:_tbActivityIndicatorView];
            currentAccount.aimText =[NSString stringWithFormat:@"%f", [aimText floatValue] * 1000.0];
            [self loadWeekPlanRestart];
            [self performSelector:@selector(createUI) withObject:sender afterDelay:1.0];
        }
        
        else
        {
            currentAccount.aimText =[NSString stringWithFormat:@"%f", [aimText floatValue] * 1000.0];
            [self createUI];
            NSLog(@"aimText = %@",aimText);
        }

    }
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"周计划设置完成" sender:nil];
}

#pragma mark - 初次设定周计划
-(void)showSettingAlert
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还未设置周计划，是否设置周计划" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            //设置周计划
        case 0:
            _aimText.enabled = YES;
            [_aimText becomeFirstResponder];
            [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
            break;
            //不设置周计划
        case 1:
            [self performSegueWithIdentifier:@"周计划设置完成" sender:nil];
            break;
    }
}
@end
