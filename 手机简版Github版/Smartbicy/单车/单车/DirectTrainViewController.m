//
//  LocalTrainViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "DirectTrainViewController.h"
#import <AFNetworking.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CurrentAccount.h"
#import "iCadeReaderView.h"
#import "DataFromICade.h"
#import "Function.h"
#import "TBActivityIndicatorView.h"
#import "MyAlertViewController.h"
#import "MobClick.h"

#define kTimeThread 3.0
#define kDistanceEachLoop 3
#define kICadeDataToSpeedThread 3

@interface DirectTrainViewController ()<iCadeEventDelegate>
{
    // 多线程操作
    dispatch_queue_t _globalQueue;
    
    CurrentAccount * current;
    
    //TB菊花框
    TBActivityIndicatorView *_tbActivityIndicatorView;
    
    float _Weight;
    float _Height;
    int _age;
    int _sex;//男生是1， 女生是0
    NSString * _birthday; //生日
    //运动起始时间
    NSString *_startTime;
    
    //重新连接服务器
    NSTimer *connectSer;
    
    //计时器，检测心率、脚踏板是否还有输入
    NSTimer *_timerForLabel;
    NSTimer *_timerForHeart;
    NSTimer *_timerForLoop;
    //获取好友位置的定时器
    NSTimer *getPoint;
    
    //心率、数据定时器
    NSTimer *_timerForGetDataForUI;
    NSTimer *timerForGetDataForPlot;
    
    float _countTime;//定时器用的时间
    float _timeHeart;
    float _timeLoop;
    
    //心率
    NSString *_heartRateString;
    NSInteger _heartBeatInteger;
    float _heartRateFloat;
    float _heartRatePreFloat;
    NSInteger _sum;
    NSInteger _yPercentLastInt;
    
    //速度
    float distance;
    int fastTimes;   //为了判断用户的骑行速度过快的语音播报
    
    //调整速度
    int countnumberforspeed;
    float averagespeed;
    float lastaveragespeed;
    float lastspeed;
    float storespeed;
    
    iCadeReaderView *control;
    
}

//运动数据缓存池
@property (strong, nonatomic) NSMutableArray *datasParseredLoopNum;
@property (assign, nonatomic) float calSum;
@property (assign, nonatomic) NSInteger currentLoopNum;//脚踏

//爬坡按钮
@property (weak, nonatomic) IBOutlet UIButton *climb;
//蓝牙按钮
@property (weak, nonatomic) IBOutlet UIButton *bluetooth;

@property (strong, nonatomic) MPMoviePlayerController * media;
@property (strong, nonatomic) UIButton * pauseBtn;//暂停按钮

//数据变化switch
@property (weak, nonatomic) IBOutlet UISwitch *dataSwitch;

@end

@implementation DirectTrainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取队列
    _globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self initCurrentData];
    
    //初始化icade
    control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:control];
    control.delegate = self;
    
    //存放数据的数组
    self.datasParsered = [NSMutableArray array];
    self.datasParseredLoopNum = [NSMutableArray array];
    
    [self startSport];
    
    current = [CurrentAccount sharedCurrentAccount];
    [self addMediaPlay];
    [_media play];
    [self addPauseBtn];

    [self inittBActivityIndicatorView];

}

#pragma mark - TB加载框初始化
- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@""];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"指导视频训练页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"指导视频训练页面"];
}

#pragma mark - 退出训练
- (IBAction)exit:(UIButton *)sender {
    //提示框
    MyAlertViewController * myAlert = [MyAlertViewController alertControllerWithTitle:@"提示" message:@"真的要离开？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   
                                   [self uploadData];
                                   
                                   [_timerForGetDataForUI invalidate];
                                   
                                   //暂停计时
                                   [_timerForLabel invalidate];
                                   
                                   
                                   [_media stop];
                                   _media = nil;
                                   
                                   
                                   control.discoveredPeripheral = nil;
                                   [control removeFromSuperview];
                                   
                                   
                                   //判断跳转到分享、打卡
                                   if ([_distanceLabel.text floatValue] > 0.021) {
                                       [self.view addSubview:_tbActivityIndicatorView];
                                        [self performSegueWithIdentifier:@"exitFromDir" sender:nil];
                                   }
                                   else
                                   {
                                       //没训练完退出
                                       [self performSegueWithIdentifier:@"exit" sender:nil];
                                   }
                               }];
    [myAlert addAction:cancelAction];
    [myAlert addAction:okAction];
    [self presentViewController:myAlert animated:YES completion:nil];
}

