//
//  LocalTrainViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "LocalTrainViewController.h"
#import <AFNetworking.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CurrentAccount.h"
#import "iCadeReaderView.h"
#import "DataFromICade.h"
#import "Function.h"
#import "MyAlertViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TBActivityIndicatorView.h"

#import "RoadProgressView.h"
#import "PointView.h"
#import "MobClick.h"

#define kTimeThread 3.0
#define kDistanceEachLoop 3
#define kICadeDataToSpeedThread 3

@interface LocalTrainViewController ()<iCadeEventDelegate>
{
    // 多线程操作
    dispatch_queue_t _globalQueue;
    
    CurrentAccount * current;
    
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
    
    //创建用户自己位置的变量，以及存储好友位置的变量
    NSMutableArray * friendPointArray;
    NSInteger * myPoint;
    CGFloat moiveTimeLong; //视频的总时长
    
    //TB菊花框
    TBActivityIndicatorView *_tbActivityIndicatorView;

}

//运动数据缓存池
@property (strong, nonatomic) NSMutableArray *datasParseredLoopNum;
@property (assign, nonatomic) float calSum;
@property (assign, nonatomic) NSInteger currentLoopNum;//脚踏
@property (assign, nonatomic) NSInteger loop_last;//记录上一次的骑行圈数，控制视频播放

//音乐
@property (strong, nonatomic) AVAudioPlayer * player;
@property (strong, nonatomic) NSMutableArray * musicItem; //播放音乐的数组
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (assign, nonatomic) NSUInteger object; //当前播放音乐索引

//爬坡按钮
@property (weak, nonatomic) IBOutlet UIButton *climb;
//蓝牙按钮
@property (weak, nonatomic) IBOutlet UIButton *bluetooth;

@property (strong, nonatomic) MPMoviePlayerController * media;

//数据变化switch
@property (weak, nonatomic) IBOutlet UISwitch *dataSwitch;

//路程更新
@property(nonatomic, strong) RoadProgressView * roadProgressView;
@property(nonatomic, strong)PointView * myPoint;
@property(nonatomic, strong)PointView * onePoint;
@property(nonatomic, strong)PointView * twoPoint;
@property(nonatomic, strong)PointView * threePoint;
@property(nonatomic, strong)PointView * fourPoint;
@property(nonatomic, strong)PointView * fivePoint;

@end

@implementation LocalTrainViewController

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
    [self getInRoom];    //计入房间
    friendPointArray = [NSMutableArray array];
    
    _media = [[MPMoviePlayerController alloc] init];
    [self addMediaPlay]; //播放视频
    [self playMusic];    //播放音乐

    getPoint =  [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateMyPoint) userInfo:nil repeats:YES];
    
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
    [MobClick beginLogPageView:@"街景骑行页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"街景骑行页面"];
}

