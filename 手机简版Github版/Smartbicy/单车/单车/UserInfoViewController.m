//
//  UserInfoViewController.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-8.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AFNetworking.h"
#import "CurrentAccount.h"
#import "TBActivityIndicatorView.h"
#import "UserInfo.h"
#import "MobClick.h"


#define kNumberOfHead 8
#define kNumberOfAccount 4

@interface UserInfoViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate> {
    
    //性别
    UIPickerView *_sexPicker;
    NSArray *_sexList;
    
    //身高
    UIPickerView *_heightPicker;
    NSArray *_heightList;
    
    //体重
    UIPickerView *_weightPicker;
    NSArray *_weightList;
    
    //头像
    UIPickerView *_headPicker;
    NSArray *_headList;
    
    //所在地
    UIPickerView *_placePicker;
    NSArray *_placeList;
    NSArray *_cities;
    
    //提示框
    TBActivityIndicatorView *_tbActivityIndicatorView;
}

@end

@implementation UserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
//                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    self.tabBarController.tabBar.hidden = YES;
    //初始化用于选择的数据
    [self loadSelectData];
    
    //初始化加载提示框
    [self inittBActivityIndicatorView];
    
    
    //载入用户信息(如果有)
    [self loadUserInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"个人信息设置页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"个人信息设置页面"];
}

- (void)loadSelectData
{
    /**
     *  生日
     */
    UIDatePicker *birthdayDatePicker = [[UIDatePicker alloc]init];
    [_birthdayText setInputView:birthdayDatePicker];
    [birthdayDatePicker setDatePickerMode:UIDatePickerModeDate];
    [birthdayDatePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN" ]];
    [birthdayDatePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    //初始化默认选项
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * minDate = [formatter dateFromString:@"1945-01-01"];
    NSDate * maxDate = [formatter dateFromString:@"2010-12-31"];
    
    NSDate *initialDate = [formatter dateFromString:@"1990-01-01"];
    birthdayDatePicker.date = initialDate;
    //设置生日的最大最小范围
    birthdayDatePicker.minimumDate = minDate;
    birthdayDatePicker.maximumDate = maxDate;
    
    
    /**
     *  性别
     */
    //初始化性别数据
    _sexList = [NSArray arrayWithObjects:@"男",@"女", nil];
    
    _sexPicker = [[UIPickerView alloc]init];
    //代理
    _sexPicker.delegate = self;
    _sexPicker.dataSource = self;
    
    [_sexText setInputView:_sexPicker]; //实现的是点击textField输入就弹出pickView
    
    /**
     *  身高
     */
    //初始化性别数据
    NSMutableArray *heightMutableArray = [[NSMutableArray alloc]init];
    for (int i = 140; i<200; i++) {
        NSString *num = [NSString stringWithFormat:@"%d", i];
        [heightMutableArray addObject:num];
    }
    _heightList = heightMutableArray;
    
    _heightPicker = [[UIPickerView alloc]init];
    //代理
    _heightPicker.delegate = self;
    _heightPicker.dataSource = self;
    
    [_heightText setInputView:_heightPicker];
    
    /**
     *  体重
     */
    //初始化性别数据
    NSMutableArray *weightMutableArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 35; i<101; i++) {
        NSString *num = [NSString stringWithFormat:@"%ld", (long)i];
        [weightMutableArray addObject:num];
    }
    _weightList = weightMutableArray;
    
    _weightPicker = [[UIPickerView alloc]init];
    //代理
    _weightPicker.delegate = self;
    _weightPicker.dataSource = self;
    
    [_weightText setInputView:_weightPicker];
    
    /*
     所在地
     */
    _placeList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
    _cities = [[_placeList objectAtIndex:0] objectForKey:@"Cities"];
    //NSLog(@"_cities = %@",_cities);
    
    _placePicker = [[UIPickerView alloc] init];
    _placePicker.tag = 123; //只有选择的地址的tag不一样
    [_placeText setInputView:_placePicker];
    _placePicker.delegate = self;
    _placePicker.dataSource = self;
    
    
    
    /**
     *  头像
     */
    NSMutableArray *headMutableArray = [[NSMutableArray alloc] init];
    for (NSInteger i =0; i < kNumberOfHead; i++) {
        UIImage *head = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)i]];
        [headMutableArray addObject:head];
    }
    _headList = headMutableArray;
    _headPicker = [[UIPickerView alloc] init];
    
    //代理
    _headPicker.delegate = self;
    _headPicker.dataSource = self;
    [_headText setInputView:_headPicker];
}