#pragma mark 初始化计算卡路里的信息 获取用户的信息
-(void)initCurrentData
{
    CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
    _Weight = [currenAccount.userWeight floatValue];
    _Height = [currenAccount.userHeight floatValue];
    
    //年龄
    _birthday =currenAccount.userBirthday ;
    //获取系统时间， 用于计算年龄
    NSDate *now = [NSDate date];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"YYYY-mm-dd"];
    NSString * nowTime = [inputFormatter stringFromDate:now];
    //NSLog(@"date= %@,", nowTime);
    _age = [[nowTime substringToIndex:4] intValue] - [[_birthday substringToIndex:4] intValue];
    
    //获取用户的性别
    NSString * sex = currenAccount.userSex;
    //NSLog(@"sex = %@",sex);
    //男女
    if ([sex isEqualToString:@"male"]) {
        _sex = 1;
    }
    else
    {
        _sex = 0;
    }
}

-(void)blueToothConnect:(NSNotification * ) notifation
{
    if ([notifation.name  isEqualToString:@"break"]) {
        //////////显示框弹出蓝牙已经连接
        [_bluetooth setImage:[UIImage imageNamed:@"蓝牙断开.png"] forState:UIControlStateNormal];
        [_bluetooth setTitle:@" 蓝牙已断开" forState:UIControlStateNormal];
        
    }
    else if ([notifation.name  isEqualToString:@"connect"]) {
        //////////显示框弹出蓝牙已经连接
        [_bluetooth setImage:[UIImage imageNamed:@"蓝牙.png"] forState:UIControlStateNormal];
        [_bluetooth setTitle:@" 蓝牙已连接" forState:UIControlStateNormal];
        
    }
}

