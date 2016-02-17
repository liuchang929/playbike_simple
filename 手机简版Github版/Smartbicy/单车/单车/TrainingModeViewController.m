//
//  TrainingModeViewController.m
//  SmartBicycle
//   周计划提示框13 点击结束是的提醒框14
//  Created by comfouriertech on 14-6-6.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "TrainingModeViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CurrentAccount.h"
#import <math.h>
#import "iCadeReaderView.h"
#import <AFNetworking.h>
#import "TBActivityIndicatorView.h"
#import "Function.h"
#import "iphoneLayout.h"
#import "WeekPlanViewController.h"

#import "LeftNavigationController.h"
#import "CurrentAccount.h"

#import "MobClick.h"

#define kIsStarting YES;
#define kXRangeInView   10.0
#define kHRmaxDefault   190
#define kWeightDefault     70
#define kHeightDefault  175
#define kAgeDefault     23
#define kSexDefault     1
#define kBLEDataToHeartRateThread 8
#define kICadeDataToSpeedThread 3
#define kThreadFilter 8
#define kArcViewStartDegree -225
#define kArcViewEndMaxDegree 45
#define kDistanceEachLoop 3
#define kTimeThread 3.0

#pragma mark —— 设置心率曲线的原点坐标以及长度宽度
//core-plot  graph frame 300,200, 360, 360
#define kXStartGraph ([UIScreen mainScreen].bounds.size.width * 10 / 1024.0f)
#define kYStartGraph ([UIScreen mainScreen].bounds.size.height * 500 / 768.0f)
#define kGraphWidth ([UIScreen mainScreen].bounds.size.width * 1260 / 1024.0f)
#define kGraphHeight ([UIScreen mainScreen].bounds.size.height * 200 / 768.0f)


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)


@interface  TrainingModeViewController() <MPMediaPickerControllerDelegate, iCadeEventDelegate> {
    //界面底下三按键
    CurrentAccount *_currentAccount;
    
    BOOL _isGuest;
    
    //GCD
    dispatch_queue_t _globalQueue;
    dispatch_queue_t _serialQueue;
    
    BOOL isStarted; //是否开始
    
    float countTime; //当前的时间
    NSTimer *timer;
    
    NSTimer *timerForGetDataForPlot;
    NSTimer *timerForGetDataForUI;
    
    // 距离播报
    NSTimer * distanceSpeak;
    
    //计时器，检测心率、脚踏板是否还有输入
    NSTimer *_timerForHeart;
    NSTimer *_timerForLoop;
    float _timeHeart;
    float _timeLoop;
    
    //音乐
    MPMediaPickerController *mpc;
    MPMusicPlayerController *musicPlayer;
    MPMediaItemCollection *itemList;
    

    //用户数据
    float _HRmax;
    float _Weight;
    float _Height;
    int _age;
    int _sex;//男生是1， 女生是0
    NSString * _birthday; //生日
    BOOL _guestAccount;
    
    //运动起始时间
    NSString *_startTime;
    
    //心率
    NSString *_heartRateString;
    NSInteger _heartBeatInteger;
    float _heartRateFloat;
    float _heartRatePreFloat;
    NSInteger _sum;
    NSInteger _yPercentLastInt;
    
    //调整速度
    int countnumberforspeed;
    float averagespeed;
    float lastaveragespeed;
    float lastspeed;
    float storespeed;
    
    //截图
    UIImage *_currentImage;
    
    //TB菊花框
    TBActivityIndicatorView *_tbActivityIndicatorView;

    int aimDistance; //本次骑行的目标距离
    float distance;
    int fastTimes;   //为了判断用户的骑行速度过快的语音播报
    
    WeekPlanView * weekPlanView; //单次计划的视图
    
    BOOL  updateLoop;
    iCadeReaderView *control;
    
    
    //时间字符串
    NSString *timeForString;
    
    //档位
    UIPickerView *_posPicker;
    NSArray *_posList;
    
    //蓝牙显示
    UIButton * blueBtn;
}

@property (strong, nonatomic) NSString *currentHeartRate;

//心率
@property (assign, nonatomic) int heartBeatCount;
@property (strong, nonatomic) NSMutableArray *datasParsered;

//脚踏
@property (assign, nonatomic) NSInteger currentLoopNum;
@property (strong, nonatomic) NSMutableArray *datasParseredLoopNum;
@property (assign, nonatomic) float calSum;

//记录当前播放的时那首歌曲
@property (assign, nonatomic) NSUInteger object;
//当前播放的时本地音乐
@property (assign, nonatomic) BOOL localPlay;