- (void)loadUserInfo
{
    _signNameText.delegate = self;
    
    //获取用户数据，通过单例
    CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    
    if (currentAccount.weChatAccount) {
        
        //如果是微信用户，则它默认是有nickName,sex，但是生日没有，可以根据生日是否为空，判断用户信息是否齐全
        self.userNickName = currentAccount.userNickName;
        _nickNameText.text = self.userNickName;
        
        self.userSex = currentAccount.userSex;
        if ([self.userSex isEqualToString:@"male"]) {
            _sexText.text = @"男";
        } else if([self.userSex isEqualToString:@"female"]){
            _sexText.text = @"女";
        }
        
        //NSLog(@"userNickName --> %@", currentAccount.userNickName);
        //取消默认头像选择
        _headText.hidden = YES;
        
        _headImage.layer.masksToBounds = YES;
        _headImage.layer.cornerRadius = _headImage.frame.size.width/2;
        _headImage.image = [UIImage imageWithContentsOfFile:currentAccount.weChatImagePath];
        
        
        if (currentAccount.userBirthday == nil) {
            //生日为空，说明是第一次登陆
        }else{
            //生日不为空，说明信息齐全，要全部显示给用户
            //用户信息不为空，对界面信息初始化
            self.userWeight = currentAccount.userWeight;
            self.userHeight = currentAccount.userHeight;
            self.userBirthday = currentAccount.userBirthday;
            self.userHeadID = currentAccount.userHeadID;
            self.userHRMax = currentAccount.userHRMax;
            self.userCity = currentAccount.userCity;
            self.userDeclaration = currentAccount.userDeclaration;
            
            //NSLog(@"info---%@ %@", currentAccount.userBirthday, currentAccount.userHeight);
            
            _weightText.text = [NSString stringWithFormat:@"%@ KG", self.userWeight];
            _heightText.text = [NSString stringWithFormat:@"%@ cm", self.userHeight];
            _birthdayText.text = self.userBirthday;
            //设置位置和宣言
            _placeText.text = _userCity;
            _signNameText.text = _userDeclaration;
            
            
            if ([self.userSex isEqualToString:@"male"]) {
                _sexText.text = @"男";
            } else if([self.userSex isEqualToString:@"female"]){
                _sexText.text = @"女";
            }
            
        }
    }else{
        //非微信用户
        
        //判断当前用户信息是否为空，由于信息是统一绑定（除了头像，如果有其他一项数据，则其他数据均有）此处直接用生日判断
        if (currentAccount.userBirthday == nil) {
            //没有信息的时候最先设置一下头像
            _userHeadID = @"0";
            NSInteger headID = [_userHeadID integerValue];
            NSString *headName = [NSString stringWithFormat:@"head%02ld.png", (long)headID];
            _headImage.image = [UIImage imageNamed:headName];
        }
        else {
            //用户信息不为空，对界面信息初始化
            self.userWeight = currentAccount.userWeight;
            self.userHeight = currentAccount.userHeight;
            self.userBirthday = currentAccount.userBirthday;
            self.userSex = currentAccount.userSex;
            self.userNickName = currentAccount.userNickName;
            self.userHeadID = currentAccount.userHeadID;
            self.userHRMax = currentAccount.userHRMax;
            self.userCity = currentAccount.userCity;
            self.userDeclaration = currentAccount.userDeclaration;
            
            //NSLog(@"info---%@ %@", currentAccount.userBirthday, currentAccount.userHeight);
            
            _weightText.text = [NSString stringWithFormat:@"%@ KG", self.userWeight];
            _heightText.text = [NSString stringWithFormat:@"%@ cm", self.userHeight];
            _nickNameText.text = self.userNickName;
            _birthdayText.text = self.userBirthday;
            //设置位置和宣言
            _placeText.text = _userCity;
            _signNameText.text = _userDeclaration;
            
            
            
            //微信用户
            if ([currentAccount.isWeChat intValue]) {
                
                _headText.hidden = YES;
                
                _headImage.layer.masksToBounds = YES;
                _headImage.layer.cornerRadius = _headImage.frame.size.width/2;
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:currentAccount.headimgurl]];
                _headImage.image = [UIImage imageWithData:data];
                
            }
            //普通用户
            else
            {
                NSInteger headID = [_userHeadID integerValue];
                NSString *headName = [NSString stringWithFormat:@"head%02ld.png", (long)headID];
                _headImage.image = [UIImage imageNamed:headName];
            }
            

            
            if ([self.userSex isEqualToString:@"male"]) {
                _sexText.text = @"男";
            } else if([self.userSex isEqualToString:@"female"]){
                _sexText.text = @"女";
            }
        }
    }
    

    _BMI.text = [self settingBIM];
}

