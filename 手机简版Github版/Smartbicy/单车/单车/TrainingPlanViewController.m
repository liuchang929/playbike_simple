//
//  TrainingPlanViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/5/4.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "TrainingPlanViewController.h"
#import "CurrentAccount.h"

//声明一些私有成员
@interface TrainingPlanViewController ()
{
    NSArray * staticHeartArray;
    NSArray * ageArray;
    NSArray * sportTimesArray;
    BOOL fat; //采用的是否是燃脂功能
    NSMutableDictionary * dictionary;//存放读取用户设置好的数据
    
    UIBarButtonItem *barbtn;
}

@end

@implementation TrainingPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    staticHeartArray = [[NSArray alloc] initWithObjects:@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59",@"60",@"61",@"62",@"63",@"64",@"65",@"66",@"67",@"68",@"69",@"70",@"71",@"72",@"73",@"74",@"75",@"76",@"77",@"78",@"79",@"80",@"81",@"82",@"83",@"84",@"85",@"86",@"87",@"88",@"89",@"90", nil];
    //65岁到5岁
    ageArray = [[NSArray alloc] initWithObjects:@"2010",@"2009",@"2008",@"2007",@"2006",@"2005",@"2004",@"2003",@"2002",@"2001",@"2000",@"1999",@"1998",@"1997",@"1996",@"1995",@"1994",@"1993",@"1992",@"1991",@"1990",@"1989",@"1988",@"1987",@"1986",@"1985",@"1984",@"1983",@"1982",@"1981",@"1980",@"1979",@"1978",@"1977",@"1976",@"1975",@"1974",@"1973",@"1972",@"1971",@"1970",@"1969",@"1968",@"1967",@"1966",@"1965",@"1964",@"1963",@"1962",@"1961",@"1960",@"1959",@"1958",@"1957",@"1956",@"1955",@"1954",@"1953",@"1952",@"1951",@"1950", nil];
    sportTimesArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30", nil];
    
    [self initData];
    
    barbtn=[[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    barbtn.title = @"保存";
    if([[CurrentAccount sharedCurrentAccount] setTrainingPlan])
    {
        barbtn.title = @"重置";
    }
    barbtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = barbtn;
}

-(void)initData
{
    //1. 静心率 2. 年龄 3. 一个月内运动次数
    _heartPicker = [[UIPickerView alloc] init];
    _heartPicker.tag = 1;
    _heartPicker.delegate = self;
    _heartPicker.dataSource = self;
    
    _agePicker = [[UIPickerView alloc] init ];
    _agePicker.tag = 2;
    _agePicker.delegate = self;
    _agePicker.dataSource = self;
    
    _sportPicker = [[UIPickerView alloc] init ];
    _sportPicker.tag = 3;
    _sportPicker.delegate = self;
    _sportPicker.dataSource = self;
    
    [_heartTextField setInputView:_heartPicker];
    [_ageTextField setInputView:_agePicker];
    [_sportTimeTextField setInputView:_sportPicker];
    
    _heartPicker.tag = 1;
    _heartPicker.delegate = self;
    _heartPicker.dataSource = self;
    _agePicker.tag = 2;
    _agePicker.delegate = self;
    _agePicker.dataSource = self;
    _sportPicker.tag = 3;
    _sportPicker.delegate = self;
    _sportPicker.dataSource = self;
    fat = YES;
    
    //如果用户没有设置训练计划隐藏planView
    if(![[CurrentAccount sharedCurrentAccount] setTrainingPlan])
    {
        _PlanView.hidden = YES;
    }
    //如果用户设置了，改变静心率的数字范围
    else
    {
        [self getDateFotUI];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 显示已经设置的数据
-(void)getDateFotUI
{
    CurrentAccount * current = [CurrentAccount sharedCurrentAccount];
    
    //设置planView界面， 这是为了显示一些数据（都是原始的），下面的饿步骤是进行更新的
    [self settingPlanView];
    
    //将用户之前设置好的数据展示出来
    NSString * filePath = [self datafilePath];
    //读取数据到字典中
    dictionary=[[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    NSLog(@"读取出来的dic %@",dictionary);
    
    for (NSString * str in [dictionary allKeys])
    {
        if ([str isEqualToString:@"staticHeart"])
        {
            _heartTextField.text = [dictionary objectForKey:@"staticHeart"];
        }
        if ([str isEqualToString:@"age"])
        {
            _ageTextField.text = [dictionary objectForKey:@"age"];
        }
        if ([str isEqualToString:@"sportTimes"])
        {
            _sportTimeTextField.text = [dictionary objectForKey:@"sportTimes"];
        }
        if ([str isEqual:@"sportLevel"]) {
            _sportLevel.text = [dictionary objectForKey:@"sportLevel"];
        }
    }
    //NSLog(@"_heartTextField = %@, _ageTextField = %@, _sportTimeTextField = %@ ", _heartTextField.text, _ageTextField.text,_sportTimeTextField.text );
    
    //更新靶心率，  必须在textfield内有数据的时候才可以计算
    [self limisHeart];
    [self setLevelTime:[dictionary objectForKey:@"sportLevel"]];

    if (current.fatFunc) {
        [_fatBtn setImage:[UIImage imageNamed:@"pointdown.png"] forState:UIControlStateNormal];
        [_aerobicBtn setImage:[UIImage imageNamed:@"pointup.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_fatBtn setImage:[UIImage imageNamed:@"pointup.png"] forState:UIControlStateNormal];
        [_aerobicBtn setImage:[UIImage imageNamed:@"pointdown.png"] forState:UIControlStateNormal];
    }
}


#pragma mark - 靶心率计算
-(void)limisHeart
{
    NSString * year = _ageTextField.text;
    int  staticHeart = [_heartTextField.text intValue];
    
    // 获取当前的时间
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * now = [dateFormatter stringFromDate:date];
    
    int age = [now intValue] - [year intValue];
    int staticHeartNum_min = (220 - age) * 0.6; //((220-age)-staticHeart)*0.6 + staticHeart;
    int staticHeartNum_max = (220 - age) * 0.8; //((220-age)-staticHeart)*0.8 + staticHeart;
    //NSLog(@"age = %d,staticHeart = %d, staticHeartNum_min = %d, staticHeartNum_max = %d",age,staticHeart,staticHeartNum_min, staticHeartNum_max);
    
    int heartDistance = (staticHeartNum_max - staticHeartNum_min)/5;
    
    _limisOne.text = [NSString stringWithFormat:@"%d", staticHeartNum_min];
    _limisTwo.text = [NSString stringWithFormat:@"%d", staticHeartNum_min + heartDistance];
    _limisThree.text = [NSString stringWithFormat:@"%d", staticHeartNum_max - heartDistance];
    _limisFour.text = [NSString stringWithFormat:@"%d", staticHeartNum_max];
    _limis.text = [NSString stringWithFormat:@"%d~%d", staticHeartNum_min, staticHeartNum_max];
}


- (IBAction)back:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self presentViewController:(UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"] animated:YES completion:nil];
}


#pragma mark - 保存按钮
- (IBAction)save:(id)sender {
    
    if ([barbtn.title isEqual:@"保存"]) {
        //用户必须输入全了才开始设置
        if ( ![_heartTextField.text isEqual:@""] && ![_ageTextField.text isEqual:@""] && ![_sportTimeTextField.text isEqual:@""] ) {
            //更新靶心率
            [self limisHeart];
            [self settingPlanView];
            _PlanView.hidden = NO;
            
            //经用户是否设置训练计划、采取的是哪种方法记录下来
            CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];
            currentAccount.setTrainingPlan = YES;
            currentAccount.fatFunc = fat;
            
            //将数据保存到plist文件中, 现在刚开始的时候都是本周的次数
            [self uploadHeart:_heartTextField.text age:_ageTextField.text sportTimes:_sportTimeTextField.text remainTimes:_weekTimes.text weekDone:@"0" sportLevel:_sportLevel.text];
        }
        //用户没有输入完整数据，则提示用户
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请您完善数据" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if([barbtn.title isEqual:@"重置"])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否重置数据" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //用户确定重置数据
    if(buttonIndex == 0)
    {
        //将按钮改变为保存
        barbtn.title = @"保存";
        //隐藏训练计划视图
        _PlanView.hidden = YES;
        
        _heartTextField.text = @"";
        _ageTextField.text = @"";
        _sportTimeTextField.text = @"";
    }
}

#pragma mark - 将数据存储到沙盒中
//获取沙盒路径 （ 模拟器）
-(NSString *)datafilePath//返回数据文件的完整路径名。
{
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return [docPath stringByAppendingPathComponent:@"trainingPlan.plist"];
}

//将用户设定的数据传入服务器
-(BOOL)uploadHeart:(NSString *)heart age:(NSString *) age sportTimes:(NSString *) sportTimes remainTimes:(NSString *) remainTimes weekDone:(NSString *) weekDone sportLevel:(NSString *) sportLevel
{
    
    //向沙河中存入数据
    NSBundle *bundle=[NSBundle mainBundle];
    NSString *path=[bundle pathForResource:@"trainingPlan" ofType:@"plist"];
    
    NSString * filePath = [self datafilePath];
    NSLog(@"filePath= %@",filePath);
    if (!path)
    {
        return NO;
    }
    
    //读取数据到字典中
    NSMutableDictionary * dic=[[NSMutableDictionary alloc]initWithContentsOfFile:path];
    [dic setObject:heart forKey:@"staticHeart"]; //将数据更新到文件中
    [dic setObject:age forKey:@"age"];
    [dic setObject:sportTimes forKey:@"sportTimes"];
    [dic setObject:remainTimes forKey:@"remainTimes"];
    [dic setObject:[NSDate date] forKey:@"saveTime"];
    [dic setObject:sportLevel forKey:@"sportLevel"];
    [dic setObject:weekDone forKey:@"weekDone"];
    // 循环输出字典中的  data 数据
    [dic writeToFile:filePath atomically:YES];
    NSLog(@"存进去的dic%@", dic);
    return YES;
}

#pragma mark - 功能按钮选择
- (IBAction)fatBurn:(id)sender {
    fat = YES;
    [_fatBtn setImage:[UIImage imageNamed:@"pointdown.png"] forState:UIControlStateNormal];
    [_aerobicBtn setImage:[UIImage imageNamed:@"pointup.png"] forState:UIControlStateNormal];
}


- (IBAction)aerobic:(id)sender {
    fat = NO;
    [_fatBtn setImage:[UIImage imageNamed:@"pointup.png"] forState:UIControlStateNormal];
    [_aerobicBtn setImage:[UIImage imageNamed:@"pointdown.png"] forState:UIControlStateNormal];
}



#pragma mark - 设置planView界面
-(void)settingPlanView
{
    
    // 根据性别修改头像
    if ([[[CurrentAccount sharedCurrentAccount] userSex] isEqual:@"male"]) {
        _sexImage.image = [UIImage imageNamed:@"man.png"];
    }
    else
    {
        _sexImage.image = [UIImage imageNamed:@"woman.png"];
    }
    
    
    // 根据用户选取的不同功能改变
    if (fat) {
        _fatOrAerobic.text = @"燃脂";
        _planTitle.text = @"燃脂";
    }
    else
    {
        _fatOrAerobic.text = @"有氧";
        _planTitle.text = @"增强心肺功能";
    }
    
    //根据运动次数确定计划开始的等级
    int sportTimes = [_sportTimeTextField.text intValue];
    switch (sportTimes) {
        case 0:
        case 1:
        case 2:
            _sportLevel.text = @"开始1";
            break;
        case 3:
        case 4:
        case 5:
            _sportLevel.text = @"开始2";
            break;
        default:
            _sportLevel.text = @"改善1";
            break;
    }
    
    [self setLevelTime:_sportLevel.text];
}




-(void)setLevelTime:(NSString *) level
{
    //燃脂功能
    if ([[CurrentAccount sharedCurrentAccount] fatFunc]) {
        if ([level isEqual:@"开始1"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"10分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"2";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"开始2"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"15分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@",  _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"改善1"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"20分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"改善2"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"25分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@",_limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"改善3"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"30分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"强化1"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"30分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"强化2"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"35分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"强化3"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"40分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if([level isEqual:@"维持"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"40分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"不限";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
    }
    //心肺功能
    else
    {
        if ([level isEqual:@"开始1"]) {
            
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"10分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"2";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"开始2"]) {
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"15分钟";
            _timeThree.text = @"5分钟";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"改善1"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"20分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"改善2"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"25分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"改善3"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"30分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"强化1"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"30分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if ([level isEqual:@"强化2"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"35分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
        else if ([level isEqual:@"强化3"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"40分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"4";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
            
        }
        else if([level isEqual:@"维持"]) {
            _timeOne.text = @"20分钟";
            _timeTwo.text = @"40分钟";
            _timeThree.text = @"5分钟";
            
            _monthTimes.text = @"不限";
            _weekTimes.text = @"3";
            _remainTimes.text = @"3";
            
            _heartOne.text = [NSString stringWithFormat:@"%@以下",_limisOne.text];
            _heartTwo.text = [NSString stringWithFormat:@"%@~%@", _limisTwo.text, _limisThree.text];
            _heartThree.text = _heartOne.text;
        }
    }
    if([[CurrentAccount sharedCurrentAccount] setTrainingPlan])
    {
        //设置剩余次数
        _remainTimes.text = [dictionary objectForKey:@"remainTimes"];
    }
}

#pragma mark - pickView的设置
//只有一组选择数据
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//本组有多少个数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return  staticHeartArray.count;
    }
    else if(pickerView.tag == 2)
    {
        return ageArray.count;
    }
    else
    {
        return sportTimesArray.count;
    }
}
//设置每个选项的内容
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
        if (pickerView.tag == 1) {
            return  [staticHeartArray objectAtIndex:row];
        }
        else if(pickerView.tag == 2)
        {
            return [ageArray objectAtIndex:row];
        }
        else
        {
            return [sportTimesArray objectAtIndex:row];
        }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        _heartTextField.text = [staticHeartArray objectAtIndex:row];
    }
    else if(pickerView.tag == 2)
    {
        _ageTextField.text = [ageArray objectAtIndex:row];
    }
    else
    {
        _sportTimeTextField.text = [sportTimesArray objectAtIndex:row];
    }
}

#pragma mark - 释放第一响应
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_heartTextField resignFirstResponder];
    [_ageTextField resignFirstResponder];
    [_sportTimeTextField resignFirstResponder];
}

@end