#pragma mark - 退出训练
- (IBAction)exit:(UIButton *)sender {
    //提示框
    MyAlertViewController * myAlert = [MyAlertViewController alertControllerWithTitle:@"提示" message:@"真的要离开？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        //暂停计时
        [_timerForGetDataForUI invalidate];
        [_timerForLabel invalidate];
        [_player stop];

        [getPoint invalidate];
        
        
        //解决屏闪问题
        [_media stop];
        _media = nil;
        
         
        control.discoveredPeripheral = nil;
        [control removeFromSuperview];
        
        [self getOutRoom];
        
        if ([_distanceLabel.text floatValue] > 0.021) {
            [self.view addSubview:_tbActivityIndicatorView];
            [self uploadData];
        }
        else
        {
            //用户没有骑行，直接返回，不跳转到反馈页面
            [self performSegueWithIdentifier:@"back" sender:nil];
        }
    }];
    [myAlert addAction:cancelAction];
    [myAlert addAction:okAction];
    [self presentViewController:myAlert animated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"***********界面消失了");
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
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/RankServlet?username=%@&nickname=%@&type=ride&cal=%f&mileage=%f&time=%d&date=%@&Hms=%@&property=%@&terminal=2&handle=updatesportdata",[[CurrentAccount sharedCurrentAccount] serverName],[[CurrentAccount sharedCurrentAccount] userName], [[CurrentAccount sharedCurrentAccount] userNickName], self.calSum, self.distance*1000,(int)_countTime, dateStr,HmsStr,current.roadMoive];
    
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
            
            [self performSegueWithIdentifier:@"exitFromLoacal" sender:nil];
            //传递数据到账户单例
            CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
            //分别记录用户到达热身或燃脂等状态的次数
            currenAccount.distance = self.distance;
            currenAccount.calSum = self.calSum;
            
            /*
             NSLog(@"level0 --> %d",self.levelCount0);
             NSLog(@"level1 --> %d",self.levelCount1);
             NSLog(@"level2 --> %d",self.levelCount2);
             NSLog(@"level3 --> %d",self.levelCount3);
             */
        }
        else{
             NSLog(@"Error:");
            [_tbActivityIndicatorView removeFromSuperview];
            //[self showAlertWithString:@"网络异常"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
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
    
    if ([[[self.datasParseredLoopNum lastObject] loopNum] integerValue] == _loop_last)
    {
        [_media pause];
    }
    else
    {
        _loop_last = [[[self.datasParseredLoopNum lastObject] loopNum] integerValue];
        [_media play];
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
    
    if (_timeLoop == 0) {
        //认为用户没有骑行
        speed = 0.0;
        self.speedLabel.text = @"0.0";
        self.calLabel.text = [NSString stringWithFormat:@"%.0f", _calSum];
        [_media pause];
    }
    else{
        //用户骑行中
        //速度
        if (self.datasParseredLoopNum.count >= kICadeDataToSpeedThread) {
            //NSLog(@"count --> %lu",(unsigned long)self.datasParseredLoopNum.count);
            NSDate *dateBack =[[self.datasParseredLoopNum objectAtIndex:kICadeDataToSpeedThread - 1] dateForReceive];
            NSDate *datePre = [[self.datasParseredLoopNum objectAtIndex:0] dateForReceive];
            NSTimeInterval timeInterval = [dateBack timeIntervalSinceDate:datePre];
            speed = 3.6 * 3 * (float) kICadeDataToSpeedThread / timeInterval;
            
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
            speed = averagespeed ;
            lastaveragespeed = averagespeed;
            
            
            
            //在此处添加视频播放速度的控制
            if(speed < 20)
            {
                _media.currentPlaybackRate = 0.7;
            }
            else if(speed > 20 && speed < 40)
            {
                _media.currentPlaybackRate = speed/20.00;
                //NSLog(@"%f",_media.currentPlaybackRate);
            }
            else if (speed > 40 )
            {
                _media.currentPlaybackRate = 2;
            }
            
            self.speedLabel.text = [NSString stringWithFormat:@"%.1f", speed];
            //卡路里
            //_calSum += speed * _Weight * 9.7 * timeInterval / 3600 * 0.05;
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
//#pragma mark 选择歌曲0

-(void)playMusic
{
    _object = 0;
    NSURL * url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music3" ofType:@"mp3"]];
    NSURL * url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music4" ofType:@"mp3"]];
    NSURL * url3 =[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music1" ofType:@"mp3"]];
    _musicItem = [[NSArray alloc] initWithObjects:url1,url2,url3,nil];
    [self loadMusic:[_musicItem objectAtIndex:0]];
}

-(void)loadMusic:(NSURL * )url
{
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //单曲循环
    _player.numberOfLoops = -1;
    [_player play];
}

#pragma mark 播放器--暂停/开始
- (IBAction)pauseOrStart:(id)sender {
    
    if (_player.playing) {
        [_player pause];
        [_playBtn setImage:[UIImage imageNamed:@"音乐开.png"] forState:UIControlStateNormal];
        _nextBtn.enabled = NO;
    }
    else
    {
        [_player play];
        [_playBtn setImage:[UIImage imageNamed:@"音乐关.png"] forState:UIControlStateNormal];
        _nextBtn.enabled = YES;
    }
}


- (IBAction)skipToNext:(id)sender {
    if (_object == 0) {
        _object++;
        [self loadMusic:[_musicItem objectAtIndex:_object]];
        [_player play];
    }else if( _object == 1){
        _object++;
        [self loadMusic:[_musicItem objectAtIndex:_object]];
        [_player play];
        
    }else if(_object == 2){
        _object = 0;
        [self loadMusic:[_musicItem objectAtIndex:_object]];
        [_player play];
        
    }
}


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


#pragma mark - 添加播放器、音乐、位置
-(void)addMediaPlay
{
    //沙盒根路径
    NSString *docDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString * path = [NSString stringWithFormat:@"%@/%@.mp4", docDirPath ,current.roadMoive];
    NSURL * url = [NSURL fileURLWithPath:path];
    
    if (url) {
        _media.contentURL = url;
        _media.controlStyle = MPMovieControlStyleFullscreen; //全屏幕播放
        _media.controlStyle = MPMovieControlStyleNone; //没有播放控件
        _media.scalingMode = MPMovieScalingModeAspectFill;   //控制模式，去掉播放器的黑边，大面积播放
        [_media.view setFrame:CGRectMake(0,0,self.view.frame.size.height,self.view.frame.size.width)];
        //[_media.view setFrame:self.view.frame];
        
        _media.repeatMode = MPMovieRepeatModeNone; //循环播放
        _media.shouldAutoplay = NO;
        //    //设置开始照片
        NSMutableArray * allThumbnails = [NSMutableArray  arrayWithObjects:[NSNumber numberWithDouble:2.0],nil];
        [_media requestThumbnailImagesAtTimes:allThumbnails timeOption:MPMovieTimeOptionExact];
        //[self.view addSubview:_media.view];
        [self.view insertSubview:_media.view belowSubview:_headView];
    }
    
    //获取整个视频的时长
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"road_localMiove.plist"];
    NSArray * moiveArray =[[NSArray alloc]initWithContentsOfFile:docPath];
    for(int i = 0; i < moiveArray.count; i++)
    {
        NSString * selectMoiveId = [moiveArray[i] objectForKey:@"video_id"];
        //NSLog(@"%@ = %@",currentAccount.Moive,selectMoiveId);
        if ([current.roadMoive isEqualToString:selectMoiveId]) {
            NSString * moiveTimeLongStr = [moiveArray[i] objectForKey:@"time_long"];
            moiveTimeLong = [moiveTimeLongStr floatValue];
            NSLog(@"%f",moiveTimeLong);
        }
    }
    
    //进入房间，获取位置信息，更新位置
    
    _roadProgressView = [[RoadProgressView alloc] initWithFrame:CGRectMake(0, _media.view.frame.size.height - 16, _media.view.frame.size.width, 16)];
    _roadProgressView.backgroundColor = [UIColor whiteColor];
    [_media.view addSubview:_roadProgressView];
    _roadProgressView.progress = 0.0;
    [_roadProgressView setNeedsDisplay];
    
    _myPoint = [PointView instancePointView];
    _myPoint.frame = CGRectMake(0, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    _myPoint.imageView.image = [UIImage imageNamed:@"自己.png"];
    
    //先创建5个位置，没有的话不显示
    _onePoint = [PointView instancePointView];
    _onePoint.frame = CGRectMake(0, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    _onePoint.imageView.image = [UIImage imageNamed:@"他人.png"];


    _twoPoint = [PointView instancePointView];
    _twoPoint.frame = CGRectMake(0, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    _twoPoint.imageView.image = [UIImage imageNamed:@"他人.png"];


    _threePoint = [PointView instancePointView];
    _threePoint.frame = CGRectMake(0, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    _threePoint.imageView.image = [UIImage imageNamed:@"他人.png"];

    
    _fourPoint = [PointView instancePointView];
    _fourPoint.frame = CGRectMake(0, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    _fourPoint.imageView.image = [UIImage imageNamed:@"他人.png"];


    _fivePoint = [PointView instancePointView];
    _fivePoint.frame = CGRectMake(0, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    _fivePoint.imageView.image = [UIImage imageNamed:@"他人.png"];

}


#pragma mark - 设置显示位置的位置
-(void)setPoint
{
    if (_media.currentPlaybackTime > 0.0)
    {
        float currentTime = (float)_media.currentPlaybackTime;
        
        //计算出当前播放的比率
        CGFloat playProgress = (currentTime/moiveTimeLong) * _media.view.frame.size.width;
        
        if (_media.view.frame.size.width*(currentTime/moiveTimeLong) > _media.view.frame.size.width)
        {
            playProgress = _media.view.frame.size.width;
        }
        
        _roadProgressView.progress = playProgress;
        [_roadProgressView setNeedsDisplay];
        _myPoint.frame = CGRectMake(playProgress - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
    }
    
    switch ((friendPointArray.count)) {
        case 1:
            _onePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[0] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            break;
        case 2:
                _onePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[0] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
                _twoPoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[1] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            break;
        case 3:
            _onePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[0] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _twoPoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[1] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _threePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[2] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            break;
        case 4:
            _onePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[0] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _twoPoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[1] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _threePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[2] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _fourPoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[3] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            break;
        case 5:
            _onePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[0] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _twoPoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[1] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _threePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[2] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _fourPoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[3] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            _fivePoint.frame = CGRectMake(_media.view.frame.size.width*([[friendPointArray[4] objectForKey:@"completeRate"] floatValue] / moiveTimeLong) - 9, _media.view.frame.size.height - 16 - _myPoint.frame.size.height, _myPoint.frame.size.width, _myPoint.frame.size.height);
            break;
    }
}


#pragma mark - 进入房间发送信号
-(void)getInRoom
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/vistaVideoServlet?type=joinroom&id=%@",current.serverName,current.roadMoive];
    //NSLog(@"urlString = %@",urlString);
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
            NSLog(@"进入房间成功");
            [self getFriendPoint];
        }else{
            //账号登陆失败，帮用户进行注册、登陆
            NSLog(@"进入房间失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - 退出房间发送信号
-(void)getOutRoom
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/vistaVideoServlet?type=getout",current.serverName];
    
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
            NSLog(@"退出房间成功");
        }else{
            //账号登陆失败，帮用户进行注册、登陆
            NSLog(@"退出房间失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - 获取好友的位置、设置头像添加点
-(void)getFriendPoint
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/vistaVideoServlet?type=getcompany&id=%@",current.serverName,current.roadMoive];
    //NSLog(@"urlString = %@",urlString);
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
            NSLog(@"获取位置成功");
            friendPointArray = [dictionary objectForKey:@"content"];
            NSLog(@"获取位置%@",friendPointArray);
            
            //设置头像添加点
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //如果被添加了，就不用再添加了
                if (![_onePoint.superview isEqual:_media.view]) {
                    switch (friendPointArray.count) {
                        case 1:
                            _onePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[0] objectForKey:@"user_head_id"] integerValue]]];
                            [_media.view addSubview:_onePoint];
                            break;
                        case 2:
                            _onePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[0] objectForKey:@"user_head_id"] integerValue]]];
                            _twoPoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[1] objectForKey:@"user_head_id"] integerValue]]];
                            [_media.view addSubview:_onePoint];
                            [_media.view addSubview:_twoPoint];
                            break;
                        case 3:
                            _onePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[0] objectForKey:@"user_head_id"] integerValue]]];
                            _twoPoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[1] objectForKey:@"user_head_id"] integerValue]]];
                            _threePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[2] objectForKey:@"user_head_id"] integerValue]]];
                            [_media.view addSubview:_onePoint];
                            [_media.view addSubview:_twoPoint];
                            [_media.view addSubview:_threePoint];
                            break;
                        case 4:
                            _onePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[0] objectForKey:@"user_head_id"] integerValue]]];
                            _twoPoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[1] objectForKey:@"user_head_id"] integerValue]]];
                            _threePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[2] objectForKey:@"user_head_id"] integerValue]]];
                            _fourPoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[3] objectForKey:@"user_head_id"] integerValue]]];
                            [_media.view addSubview:_onePoint];
                            [_media.view addSubview:_twoPoint];
                            [_media.view addSubview:_threePoint];
                            [_media.view addSubview:_fourPoint];
                            break;
                        case 5:
                            _onePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[0] objectForKey:@"user_head_id"] integerValue]]];
                            _twoPoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[1] objectForKey:@"user_head_id"] integerValue]]];
                            _threePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[2] objectForKey:@"user_head_id"] integerValue]]];
                            _fourPoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[3] objectForKey:@"user_head_id"] integerValue]]];
                            _fivePoint.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head%02ld.png",(long)[[friendPointArray[4] objectForKey:@"user_head_id"] integerValue]]];
                            [_media.view addSubview:_onePoint];
                            [_media.view addSubview:_twoPoint];
                            [_media.view addSubview:_threePoint];
                            [_media.view addSubview:_fourPoint];
                            [_media.view addSubview:_fivePoint];
                            break;
                    }
                    [self.media.view addSubview:_myPoint];
                }
                //获取完好友位置之后开始显示
                [self setPoint];
                
            });

            
        }else{
            //账号登陆失败，帮用户进行注册、登陆
            NSLog(@"获取位置失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma  mark - 更新自己和其他人的位置
-(void)updateMyPoint
{
    int myPoint = _media.currentPlaybackTime;
    NSString * friendList;
    for (int i = 0; i < friendPointArray.count; i++) {
        //已经添加过得骑行用户
        if (friendList) {
            friendList = [NSString stringWithFormat:@"%@,%@",friendList,[friendPointArray[i] objectForKey:@"userName"]];
        }
        else{
            friendList = [NSString stringWithFormat:@"%@",[friendPointArray[i] objectForKey:@"userName"]];
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/vistaVideoServlet?type=flashinfo&mycurrent=%d&company=%@",current.serverName,myPoint,friendList];
    //    NSLog(@"urlString = %@",urlString);
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        int retLogin = [[dictionary objectForKey:@"ret"] intValue];
        
        if (retLogin == 1) {
            friendPointArray = [dictionary objectForKey:@"content"];
            NSLog(@"更新位置friendPointArray = %@",friendPointArray);
            [self setPoint];
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
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
    //移除其余的显示
    if (!_settingView.hidden) {
        _settingView.hidden = YES;
    }
}

@end