-(NSString*) settingBIM
{
    CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];
    //设置BMI的值
    NSLog(@"_heightText.text = %@,_weightText.text = %@",_heightText.text,_weightText.text);
    NSLog(@"_heightText.text = %d,_weightText.text = %d",[_heightText.text intValue],[_weightText.text intValue]);
    if (currentAccount.infoEmpty) {
        return @"";
    }
    else if([_heightText.text intValue] && [_weightText.text intValue])
    {
        float heightMetter = [_heightText.text floatValue] / 100;
        float BMIfloat = [_weightText.text floatValue]/ (heightMetter*heightMetter);
        NSString * str;
        if (BMIfloat < 18.5 ) {
            str = @"偏瘦";
        }
        else if (BMIfloat > 18.5 && BMIfloat < 24.99){
            str = @"正常";
        }
        else if (BMIfloat > 24.99 && BMIfloat < 28)
        {
            str = @"偏肥";
        }
        else if(BMIfloat > 28 && BMIfloat < 32){
            str = @"肥胖";
        }
        else if(BMIfloat > 32){
            str = @"超标";
        }
        NSString * BMIStr = [NSString stringWithFormat:@"%0.2f（%@）",BMIfloat, str];
        return BMIStr;
    }
    return  @"";
}

#pragma mark - Action
#pragma mark “返回登陆界面”按钮  我的账户界面的返回登陆界面的按钮响应事件
#pragma mark "此处是注销按钮的响应事件"
- (IBAction)logout:(UIButton *)sender {
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
                
                [_tbActivityIndicatorView removeFromSuperview];
                [self showAlertWithDelegateWithString:@"注销成功" withTag: 111];
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    //注销
    if (alertView.tag == 111)
    {
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
        //保存偏好设置信息, 取消自动登录
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //4.是否记住密码
        [defaults setBool:NO forKey:@"loginBtn"];
        [defaults synchronize];
        [self performSegueWithIdentifier:@"退出登录" sender:nil];
    }
    //保存
    else if (alertView.tag == 999)
    {
        currentAccount.infoEmpty = NO;
        _BMI.text = [self settingBIM];
    }
}


#pragma mark - pickerView 数据源方法
#pragma pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView == _placePicker)
        return 2;
    return 1;
}
#pragma mark 行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _sexPicker) {
        return _sexList.count;
    }else if(pickerView == _heightPicker){
        return _heightList.count;
    }else if(pickerView == _weightPicker) {
        return _weightList.count;
    }else if(pickerView == _headPicker) {
        return _headList.count;
    }else if(pickerView == _placePicker) {
        switch (component) {
            case 0:
                return [_placeList count];
                break;
            case 1:
                return [_cities count];
                break;
            default:
                return 0;
                break;
        }
    }
    else {
        return 1;
    }
}

#pragma mark - pickerView 代理方法
#pragma mark 每行具体数据
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _sexPicker) {
        //默认在用户点击输入框后，默认显示为男
        _sexText.text = _sexList[0];
        return _sexList[row];
    }else if(pickerView == _heightPicker) {
        //        _heightText.text = _heightList[0];
        return [_heightList[row] stringByAppendingString:@" cm"];
    }else if(pickerView == _weightPicker){
        //        _weightText.text = _weightList[0];
        return [_weightList[row] stringByAppendingString:@" KG"];
    }
    else if(pickerView == _placePicker){
        switch (component) {
            case 0:
                return [[_placeList objectAtIndex:row] objectForKey:@"State"];
                break;
            case 1:
                return [[_cities objectAtIndex:row] objectForKey:@"city"];
                break;
            default:
                return nil;
                break;
        }
    }
    else {
        return @"hello";
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (pickerView == _headPicker) {
        NSString *headName = [NSString stringWithFormat:@"head%02ld.png",(long)row];
        UIImage *head = [UIImage imageNamed:headName];
        UIImageView *headImage = [[UIImageView alloc] initWithImage:head];
        
        headImage.frame = CGRectMake(0, 0, 120, 120);
        return headImage;
    }
    NSString *stringText = [self pickerView:pickerView titleForRow:row forComponent:component];
    UILabel *stringLabel = [[UILabel alloc] init];
    stringLabel.font = [UIFont systemFontOfSize:25.0];
    stringLabel.text = stringText;
    stringLabel.textAlignment = NSTextAlignmentCenter;
    return stringLabel;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if (pickerView == _headPicker) {
        return 140.0;
    }
    return 40.0;
}