-(void)showCompleteInfo
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的个人资料未完善，卡路里计算异常!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - 用户过每过半个小时重新登录一次
-(void)connectSerVer
{
    //获取用户输入的登录信息
    NSString * name = [[CurrentAccount sharedCurrentAccount] userName];
    NSString * pwd =  [[CurrentAccount sharedCurrentAccount] userPassword];
    //NSLog(@"name = %@ pwd = %@", name, pwd);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=login&username=%@&password=%@",current.serverName,name, pwd];
    
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

#pragma mark - 上传数据
- (void)uploadData
{
    //   "http://bikeme.duapp.com/InfoSubmit?mileage=%f&calorie=32&user_time=00:23:11&max_heart_rate=100&min_heart_rate=60&avg_heart_rate=80&user_red_area=0&user_anaerobic_area=10&user_aerobic_area=20&user_fat_burn_area=30&user_simple_area=40&user_other_area=50&ts=2014-04-14
    
    [self connectSerVer];
    
    NSDate * date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * dateStr = [formatter stringFromDate:date];
    //&Hms=%@&property=1
    [formatter setDateFormat:@"HH:mm"];
    NSString * HmsStr = [formatter stringFromDate:date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/RankServlet?username=%@&nickname=%@&type=train&cal=%f&mileage=%f&time=%d&date=%@&Hms=%@&property=%@&terminal=2&handle=updatesportdata",[[CurrentAccount sharedCurrentAccount] serverName],[[CurrentAccount sharedCurrentAccount] userName], [[CurrentAccount sharedCurrentAccount] userNickName], self.calSum, self.distance*1000,(int)_countTime, dateStr,HmsStr,current.dirMoive];
    
    NSLog(@"%@",urlString);
    
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        //        return {“ret”: -1} 用户没有登录
        //        {“ret”:1} 操作成功
        //        {“ret”:-2}操作失败
        
        NSDictionary *dictionary = responseObject;
        //解析数据
        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];
        NSLog(@"ret = %@", dictionary);
        
        if (ret == 1) {
            //取消加载框
            [_tbActivityIndicatorView removeFromSuperview];
            
            //传递数据到账户单例
            CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
            //分别记录用户到达热身或燃脂等状态的次数
            currenAccount.distance = self.distance;
            currenAccount.calSum = self.calSum;
            
            currenAccount.planHeartView = NO;//不是从训练计划跳转过来的
            /*
             NSLog(@"level0 --> %d",self.levelCount0);
             NSLog(@"level1 --> %d",self.levelCount1);
             NSLog(@"level2 --> %d",self.levelCount2);
             NSLog(@"level3 --> %d",self.levelCount3);
             */
        }
        else{
            [_tbActivityIndicatorView removeFromSuperview];
            //[self showAlertWithString:@"网络异常"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@",error);
        [_tbActivityIndicatorView removeFromSuperview];
        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        //[self showAlertWithString:@"网络异常"];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}



#pragma mark -  触发运动
-(void)startSport
{
    NSDate *now = [NSDate date];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"YYYY-mm-dd"];
    NSString * nowTime = [inputFormatter stringFromDate:now];
    //NSLog(@"date= %@,", nowTime);
    _age = [[nowTime substringToIndex:4] intValue] - [[_birthday substringToIndex:4] intValue];
    //NSLog(@"age = %d,w= %f,h=%f",_age,_Weight,_Height);
    // 个人资料不完善
    if (_age == [[nowTime substringToIndex:4] intValue] || _Weight == 0 || _Height == 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showCompleteInfo) userInfo:nil repeats:NO];
        NSLog(@"个人资料不完善，不能运动");
    }
    
    connectSer = [NSTimer scheduledTimerWithTimeInterval:1700 target:self selector:@selector(connectSerVer) userInfo:nil repeats:YES];
    
    _startTime = [self saveStartTime];
    //开始计时
    /*
     *@param Interval: 时间间隔，调用 selector
     *
     */
    _timerForLabel = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    
    //其他功能开启
    
    
    //开始每秒从脚踏数据中提取数据计算其他参数以便更新UI
    timerForGetDataForPlot = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTrainingDataForPlot) userInfo:nil repeats:YES];
    _timerForGetDataForUI = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTrainingDataForUI) userInfo:nil repeats:YES];
    
    //开启心率、脚踏板计时器
    _timeHeart = kTimeThread;
    _timeLoop = kTimeThread;
    
    _timerForHeart = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateHeartTime) userInfo:nil repeats:YES];
    _timerForLoop = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLoopTime) userInfo:nil repeats:YES];
    
    //getPoint =  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateMyPoint) userInfo:nil repeats:YES];
    
    
    
    self.distanceLabel.text = @"0.00";
    self.speedLabel.text = @"0.0";
    self.calLabel.text = @"0";
    
}

#pragma mark 更新时间UI，定时回调
- (void)updateTime {
    
    //更新时间UI，每0.1秒执行一次，考虑到主线程的负荷，将此操作执行与子线程。此处使用GCD技术。
    //现在在global中只有一个任务，其实完全可以用串行队列，不过考虑到后续可能会有其他任务与“时间计算任务”异步执行，此处直接使用了global
    
    
    //在global队列上异步“时间计算任务”
    dispatch_async(_globalQueue, ^{
        //       NSLog(@"%@", [NSThread currentThread]);//调试结果显示，线程num = 4
        _countTime +=1;
        NSInteger hour = (int)(_countTime / 3600);
        NSInteger min = (int)((_countTime - hour * 3600)/60);
        NSInteger sec = _countTime - hour * 3600 - min * 60;
        NSString *timeForString = [NSString stringWithFormat:@"%02d:%02d:%02d", hour,min ,sec];
        
        NSString *sprotTimeStr = [NSString stringWithFormat:@"%d", (int)_countTime / 60];
        CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];
        currentAccount.sportTime = sprotTimeStr;
        
        //每次计算完时间，在主线程上更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            _timeLabel.text = timeForString;
        });
    });
}

- (void)updateHeartTime{
    if (_timeHeart != 0) {
        _timeHeart -= 1.0;
    }
}

- (void)updateLoopTime{
    if (_timeLoop != 0) {
        _timeLoop -= 1.0;
    }
}