@end

@implementation TrainingModeViewController

#pragma mark DidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置屏幕常亮
    [[ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
    
    //载入当前账户信息
    [self loadCurrentAccount];
    


    blueBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 15)];
    [blueBtn setImage:[UIImage imageNamed:@"蓝牙断开.png"] forState:UIControlStateNormal];
    [blueBtn setTitle:@" 蓝牙已断开" forState:UIControlStateNormal];
    [blueBtn.titleLabel setFont:[UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:12]];
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithCustomView:blueBtn];
    self.navigationItem.rightBarButtonItem = backBtn;
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem * back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    //[self pickViewSetting:_chooseTapPos tag:11];
    
    [self jumpSysMusic];


    [self setHRmax];                   //设置最大心率
    [self initCurrentData];            //初始化的用户信息 为计算卡路里使用
    
//    [self showOnePlan];
    

    _posList = [NSArray arrayWithObjects:@"爬坡",@"平路", nil];
    
    _posPicker = [[UIPickerView alloc]init];
    //代理
    _posPicker.delegate = self;
    _posPicker.dataSource = self;
    _posText.text = @"爬坡";
    [_posText setInputView:_posPicker]; //实现的是点击textField输入就弹出pickView
    
    
    //获取队列
    _globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    /******************  设置开关初始状态 ***************/
    isStarted = kIsStarting;
    //[_startOrEndButton setBackgroundImage:[UIImage imageNamed:@"开始@2x.png" ] forState:UIControlStateNormal];
    
    //没连上蓝牙，不可点击
    _startOrEndButton.enabled = NO;
    
    _heartRateString = @"";
    _heartBeatInteger = 0;
    _heartRateFloat = 0.0f;
    _sum = 0;
    //初始化数据选择信息
    _pickViewData = [[NSArray alloc] initWithObjects:@"8",@"7",@"6",@"5",@"4",@"3",@"2",@"1", nil];
    _onePlanData =  [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    //初始化数据显示
    self.distanceLabel.text = [NSString stringWithFormat:@"00"];
    self.speedLabel.text = @"0.0";
    self.calLabel.text = @"0";

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //此处为了调试方便，将按钮设置为可以点击，在正式过程中，请删除此句
    _startOrEndButton.enabled = YES;
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /********************** 初始化icade *****************/
    control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:control];
    //control.active = YES;
    control.delegate = self;
    
    self.datasParsered = [NSMutableArray array];
    self.datasParseredLoopNum = [NSMutableArray array];
    
    
    
    //提醒用户到目标距离
    distanceSpeak = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(aimMessageSpeak) userInfo:nil repeats:YES];
    
    
    NSMutableArray * roundImage = [NSMutableArray array];
    for (int i = 1; i < 25; i++) {
        NSString * imageStr = [NSString stringWithFormat:@"%d.png",i];
        UIImage * image = [UIImage imageNamed:imageStr];
        [roundImage addObject:image];
    }
    _roundImageView.animationImages = roundImage;
    _roundImageView.animationDuration = 0.8;
    _roundImageView.animationRepeatCount = 0;
    //[_roundImageView startAnimating];
    
    [self inittBActivityIndicatorView];

}

#pragma mark - TB加载框初始化
- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@""];
}

-(void)back
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否结束本次训练" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: @"取消", nil];
    alertView.tag = 14;
    [alertView show];
}