#pragma mark 当选择时
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    NSLog(@"选择");
    if (pickerView == _sexPicker) {
        _sexText.text = _sexList[row];
        
    }else if(pickerView == _heightPicker) {
        _heightText.text = [_heightList[row] stringByAppendingString:@" cm"];
        _userHeight = _heightList[row];
    }else if(pickerView == _weightPicker){
        _weightText.text = [_weightList[row] stringByAppendingString:@" KG"];
        _userWeight = _weightList[row];
    }else if(pickerView == _headPicker){
        _headImage.image = _headList[row];
        _userHeadID = [NSString stringWithFormat:@"%ld", (long)row];
        NSLog(@"%@", _userHeadID);
    }
    else if(pickerView == _placePicker)
    {
        switch (component) {
            case 0:
                _cities = [[_placeList objectAtIndex:row] objectForKey:@"Cities"];
                [_placePicker selectRow:0 inComponent:1 animated:NO];
                [_placePicker reloadComponent:1];
                
                break;
            case 1:
                _userCity = [[_cities objectAtIndex:row] objectForKey:@"city"];
                _placeText.text = [[_cities objectAtIndex:row] objectForKey:@"city"];
                break;
            default:
                break;
        }
    }
}


#pragma mark - 生日，日期选择器，值改变时调用
- (void)dateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:datePicker.date];
    
    //更新UI--birthdayText
    _birthdayText.text = dateString;
    
    _userBirthday = dateString;
}