#pragma mark 获取画图数据并画图
- (void)getTrainingDataForPlot {
    
    _heartRateFloat = get_heart_rate;
    
    _heartRatePreFloat = _heartRateFloat;
    
    //画心率曲线图
    _heartRateString = [NSString stringWithFormat:@"%d", (int)_heartRateFloat];
    self.currentHeartRate = _heartRateString;
    self.heartRateLabel.text = self.currentHeartRate;
}

#pragma mark 获取画图数据并更新UI，距离、速度、卡路里计算
- (void)getTrainingDataForUI
{
    float speed;
    //   NSLog(@"更新UI前的数据_timeLoop = %f", _timeLoop);
    //距离
    if (self.datasParseredLoopNum.count > 0) {
        distance = [[[self.datasParseredLoopNum lastObject] loopNum] floatValue] * kDistanceEachLoop / 1000;
        distance = distance * 1.5;
        self.distance = distance;
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", distance];
    }
    else
    {
        distance = 0;
    }
    
    if (_timeHeart == 0) {
        //没有心率输入
        _heartRateString = [NSString stringWithFormat:@"%d", 0];
        self.currentHeartRate = _heartRateString;
        self.heartRateLabel.text = self.currentHeartRate;
    }
    
    if (_timeLoop == 0) {
        //认为用户没有骑行
        speed = 0.0;
        self.speedLabel.text = @"0.0";
        self.calLabel.text = [NSString stringWithFormat:@"%.0f", _calSum];
    }else{
        //用户骑行中
        //速度
        if (self.datasParseredLoopNum.count >= kICadeDataToSpeedThread) {
            //NSLog(@"count --> %lu",(unsigned long)self.datasParseredLoopNum.count);
            NSDate *dateBack =[[self.datasParseredLoopNum objectAtIndex:kICadeDataToSpeedThread - 1] dateForReceive];
            NSDate *datePre = [[self.datasParseredLoopNum objectAtIndex:0] dateForReceive];
            NSTimeInterval timeInterval = [dateBack timeIntervalSinceDate:datePre];
            //          NSLog(@"检测到的时间为——>%f",timeInterval);
            speed = 3.6 * 3 * (float) kICadeDataToSpeedThread / timeInterval; //距离除以时间
            //          NSLog(@"speed = %f", speed);
            
            //把速度加卡尔曼滤波
            if (countnumberforspeed == 0) {
                
                countnumberforspeed ++;
                averagespeed = speed;
                storespeed = speed;
                
            }else if (countnumberforspeed == 1){
                
                averagespeed = (averagespeed + speed) / 2;
                lastaveragespeed = storespeed;
                countnumberforspeed ++;
                
            }else {
                
                averagespeed = (averagespeed + lastaveragespeed + speed) / 3;
            }
            speed = averagespeed;
            lastaveragespeed = averagespeed;
            
            if (speed > 30) {
                fastTimes++;
                //十秒内速度要是还大于9就播
                if (fastTimes > 10) {
                    fastTimes = 0;
                    [[Function shareFunction] speak:@"您的速度过快，请注意安全。"];
                }
            }
            else if (speed < 7)
            {
                [[Function shareFunction] speak:@"您的速度过慢，请加速以保持健身效果。"];
            }
            self.speedLabel.text = [NSString stringWithFormat:@"%.1f", speed];
            _calSum += [self getCal:_speedLabel.text];
            
            self.calLabel.text = [NSString stringWithFormat:@"%.0f", _calSum];
        }
    }
}

#pragma mark 计算卡路里的公式
-(float)getCal:(NSString *) speed
{
    //卡路里和阻力参数
    float cal, met;
    //获取用户选择的是哪个阻力档位,默认是0位置8档
    //NSInteger tapPos = [_chooseTapPos selectedRowInComponent:0];
    
    NSInteger tapPos = 7;
    if([_climb.titleLabel.text isEqualToString:@"平路"])
    {
        tapPos = 3;
    }
    
    
    //用户资料不全
    if ( _Weight == 0 || _Height == 0)
    {
        met = [[Function shareFunction] accountTapPos:tapPos speed:speed];
        //因为默认是8档，所以刚开始不用判断用户有没有设置阻力档位。8->1
        cal = 1748.7 * met/24/60/60;
    }
    //用户
    else
    {
        met = [[Function shareFunction] unAccountTapPos:tapPos speed:speed];
        //男生
        if (_sex) {
            cal = (66.5 + (13.75*_Weight) + (5.003*_Height) - (6.775*_age)) * met/24/60/60;
        }
        else
        {
            cal = (655.1 + (9.563*_Weight) + (1.850*_Height) - (4.676*_age)) * met/24/60/60;
        }
    }
    return cal;
}