-(void)blueToothConnect:(NSNotification * ) notifation
{
    if ([notifation.name  isEqualToString:@"break"]) {
        //////////显示框弹出蓝牙已经连接
        [blueBtn setImage:[UIImage imageNamed:@"蓝牙断开.png"] forState:UIControlStateNormal];
        [blueBtn setTitle:@" 蓝牙已断开" forState:UIControlStateNormal];

    }
    else if ([notifation.name  isEqualToString:@"connect"]) {
        //////////显示框弹出蓝牙已经连接
        [blueBtn setImage:[UIImage imageNamed:@"蓝牙.png"] forState:UIControlStateNormal];
        [blueBtn setTitle:@" 蓝牙已连接" forState:UIControlStateNormal];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"自由训练页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"自由训练页面"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //将要推出界面的时候音乐停止
    [_player stop];
    //暂停距离播报
    [distanceSpeak invalidate];
    [_timerForHeart invalidate];
    [_timerForLoop invalidate];
    [timerForGetDataForPlot invalidate];
    [timerForGetDataForUI invalidate];
    [timer invalidate];
    
//    //界面消失的时候，需要将蓝牙经纪人关闭， 因为苹果自动释放，这是野指针的方法释放一下吧
    control.centralManager = nil;
}


#pragma mark - 用户过每过半个小时重新登录一次
-(void)connectSerVer
{
    //获取用户输入的登录信息
    NSString * name = [[CurrentAccount sharedCurrentAccount] userName];
    NSString * pwd =  [[CurrentAccount sharedCurrentAccount] userPassword];
     NSLog(@"name = %@ pwd = %@", name, pwd);
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Login?type=login&username=%@&password=%@", [[CurrentAccount sharedCurrentAccount] serverName],name, pwd];
   
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
  //          NSLog(@"登陆成功");
        }else{
            //账号登陆失败，帮用户进行注册、登陆
             NSLog(@"登陆失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}
     

-(void)aimMessageSpeak
{//提醒用户离本次目标还有多少距离
    [[Function shareFunction] remind:aimDistance distance:distance];
}


#pragma mark - 保存、读取周计划部分
//-(NSString *)datafilePath
//{   //返回数据文件的完整路径名。
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    return [docPath stringByAppendingPathComponent:@"weekPlan.plist"];
//}
//
////保存数据
//-(void)saveWeekComplete
//{
//    NSString * path = [self datafilePath];
//    _weekPlanDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
//    if (_weekPlanDic) {
//        float completeDistance = _distance + [[_weekPlanDic objectForKey:@"complete"] floatValue];
//        NSString * completeStr = [NSString stringWithFormat:@"%0.2f",completeDistance];
//        NSLog(@"%@",completeStr);
//        [_weekPlanDic setObject:completeStr forKey:@"complete"];
//        [_weekPlanDic writeToFile:[self datafilePath] atomically:YES];
//    }
//}
//
//#pragma mark - 单次计划设置View
//-(void)showOnePlan
//{
//    weekPlanView = [[WeekPlanView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:weekPlanView];
//    
//    //关闭按钮
//    UIButton * close = [UIButton buttonWithType:UIButtonTypeCustom];
//    [close setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
//    [close addTarget:self action:@selector(closeMessageView:) forControlEvents:UIControlEventTouchUpInside];
//    
//    NSString * plistPath = [self datafilePath];
//    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
//    
//    _tenNum = [[UIPickerView alloc] init];
//    _Num = [[UIPickerView alloc] init];
//    
//    [[iphoneLayout shareIphoneLayout] GuestAccount:_guestAccount Ten:_tenNum num:_Num closeBtn:close dictionary:dictionary];
//    
//    [self pickViewSetting:_tenNum tag:10];
//    [self pickViewSetting:_Num tag:10];
//    [self.view addSubview:close];
//}
//
////关闭单次计划
//-(void)closeMessageView:(UIButton * ) btn
//{
//    NSInteger ten = [_tenNum selectedRowInComponent:0];
//    NSInteger num = [_Num selectedRowInComponent:0];
//    aimDistance = ten * 10  + num;
//    //  aimDistance = _tenNum * 10 + _Num ;
//    NSLog(@"aimdistance is %d", aimDistance);
//    //移除各个控件
//    [btn removeFromSuperview];
//    [_tenNum removeFromSuperview];
//    [_Num removeFromSuperview];
//    [weekPlanView removeFromSuperview];
//    
//    NSString *number2 = [NSString stringWithFormat:@"%d km",aimDistance];
//    goalKm.text = number2;
//}
//
//设置PickView的一些属性
-(void)pickViewSetting:(UIPickerView *) pick tag:(int)tag
{
    pick.tag = tag;
    pick.delegate = self;
    pick.dataSource = self;
    pick.showsSelectionIndicator = YES;
    [pick setBackgroundColor:[UIColor clearColor]];
    pick.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view  addSubview:pick];
}


#pragma mark 设置最大心率
- (void)setHRmax
{
    CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
    NSLog(@"currenAccount.userHRMax = %@", currenAccount.userHRMax);
    if (currenAccount.userHRMax != nil ) {
        _HRmax = [currenAccount.userHRMax floatValue];
        _Weight = [currenAccount.userWeight floatValue];
    }else {
        _HRmax = kHRmaxDefault;
        _Weight = kWeightDefault;
    }
}

#pragma mark 获取用户的信息、年龄、身高等
-(void)initCurrentData
{
    CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
    _guestAccount = currenAccount.guestAccount; //判断是不是游客
    if (!_guestAccount) {
        _Weight = [currenAccount.userWeight floatValue];
        _Height = [currenAccount.userHeight floatValue];
        
        //年龄，用于计算卡路里
        _birthday =currenAccount.userBirthday ;
        //获取系统时间， 用于计算年龄
        NSDate *now = [NSDate date];
        NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"YYYY-mm-dd"];
        NSString * nowTime = [inputFormatter stringFromDate:now];
        NSLog(@"date= %@,", nowTime);
        _age = [[nowTime substringToIndex:4] intValue] - [[_birthday substringToIndex:4] intValue];
        
        //获取用户的性别
        NSString * sex = currenAccount.userSex;
        NSLog(@"sex = %@",sex);
        //男女
        if ([sex isEqualToString:@"male"]) {
            _sex = 1;
        }
        else
        {
            _sex = 0;
        }
    }
    else {
        _Weight = kWeightDefault;
        _Height = kHeightDefault;
        _sex = kSexDefault;
        _age = kAgeDefault;
    }
    //NSLog(@"age = %d, sex = %d, w = %f, h = %f", _age, _sex, _Weight, _Height);
}


#pragma mark 计算卡路里的公式
-(float)getCal:(NSString *) speed
{
    //卡路里和阻力参数
    float cal, met;
    //获取用户选择的是哪个阻力档位,默认是0位置8档
    //NSInteger tapPos = [_chooseTapPos selectedRowInComponent:0];
    
    NSInteger tapPos = 7;
    if([_posText.text isEqualToString:@"平路"])
    {
        tapPos = 3;
    }
    

    //用户
    if (!_guestAccount)
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
    //游客
    else
    {
        met = [[Function shareFunction] accountTapPos:tapPos speed:speed];
        //因为默认是8档，所以刚开始不用判断用户有没有设置阻力档位。8->1
        cal = 1748.7 * met/24/60/60;
    }
    return cal;
}

#pragma mark 模式开始/暂停按钮
- (IBAction)startOrEnd:(UIButton *)sender {
    if (isStarted)
    {
        [_player play];
        
        [_roundImageView startAnimating];
        _infoBtn.enabled = NO;
        _historyBtn.enabled = NO;
        _weekPlanBtn.enabled = NO;
        
        //button正显示开始，将改为暂停，背景颜色改变。说明将start程序
        //用户起时间长了就提交不了数据了，因为连接时间的请求只能是半个小时
        [NSTimer scheduledTimerWithTimeInterval:1700 target:self selector:@selector(connectSerVer) userInfo:nil repeats:YES];
        isStarted = NO;
        [[Function shareFunction] speak:@"健身开始，请先保持3分钟低速运动热身"];
        
        [_startOrEndButton setBackgroundImage:[UIImage imageNamed:@"自由训练结束.png"] forState:UIControlStateNormal];
        
        _startTime = [[Function shareFunction] saveStartTime]; //获取当前系统时间，记录运动开始的时间
        //开始计时
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
        //其他功能开启
        //开始每秒从接收到数据中提取用于画图的数据
        timerForGetDataForPlot = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTrainingDataForPlot) userInfo:nil repeats:YES];
        
        //开始每秒从脚踏数据中提取数据计算其他参数以便更新UI
        timerForGetDataForUI = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTrainingDataForUI) userInfo:nil repeats:YES];
        
        //开启心率、脚踏板计时器
        _timeHeart = kTimeThread;
        _timeLoop = kTimeThread;
        
        _timerForHeart = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateHeartTime) userInfo:nil repeats:YES];
        _timerForLoop = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLoopTime) userInfo:nil repeats:YES];
        
        
    } else { //button显示暂停，将改为开始。说明将pause程序
        [_roundImageView stopAnimating];
        isStarted = YES;
        [_startOrEndButton setBackgroundImage:[UIImage imageNamed:@"自由训练开始.png"] forState:UIControlStateNormal];
        
        //暂停计时,  在alertView的响应中点击取消回复计时
        [timer invalidate];
        //停止每秒从接收的蓝牙数据中提取用于画图的数据
        [timerForGetDataForPlot invalidate];
        //停止每秒从接收的蓝牙数据中提取用于UI的数据
        [timerForGetDataForUI invalidate];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否结束本次训练" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: @"取消", nil];
        alertView.tag = 14;
        [alertView show];
    }
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
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/RankServlet?username=%@&nickname=%@&type=train&cal=%f&mileage=%f&time=%d&date=%@&Hms=%@&property=0&terminal=2&handle=updatesportdata",[[CurrentAccount sharedCurrentAccount] serverName],[[CurrentAccount sharedCurrentAccount] userName], [[CurrentAccount sharedCurrentAccount] userNickName], self.calSum, self.distance*1000,(int)countTime, dateStr,HmsStr];
    
    //NSLog(@"%@",urlString);
    
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
//        NSLog(@"ret = %d", ret);
        
        if (ret == 1) {
            //取消加载框
            [_tbActivityIndicatorView removeFromSuperview];
            
            [self performSegueWithIdentifier:@"trainingEnd" sender:nil];
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
            [self showAlertWithString:@"网络异常"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@",error);
        [_tbActivityIndicatorView removeFromSuperview];
        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        [self showAlertWithString:@"网络异常"];
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}


#pragma mark 更新时间UI，定时回调
- (void)updateTime {
    
    //更新时间UI，每0.1秒执行一次，考虑到主线程的负荷，将此操作执行与子线程。此处使用GCD技术。
    //现在在global中只有一个任务，其实完全可以用串行队列，不过考虑到后续可能会有其他任务与“时间计算任务”异步执行，此处直接使用了global
    
    
    //在global队列上异步“时间计算任务”
    dispatch_async(_globalQueue, ^{
        //       NSLog(@"%@", [NSThread currentThread]);//调试结果显示，线程num = 4
        countTime +=0.1;
        int hour = (int)(countTime / 3600);
        int min = (int)((countTime - hour * 3600)/60);
        int sec =(int) (countTime - hour * 3600 - min * 60);
        
       
        timeForString = [NSString stringWithFormat:@"%02d:%02d:%02d", hour,min ,sec];
        
        //将运动时间传递给单例
        //NSString *sprotTimeStr = [NSString stringWithFormat:@"%02d小时%02d分%02d秒", hour,min ,sec];
        NSString *sprotTimeStr = [NSString stringWithFormat:@"%d", (int)countTime / 60];
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
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", distance];
        self.distance = distance;
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
        _stateOfExercise.text = @"";
        
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

#pragma mark - 音乐选择部分
#pragma mark 选择歌曲
-(void)jumpSysMusic
{
    _localPlay = NO,_object = 0;
    NSURL * url1 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music3" ofType:@"mp3"]];
    NSURL * url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music4" ofType:@"mp3"]];
    NSURL * url3 =[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music1" ofType:@"mp3"]];
    _musicItem = [[NSArray alloc] initWithObjects:url1,url2,url3,nil];
    [self loadMusic:[_musicItem objectAtIndex:_object]];
}

-(void)loadMusic:(NSURL * )url
{
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //单曲循环
    _player.numberOfLoops = -1;
    [_playBtn setImage:[UIImage imageNamed:@"音乐关闭.png"] forState:UIControlStateNormal];
}

#pragma mark 播放器--暂停/开始
- (IBAction)pauseOrStart:(id)sender {

    if (_player.playing) {
        [_player pause];
        [_playBtn setImage:[UIImage imageNamed:@"音乐开启.png"] forState:UIControlStateNormal];
        _beforeBtn.enabled = NO;
        _nextBtn.enabled = NO;
    }
    else
    {
        [_player play];
        [_playBtn setImage:[UIImage imageNamed:@"音乐关闭.png"] forState:UIControlStateNormal];
        _beforeBtn.enabled = YES;
        _nextBtn.enabled = YES;
    }
}

//前后一首播放歌曲
//- (IBAction)skipToPrevious:(id)sender {
//    if (_object != 0) {
//        _object--;
//        [self loadMusic:[_musicItem objectAtIndex:_object]];
//        [_player play];
//    }
//}

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


#pragma mark - 文字提示框
- (void)showAlertWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

#pragma mark - 截图分享
#pragma mark 截图分享功能实现
- (IBAction)shareWithPhoto:(UIButton *)sender {
    
    //截图,并保存至当前图片  _currentImage
    _currentImage = [[Function shareFunction] captureScreen];
    
    //保存至设备相册
    UIImageWriteToSavedPhotosAlbum(_currentImage, self,nil, nil);
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"分享至" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"朋友圈", nil];
    shareSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [shareSheet showInView:self.view];
}

#pragma mark - UIActionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //分享至 微信
            [[Function shareFunction] sendImageContentWithImage:_currentImage InScene:0];
            break;
            
        case 1:
            //分享至 朋友圈
            [[Function shareFunction] sendImageContentWithImage:_currentImage InScene:1];
            break;
    }
}


#pragma mark - alertView 代理方法
#pragma mark 点击按钮后
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //导航栏提醒框
    if (alertView.tag == 13) {
        switch (buttonIndex) {
            case 0:
                [self presentViewController:(UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"] animated:YES completion:nil];
                break;
            case 1:
                //重新恢复计时器
                timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                break;
        }
    }
    //结束提醒框
    else
    {
        switch (buttonIndex) {
            case 0:
            {
                
                //用户确定将将结束运动
                _infoBtn.enabled = YES;
                _historyBtn.enabled = YES;
                _weekPlanBtn.enabled = YES;
                
                //如果不是游客，则上传运动数据到服务器
                CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
                if (!currentAccount.guestAccount) {
                    //弹出加载框
                    [self.view addSubview:_tbActivityIndicatorView];
                    
                    //测试使用代码
                    //_distanceLabel.text = @"0.022";
                    
                    if ([_distanceLabel.text floatValue] > 0.021) {
                        //添加风火轮
                        [self.view addSubview:_tbActivityIndicatorView];
                        [self uploadData];
                    }
                    else
                    {
                        [self performSegueWithIdentifier:@"trainBack" sender:nil];
                    }
                    //[self saveWeekComplete];
                }else{
                    [self performSegueWithIdentifier:@"trainingEnd" sender:nil];
                    //传递数据到账户单例
                    CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
                    currenAccount.distance = self.distance;
                }
            }
                [timerForGetDataForPlot invalidate];
                [timerForGetDataForUI invalidate];
                [timer invalidate];
                break;
            case 1:
            {
                //点击了取消
                [_roundImageView startAnimating];
                isStarted = NO;
                 _startOrEndButton.titleLabel.font = [UIFont systemFontOfSize: 22.0];
                [_startOrEndButton setBackgroundImage:[UIImage imageNamed:@"自由训练结束.png"] forState:UIControlStateNormal];
                
                timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                
                //其他功能开启
                //开始每秒从接收到数据中提取用于画图的数据
                timerForGetDataForPlot = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTrainingDataForPlot) userInfo:nil repeats:YES];
                
                //开始每秒从脚踏数据中提取数据计算其他参数以便更新UI
                timerForGetDataForUI = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTrainingDataForUI) userInfo:nil repeats:YES];
            }
                break;
        }
    }
}