#pragma mark - 释放键盘
- (void)resignKeyboard
{
    [self.sexText resignFirstResponder];
    [self.nickNameText resignFirstResponder];
    [self.heightText resignFirstResponder];
    [self.weightText resignFirstResponder];
    [self.birthdayText resignFirstResponder];
    [self.headText resignFirstResponder];
    [self.placeText resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //点击空白，释放键盘
    //[self resignKeyboard];
    [self.view endEditing:YES];
}
#pragma mark - 警告框
#pragma mark 无代理
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

#pragma mark - TB加载框初始化
- (TBActivityIndicatorView *)inittBActivityIndicatorView
{
    //    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"保存中"];
    //    return _tbActivityIndicatorView;
    return nil;
}

- (IBAction)save:(UIButton *)sender {
    
    [self.view endEditing:YES];
    //弹出提示框
    [self.view addSubview:_tbActivityIndicatorView];
    
    //转换数据格式为能直接保存的格式
    _userNickName = _nickNameText.text;
    _userSex = @"male";
    if ([_sexText.text isEqualToString:@"女"]) {
        _userSex = @"female";
    }
    [self setHRmax];
    
    CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    _userDeclaration = _signNameText.text;
    
    
    if ([_nickNameText.text isEqualToString:@""] || [_heightText.text isEqualToString:@""]|| [_weightText.text isEqualToString:@""]||[_sexText.text isEqualToString:@""]||[_birthdayText.text isEqualToString:@""]|| [_placeText.text isEqualToString:@""])
    {
        [self showAlertWithString:@"请完善个人信息以适配算法"];
    }
    else
    {
        
        currentAccount.userNickName = _userNickName;
        currentAccount.userSex = _userSex;
        currentAccount.userBirthday = _userBirthday;
        currentAccount.userCity = _userCity;
        currentAccount.userWeight = _userWeight;
        currentAccount.userHeight = _userHeight;
        currentAccount.userHeadID = _userHeadID;
        currentAccount.userDeclaration = _userDeclaration;
        
        
        NSString *urlString = [NSString stringWithFormat:@"http://%@/PersonalInfo?nick_name=%@&sex=%@&height=%@&weight=%@&birthday=%@&level=0&plan=-1&minutes=25&HRmax=%@&headId=%@&isWeChat=%@&weChatHeadUrl=%@&user_city=%@&user_declaration=%@",currentAccount.serverName, _userNickName, _userSex,_userHeight, _userWeight, _userBirthday,_userHRMax,_userHeadID,currentAccount.isWeChat, currentAccount.headimgurl, _userCity, _userDeclaration];
        
        
        NSLog(@"%@", urlString);
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
             * return {“ret”: -1} 用户没有登录
             * {“ret”:1} 操作成功
             * {“ret”:-2}操作失败
             */
            //对服务器返回数据进行判断
            switch (ret) {
                case -1:
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithString:@"用户未登录"];
                    break;
                case 1:
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithDelegateWithString:@"保存成功" withTag:999];
                    break;
                case -2:
                    [_tbActivityIndicatorView removeFromSuperview];
                    [self showAlertWithString:@"保存失败"];
                    break;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Error: %@",error);
            //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
            [self showAlertWithString:@"请完善个人信息或检查网络"];
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
        
    }
}
#pragma mark 设置最大心率
- (void)setHRmax
{
    /**
     *锻炼者的最大心率HRmax， 以每分钟的心跳为单位(BMP)的，计算方法：
     *男: 210 - 年龄/2 - (0.11 * 体重 + 4)
     *女: 210 - 年龄/2 - (0.11 * 体重)
     *
     *假如没有账户信息，需要一个默认数据（平均）------->kHRmaxDefault    190
     *
     */
    
    //获取用户数据，通过单例
    //    TBAppDelegate *appDelegate = [[UIApplication sharedApplication ]delegate];
    //    self.infoDictionary = appDelegate.infoDictionary;
    //    self.userWeight = [self.infoDictionary objectForKey:@"weight"];
    //    self.userBirthday = [self.infoDictionary objectForKey:@"birthday"];
    //    self.userSex = [self.infoDictionary objectForKey:@"sex"];
    
    //转换生日数据格式，方便计算
    NSDateFormatter *formatterWithSymbol = [[NSDateFormatter alloc]init];
    [formatterWithSymbol setDateFormat:@"yyyy-MM-dd"];
    NSDate *initialDate = [formatterWithSymbol dateFromString:_userBirthday];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *birthString = [formatter stringFromDate:initialDate];
    
    //获取现在时间
    NSDate *date = [NSDate date];
    NSString *dateNowString = [formatter stringFromDate:date];
    
    //转换为能进行四则运算的格式
    int dateNow = [dateNowString intValue];
    int birth = [birthString intValue];
    int age = (dateNow - birth) / 10000;
    int weight = [_userWeight intValue];
    
    //判断是否登录并判断男女,以设置最大心率
    if ([self.userSex isEqualToString:@"male"]) {//男
        _userHRMax =[NSString stringWithFormat:@"%f",210 - age / 2 - (0.11 * weight +4) ];
    }else if([self.userSex isEqualToString:@"female"]){//女
        _userHRMax = [NSString stringWithFormat:@"%f",210 - age / 2 - (0.11 * weight )];
    }else{//未登录
        _userHRMax = [NSString stringWithFormat:@"%f",kHRmaxDefault];
    }
}