#pragma mark - 音乐选择部分
//#pragma mark 选择歌曲
//-(void)jumpSysMusic
//{
//    _localPlay = NO,_object = 0;
//    NSURL * url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music3" ofType:@"mp3"]];
//    NSURL * url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music4" ofType:@"mp3"]];
//    NSURL * url3 =[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music1" ofType:@"mp3"]];
//    _musicItem = [[NSArray alloc] initWithObjects:url1,url2,url3,nil];
//    [self loadMusic:[_musicItem objectAtIndex:_object]];
//}
//
//-(void)loadMusic:(NSURL * )url
//{
//    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    //单曲循环
//    _player.numberOfLoops = -1;
//}
//
//#pragma mark 播放器--暂停/开始
//- (IBAction)pauseOrStart:(id)sender {
//
//    if (_player.playing) {
//        [_player pause];
//        [_playBtn setImage:[UIImage imageNamed:@"音乐开启.png"] forState:UIControlStateNormal];
//        _beforeBtn.enabled = NO;
//        _nextBtn.enabled = NO;
//    }
//    else
//    {
//        [_player play];
//        [_playBtn setImage:[UIImage imageNamed:@"音乐关闭.png"] forState:UIControlStateNormal];
//        _beforeBtn.enabled = YES;
//        _nextBtn.enabled = YES;
//    }
//}
//
////前后一首播放歌曲
////- (IBAction)skipToPrevious:(id)sender {
////    if (_object != 0) {
////        _object--;
////        [self loadMusic:[_musicItem objectAtIndex:_object]];
////        [_player play];
////    }
////}
//
//- (IBAction)skipToNext:(id)sender {
//    if (_object == 0) {
//        [self loadMusic:[_musicItem objectAtIndex:_object]];
//        [_player play];
//        _object++;
//    }else if( _object == 1){
//        [self loadMusic:[_musicItem objectAtIndex:_object]];
//        [_player play];
//        _object++;
//    }else if(_object == 2){
//        [self loadMusic:[_musicItem objectAtIndex:_object]];
//        [_player play];
//        _object = 0 ;
//    }
//}


#pragma mark - 蓝牙
- (void)buttonDown:(iCadeState)button {
    
    //4：心率
    dispatch_async(_globalQueue, ^{
        
        if (button == iCadeJoystickDown) {
            //重置心率计时器
            _timeHeart = kTimeThread;
            
            //int类型，每次检测到就+1.显示的为心跳总数
            self.heartBeatCount++;
            
        }
        //1：脚踏板
        if (button == iCadeJoystickUp) {
            //重置脚踏板计时器
            _timeLoop = kTimeThread;
            
            
            
            //NSInteger 类型，每次检查到就+1
            self.currentLoopNum++;
            
            //构造模型，保存当前脚踏板总圈数以及每一个圈数的时间
            DataFromICade *loopDataFromICade = [DataFromICade initWithCurrentDateWithLoopNum:self.currentLoopNum];
            
            //模型放入数组中
            [self.datasParseredLoopNum addObject:loopDataFromICade];
            
            //NSLog(@"蓝牙中.datasParseredLoopNum.count  = %d", self.datasParseredLoopNum.count );
            
            //模型数量限制：总共有kICadeDataToSpeedThread个数据（3）
            if (self.datasParseredLoopNum.count > kICadeDataToSpeedThread) {
                [self.datasParseredLoopNum removeObjectAtIndex:0];
            }
        }
    });
}