#pragma mark pickView个性设置 (档位选择)
//只有一组选择数据
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//本组有多少个数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView.tag == 10) {
        return [_onePlanData count];
    }
    else if (pickerView == _posPicker) {
        //默认在用户点击输入框后，默认显示为男
        return [_posList count];
    }
    return [_pickViewData count];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark 每行具体数据
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _posPicker) {
        //默认在用户点击输入框后，默认显示为男
        return _posList[row];
    }
    return @"";
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *stringText = [self pickerView:pickerView titleForRow:row forComponent:component];
    UILabel *stringLabel = [[UILabel alloc] init];
    stringLabel.font = [UIFont systemFontOfSize:25.0];
    stringLabel.text = stringText;
    stringLabel.textAlignment = NSTextAlignmentCenter;
    return stringLabel;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

#pragma mark 当选择时
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    NSLog(@"选择");
    if (pickerView == _posPicker) {
        _posText.text = _posList[row];
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - 控制屏幕旋转
- (BOOL)shouldAutorotate
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight ;
}

#pragma mark 获取当前账号信息
- (void)loadCurrentAccount
{
    _currentAccount = [CurrentAccount sharedCurrentAccount];
}


- (IBAction)infoBtn:(id)sender {
    CATransition *animation = [CATransition animation];
    
    //从右向左
    [animation setSubtype:kCATransitionFromRight];
    
    [self.navigationController.view.layer addAnimation:animation forKey:@"animation"];

    [self performSegueWithIdentifier:@"个人信息设置" sender:nil];
}

- (IBAction)historyCheckButton:(UIButton *)sender {
    if (_isGuest) {
        [self showAlertWithString:@"请先登录账户"];
    }else{
        [self viewDidDisappear:YES];
        [self performSegueWithIdentifier:@"历史数据" sender:nil];
    }
}

- (IBAction)weekPlanButton:(id)sender {
    if (_isGuest) {
        [self showAlertWithString:@"请先登录账户"];
    }else{
        [self performSegueWithIdentifier:@"周计划设置" sender:nil];
//         [self showAlertWithString:@"该功能暂未开放"];
    }
}

@end