//#pragma 保存数据到当前用户和历史记录中
//- (void)saveDataToCurrentAccount
//{
//    CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];
//    
//    //获取路径
//    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docPath = [documents objectAtIndex:0];
//    NSString *path = [docPath stringByAppendingPathComponent:@"accounts.plist"]; //在沙盒里创建一个plist文件存储离世用户信息
//    
//    NSArray *accounts = [NSArray arrayWithContentsOfFile:path];
//    if (accounts == nil) {
//        accounts = [[NSArray alloc] init];
//    }
//    NSMutableArray *accountsNew = [NSMutableArray arrayWithArray:accounts];
//    BOOL isExistAccount = NO;
//    
//    for (NSDictionary *info in accounts) {
//        
//        if ([[info objectForKey:@"userName"] isEqualToString:currentAccount.userName])
//        {
//            
//            [accountsNew removeObject:info];
//            isExistAccount = NO;
//            break;
//        }
//    }
//    if (!isExistAccount) {
//        
//        //手机注册的用户
//        NSString * weChatServerNameStr = @"";
//        NSString * phoneServerNameStr = currentAccount.serverUserName;
//        NSString * weChatAccountStr = @"0";
//        if (currentAccount.weChatAccount)
//        {
//            weChatAccountStr = @"1";
//            
//            weChatServerNameStr = currentAccount.serverUserName;
//            phoneServerNameStr = @"";
//            
//            UIImage *headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentAccount.weChatUrl]]];
//            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docPath, currentAccount.userName];
//            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(headImage)];
//            [data1 writeToFile:pngFilePath atomically:YES];
//            currentAccount.weChatImagePath = pngFilePath;
//        }
//        else
//        {
//            currentAccount.weChatUrl = @"";
//            currentAccount.weChatImagePath = @"";
//        }
//        
//        //NSLog(@"currentAccount.userName = %@\ncurrentAccount.userPassword = %@\ncurrentAccount.userNickName = %@\nweChatAccountStr = %@\ncurrentAccount.userHeadID = %@\ncurrentAccount.weChatUrl = %@\ncurrentAccount.userBirthday = %@\ncurrentAccount.userSex = %@\ncurrentAccount.userHeight = %@\ncurrentAccount.userWeight = %@\ncurrentAccount.userCity = %@\ncurrentAccount.userDeclaration = %@\nweChatServerNameStr = %@\nphoneServerNameStr= %@\ncurrentAccount.weChatImagePath = %@",currentAccount.userName,currentAccount.userPassword,currentAccount.userNickName,weChatAccountStr,currentAccount.userHeadID,currentAccount.weChatUrl,currentAccount.userBirthday,currentAccount.userSex,currentAccount.userHeight,currentAccount.userWeight,currentAccount.userCity,currentAccount.userDeclaration,weChatServerNameStr,phoneServerNameStr,currentAccount.weChatImagePath);
//        
//        NSDictionary * userInfo = @{@"userName": currentAccount.userName, @"userPassword":currentAccount.userPassword,@"userNickName":currentAccount.userNickName,
//                                    @"weChatAccount":weChatAccountStr, @"userHeadID":currentAccount.userHeadID, @"weChatUrl":currentAccount.weChatUrl,
//                                    @"userBirthday":currentAccount.userBirthday, @"userSex":currentAccount.userSex, @"userHeight":currentAccount.userHeight,
//                                    @"userWeight":currentAccount.userWeight,@"userCity":currentAccount.userCity, @"userDeclaration":currentAccount.userDeclaration,
//                                    @"weChatServerName":weChatServerNameStr,@"phoneServerName":phoneServerNameStr,@"weChatImagePath":currentAccount.weChatImagePath};
//        
//        //NSLog(@"userInfo = %@, accountsNew = %@",userInfo,accountsNew);
//        
//        
//        
//        if (accountsNew.count == kNumberOfAccount) {//默认是保存4个账户，如果已经存在4个，则去除第一个账户
//            [accountsNew removeObjectAtIndex:0];
//        }
//        [accountsNew addObject:userInfo];
//    }
//    NSArray *array = [NSArray arrayWithArray:accountsNew];
//    [array writeToFile:path atomically:YES];
//}
//
//#pragma mark 获取历史账户信息
//- (NSArray *)getAccounts
//{
//    NSString *path = [self getAccountsPath];
//    NSArray *accounts = [NSArray arrayWithContentsOfFile:path];
//    return accounts;
//}
//
//-(NSString *)getAccountsPath
//{
//    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docPath = [documents objectAtIndex:0];
//    NSString *path = [docPath stringByAppendingPathComponent:@"accounts.plist"];
//    return path;
//}



- (IBAction)backForModel:(id)sender {
    
    //转换数据格式为能直接保存的格式
    _userNickName = _nickNameText.text;
    _userSex = @"male";
    if ([_sexText.text isEqualToString:@"女"]) {
        _userSex = @"female";
    }
    _userDeclaration = _signNameText.text;
    
    
    if ([_nickNameText.text isEqualToString:@""] || [_heightText.text isEqualToString:@""]|| [_weightText.text isEqualToString:@""]||[_sexText.text isEqualToString:@""]||[_birthdayText.text isEqualToString:@""]|| [_placeText.text isEqualToString:@""])
    {
        [self showAlertWithString:@"请完善个人信息以适配算法"];
    }
    else
    {
        CurrentAccount * current = [CurrentAccount sharedCurrentAccount];
        current.page = 4;
        [self performSegueWithIdentifier:@"训练" sender:nil];
    }
}

//将个性签名这几个字删除
-(void)textFieldDidBeginEditing:(UITextView *)textView
{
    _signNameText.text = @"";
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]){
        return YES;
    }
    
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_signNameText == textField)
    {
        if ([aString length] > 30) {
            
            _signNameText.text = [aString substringToIndex:7];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"超过最大字数了,请重新输入！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
            _signNameText.text = @"";
        }
    }
    return YES;
}


@end