#pragma mark -获取运动起始时间
- (NSString *)saveStartTime
{
    NSDateFormatter *dateFormtter=[[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormtter stringFromDate:[NSDate date]];
    //NSLog(@"%@",dateString);
    return dateString;
}

#pragma mark - 定时显隐藏head
-(void)showHeadView
{
    //    if (_headView.hidden) {
    //        [UIView animateWithDuration:2.0 animations:^{
    //            _headView.hidden = NO;
    //        }];
    //    }
    //    else
    //    {
    //        [UIView animateWithDuration:2.0 animations:^{
    //            _headView.hidden = YES;
    //        }];
    //    }
}

-(void)addPauseBtn
{
    //添加暂停按钮
    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 35, 70, 70)];
    [_pauseBtn setImage:[UIImage imageNamed:@"继续播放.png"] forState:UIControlStateNormal];
    _pauseBtn.center = self.media.view.center;
    [_pauseBtn addTarget:self action:@selector(playMoive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pauseBtn];
    _pauseBtn.hidden = YES;
}

#pragma mark - 隐藏显示数据
- (IBAction)showData:(UIButton *)sender {
    [UIView animateWithDuration:2.9 animations:^{
        if(sender.tag == 1)
        {
            _leftView.hidden = NO;
            _rightView.hidden = NO;
            _dataSwitch.on = YES;
        }
        else
        {
            _leftView.hidden = YES;
            _rightView.hidden = YES;
            _dataSwitch.on = NO;
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 代码切换横屏
- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - 添加播放器
-(void)addMediaPlay
{
    //沙盒根路径
    NSString *docDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString * path = [NSString stringWithFormat:@"%@/%@.mp4", docDirPath ,current.dirMoive];
    NSURL * url = [NSURL fileURLWithPath:path];
    
    if (url) {
        _media = [[MPMoviePlayerController alloc] initWithContentURL:url];
        _media.controlStyle = MPMovieControlStyleFullscreen; //全屏幕播放
        _media.controlStyle = MPMovieControlStyleNone; //没有播放控件
        _media.scalingMode = MPMovieScalingModeAspectFill;   //控制模式，去掉播放器的黑边，大面积播放
        [_media.view setFrame:CGRectMake(0,0,self.view.frame.size.height,self.view.frame.size.width)];
        //[_media.view setFrame:self.view.frame];
        
        //_media.repeatMode = MPMovieRepeatModeOne; //循环播放
        _media.shouldAutoplay = NO;
        //    //设置开始照片
        NSMutableArray * allThumbnails = [NSMutableArray  arrayWithObjects:[NSNumber numberWithDouble:2.0],nil];
        [_media requestThumbnailImagesAtTimes:allThumbnails timeOption:MPMovieTimeOptionExact];
        //[self.view addSubview:_media.view];
        [self.view insertSubview:_media.view belowSubview:_headView];
    }
}

#pragma mark -  设置
- (IBAction)setting:(UIButton *)sender {
    if (_settingView.hidden) {
        _settingView.hidden = NO;
    }
    else
    {
        _settingView.hidden =  YES;
    }
}

//菜单设置
- (IBAction)settingMenu:(UISwitch *)sender {
    // 显示数据
    if (sender.tag == 1) {
        //显示
        if(sender.on)
        {
            _leftView.hidden = NO;
            _rightView.hidden = NO;
        }
        //不显示
        else
        {
            _leftView.hidden = YES;
            _rightView.hidden = YES;
        }
    }
    //设置爬坡
    else
    {
        //爬坡
        if(sender.on)
        {
            [_climb setTitle:@" 爬坡" forState:UIControlStateNormal];
            [_climb setImage:[UIImage imageNamed:@"爬坡.png"] forState:UIControlStateNormal];
        }
        //平坡
        else
        {
            [_climb setTitle:@" 平坡" forState:UIControlStateNormal];
            [_climb setImage:[UIImage imageNamed:@"平坡.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark -  暂停
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_pauseBtn.hidden) {
        _pauseBtn.hidden = NO;
        //暂停视频
        [_media pause];
    }
    
    //移除其余的显示
    if (!_settingView.hidden) {
        _settingView.hidden = YES;
    }
}

//据需播放视频
-(void)playMoive
{
    _pauseBtn.hidden = YES;
    [self showHeadView];//隐藏
    [_media play];
}



@end
