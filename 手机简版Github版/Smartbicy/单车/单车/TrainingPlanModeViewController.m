//
//  TrainingPlanModeViewController
//  SmartBicycle
//   周计划提示框13 点击结束是的提醒框14
//  Created by comfouriertech on 14-6-6.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "TrainingPlanModeViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CurrentAccount.h"
#import <math.h>
#import "iCadeReaderView.h"
#import <AFNetworking.h>
#import "TBActivityIndicatorView.h"
#import "Function.h"
#import "iphoneLayout.h"


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

//core-plot  graph frame 250,200, 360, 360
#define kXStartGraph ([UIScreen mainScreen].bounds.size.width * 300 / 1024.0f)
#define kYStartGraph ([UIScreen mainScreen].bounds.size.height * 200 / 768.0f)
#define kGraphWidth ([UIScreen mainScreen].bounds.size.width * 360 / 1024.0f)
#define kGraphHeight ([UIScreen mainScreen].bounds.size.height * 360 / 768.0f)


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)


@interface  TrainingPlanModeViewController() <MPMediaPickerControllerDelegate, iCadeEventDelegate> {
    
    //GCD
    dispatch_queue_t _globalQueue;
    dispatch_queue_t _serialQueue;
    
    BOOL isStarted; //是否开始
    
    float countTime; //当前的时间
    NSTimer *timer;
    
    NSTimer *timerForGetDataForPlot;
    NSTimer *timerForGetDataForUI;
    
    //语音播报计时器
    NSTimer *speak;
    
    //计时器，检测心率、脚踏板是否还有输入
    NSTimer *_timerForHeart;
    NSTimer *_timerForLoop;
    float _timeHeart;
    float _timeLoop;
    
    //音乐
    MPMediaPickerController *mpc;
    MPMusicPlayerController *musicPlayer;
    MPMediaItemCollection *itemList;
    
    //画图
    CPTXYGraph * _graph;
    CPTXYPlotSpace * _plotSpace;
    NSMutableArray * _dataReceivedFromBLE;
    NSMutableArray * _dataForPlotTest;
    // float countTime;
    CPTXYAxis * y;
    int xIndex;
    int testCount;
    
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
    
    //截图
    UIImage *_currentImage;
    
    //TB菊花框
    TBActivityIndicatorView *_tbActivityIndicatorView;
    
    //训练计划里面的数据
    NSDictionary * trainingPlanDic;
    //存放用户的心率范围
    NSString * heart_min;
    NSString * heart_two;
    NSString * heart_three;
    NSString * heart_max;
    int exitTimeLimit; //记录用户退出时间是否为放松的界限
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

//iphone布局
@property (strong, nonatomic) UILabel * timeLable_;
@property (strong, nonatomic) UILabel * calLable_;
@property (strong, nonatomic) UILabel * distanceLable_;
@property (strong, nonatomic) UILabel * speedLable_;
@property (strong, nonatomic) UILabel * calTitle_;
@property (strong, nonatomic) UILabel * distanceTitle_;
@property (strong, nonatomic) UILabel * speedTitle_;

@end

@implementation TrainingPlanModeViewController

#pragma mark DidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(returnRunRunFast)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [self initShareButton];            //分享按钮，如果用户没有安装微信，隐藏分享按钮
    [self UILayoutInit];               // UI布局
    [self inittBActivityIndicatorView];//初始化TB菊花框
    [self setHRmax];                   //设置最大心率
    [self setupCoreplotViews];         //心率图或者是燃脂图
    [self initCurrentData];            //初始化的用户信息 为计算卡路里使用
    [self createMusicBtn];
    
    //获取队列
    _globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    /******************  设置开关初始状态 ***************/
    isStarted = kIsStarting;
    _startOrEndButton.backgroundColor = [UIColor colorWithRed:1.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
    //没连上蓝牙，不可点击
    _startOrEndButton.enabled = NO;
    
    _heartRateString = @"";
    _heartBeatInteger = 0;
    _heartRateFloat = 0.0f;
    _sum = 0;
    //初始化数据选择信息
    _pickViewData = [[NSArray alloc] initWithObjects:@"8",@"7",@"6",@"5",@"4",@"3",@"2",@"1", nil];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //此处为了调试方便，将按钮设置为可以点击，在正式过程中，请删除此句
    _startOrEndButton.enabled = YES;
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /********************** 初始化icade *****************/
    iCadeReaderView *control = [[iCadeReaderView alloc] init];
    //[self.view addSubview:control];
    //control.active = YES;
    control.delegate = self;
    
    self.datasParsered = [NSMutableArray array];
    self.datasParseredLoopNum = [NSMutableArray array];
    
    //用于画图的数据数组，每秒从_dataReceivedFromBLE提取一个
    _dataForPlotTest = [[NSMutableArray alloc] init];
    
    //初始化_dataReceivedFromBLE，此数组中保存接收到得蓝牙数据。每次替换，不是增加。
    _dataReceivedFromBLE = [[NSMutableArray alloc] init];
    _dataReceivedFromBLE = [NSMutableArray arrayWithCapacity:1];
    
    //初始化心率弧度图
    _arcView.degreeEnd = kArcViewStartDegree;
    [_arcView setNeedsDisplay];
    
    [self updateTrainingPlanDate];
    [self speakTrainingPlan]; //为语音提示做准备
}

- (void)viewDidDisappear:(BOOL)animated
{
    //将要推出界面的时候音乐停止
    [_player stop];
    
    //停止语音播报
    [speak invalidate];
}

-(void)connectSerVer
{
    //获取用户输入的登录信息
    NSString * name = [[CurrentAccount sharedCurrentAccount] userName];
    NSString * pwd =  [[CurrentAccount sharedCurrentAccount] userPassword];
    NSLog(@"name = %@ pwd = %@", name, pwd);
    NSString *urlString = [NSString stringWithFormat:@"http://bikeme.duapp.com/Login?type=login&username=%@&password=%@", name, pwd];
    
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

#pragma mark - 保存、读计划训练部分
-(NSString *)datafilePath
{   //返回数据文件的完整路径名。
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:@"trainingPlan.plist"];
}

-(void)updateTrainingPlanDate
{
    NSString * path = [self datafilePath];
    trainingPlanDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSLog(@"1/ 为更新的 trainingPlanDic %@",trainingPlanDic);
    /*
     更新一下trainingPlanDic,
     根据更新的数值判断用户升级范围
     */
    
    
    NSDate * now = [NSDate date];
    int daySub = [self dateSub:now setTime:[trainingPlanDic objectForKey:@"saveTime"]];
    int distanceNextMonday = 0; //差多少天一周
    /*
     计算星期几设置的， 并且计算出距离下一个星期一还需要多长时间
     重新开始计数
     */
    //如果今天是星期一
    switch ([self weekNow:[trainingPlanDic objectForKey:@"saveTime"]]) {
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
    //NSLog(@"distanceOneWeek = %d, daySub = %d", distanceNextMonday, daySub);
    /*
        用户在下个星期的每一天都是可以更新数据的
     */
    if (  daySub > distanceNextMonday -1 && daySub < distanceNextMonday + 7 && daySub != 0 )
    {
        // 如果上周达到目标
        if ([[trainingPlanDic objectForKey:@"remainTimes"] isEqual: @"0"])
        {
            [trainingPlanDic setValue:@"3" forKey:@"remainTimes"];
            
            NSString * weekDone = [trainingPlanDic objectForKey:@"weekDone"];
            weekDone = [NSString stringWithFormat:@"%d",[weekDone intValue] + 1 ];
            
            [trainingPlanDic setValue:weekDone forKey:@"weekDone"];
            [trainingPlanDic setValue:[NSDate date] forKey:@"saveTime"];
            
            //说明用户一周内完成了目标，将weekDone++
            [trainingPlanDic writeToFile:path atomically:YES];
            
            
            //重新下载dic
            NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
            NSLog(@"2.更新 weekdone 后的dic %@",dictionary);
            /*
             只有在开始1等级的时候，周期是2周，其他的都是4周
             */
            if([[dictionary objectForKey:@"weekDone"] intValue] == 2)
            {
                if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"开始1"])
                {
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 开始2"];
                    //升级，重新计数
                    [dictionary setValue:@"开始2" forKey:@"sportLevel"];
                    [dictionary setValue:@"0" forKey:@"weekDone"];
                    [dictionary setValue:[NSDate date] forKey:@"saveTime"];
                    [dictionary setValue:@"3" forKey:@"remainTimes"];
                    [dictionary writeToFile:path atomically:YES];
                    NSLog(@"3. 上传的 开始1 的 weekdone 后的dic %@",dictionary);
                }
            }
            if([[dictionary objectForKey:@"weekDone"] intValue] == 4)
            {
                //开始升级
                if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"开始2"]){
                    [dictionary setValue:@"改善1" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 改善1"];
                }
                else if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"改善1"]){
                    [dictionary setValue:@"改善2" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 改善2"];
                }
                else if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"改善2"]){
                    [dictionary setValue:@"改善3" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 改善3"];
                }
                else if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"改善3"]){
                    [dictionary setValue:@"强化1" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 强化1"];
                }
                else if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"强化1"]){
                    [dictionary setValue:@"强化2" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 强化2"];
                }
                else if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"强化2"]){
                    [dictionary setValue:@"强化3" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 强化3"];
                }
                else if([[dictionary objectForKey:@"sportLevel"] isEqualToString:@"强化3"]){
                    [dictionary setValue:@"维持" forKey:@"sportLevel"];
                    [[Function shareFunction] speak:@"你已完成本阶段任务，现在进入下一个阶段 维持"];
                }
                [dictionary setValue:@"0" forKey:@"weekDone"];
                [dictionary setValue:[NSDate date] forKey:@"saveTime"];
                [dictionary setValue:@"3" forKey:@"remainTimes"];
                [dictionary writeToFile:path atomically:YES];
                NSLog(@"上传的 开始1后 的 weekdone 后的dic %@",dictionary);
            }
        }
    }
}


#pragma mark - 为语音播报做准备,计算靶心率
-(void)speakTrainingPlan
{
    NSString * path = [self datafilePath];
    trainingPlanDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSString * year = [trainingPlanDic objectForKey:@"age"];
    
    // 获取当前的时间
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * now = [dateFormatter stringFromDate:date];
    
    //计算用户靶心率的范围
    int age = [now intValue] - [year intValue];
    int staticHeartNum_min = (220 - age) * 0.6; //((220-age)-staticHeart)*0.6 + staticHeart;
    int staticHeartNum_max = (220 - age) * 0.8; //((220-age)-staticHeart)*0.8 + staticHeart;
    //NSLog(@"age = %d,staticHeart = %d, staticHeartNum_min = %d, staticHeartNum_max = %d",age,staticHeart,staticHeartNum_min, staticHeartNum_max);
    
    int heartDistance = (staticHeartNum_max - staticHeartNum_min)/5;
    
    heart_min = [NSString stringWithFormat:@"%d", staticHeartNum_min];
    heart_two = [NSString stringWithFormat:@"%d", staticHeartNum_min + heartDistance];
    heart_three = [NSString stringWithFormat:@"%d", staticHeartNum_max - heartDistance];
    heart_max = [NSString stringWithFormat:@"%d", staticHeartNum_max];
    
    //设置心率保持的范围
    _heartRange.text = [NSString stringWithFormat:@"%@以下",heart_min];
}

//保存数据
-(void)savePlanData
{
    NSString * path = [self datafilePath];
    trainingPlanDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    int doneTimes = [[trainingPlanDic objectForKey:@"remainTimes"] intValue];
    NSLog(@"~~~~~上传retain前的trainingPlanDic的数据 = %@, doneTimes = %d",trainingPlanDic, doneTimes);
    if (trainingPlanDic) {
        //先短暂测试一下，时间先设为1秒有效
        if ((int)countTime > 1) {
            doneTimes -= 1;
        }
        if(doneTimes < 0)
        {
            doneTimes = 0;
        }
        [trainingPlanDic setValue:[NSString stringWithFormat:@"%d", doneTimes] forKey:@"remainTimes"];
        NSLog(@"***·····上传retain后的trainingPlanDic的数据 = %@",trainingPlanDic);
        [trainingPlanDic writeToFile:path atomically:YES];
    }
}

#pragma mark - UI布局
- (void)UILayoutInit
{
    UIFont * fontTimeTitle = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:45.0f];
    UIFont * fontTimeLable = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:50.0F];
    UIFont * fontThreeTitle = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:30.0f];
    UIFont * fontCal = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:20.0f];
    UIFont * fontStart = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:63.0f];
    UIFont * calLable = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:36];
    //判断不同设备设置字体大小
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        fontStart = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:40.0f];
        calLable = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:20];
    }
    //解决sizeclass的失效问题：新建控件覆盖原有控件，手动添加代码
    self.timeTitle.font = fontTimeTitle;
    self.timeLabel.font = fontTimeLable;
    self.calorieTitle.font = fontThreeTitle;
    self.distanceTitle.font = fontThreeTitle;
    self.speedTitle.font = fontThreeTitle;
    self.calTitle.font =fontCal;
    self.gongliLable.font = fontCal;
    self.gongliHourLable.font = fontCal;
    _stateOfExercise.font = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:18.0f];
    _heartRateLabel.font = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:18.0f];
    [self.startOrEndButton.titleLabel setFont:fontStart];
    [self.calLabel setFont:calLable];
    [self.distanceLabel setFont:calLable];
    [self.speedLabel setFont:calLable];
    
    //iphone端布局
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        //Phone
        //UI过多，隐藏多余的几个Title
        
        [self.heartRateLabel setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:10.0f]];
        
        self.calorieTitle.hidden = YES;
        self.distanceTitle.hidden = YES;
        self.speedTitle.hidden = YES;
        self.timeTitle.hidden = YES;
        [self iphone];
    }
    //解决时间频闪的问题
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _timeLable_two = [[UILabel alloc] initWithFrame:CGRectMake(669, 198, 300, 55)];
        _timeLable_two.font = fontTimeLable;
        [self.view addSubview:_timeLable_two];
        _timeLable_two.text = @"00:00:00.0";
        _timeLabel.hidden = YES;
        
        self.stateOfExercise.hidden = NO;
    }
}
            

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

#pragma mark 导航栏按钮返回runrunfast响应
-(void)returnRunRunFast{
    UIAlertView * aletView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃本次训练数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    aletView.tag = 13;
    [self.view addSubview:aletView];
    
    if (!isStarted) {
        [aletView show];    //用户已经开始，显示提示框
        [timer invalidate]; //定时器暂停
    }else{
        [self.navigationController popViewControllerAnimated:YES]; //如果没有开始，直接返回上一界面
    }
}

- (void)initShareButton{
    if (![WXApi isWXAppInstalled]) {     //如果没有安装微信则分享按钮为隐藏
        self.shareButton.hidden = YES;
    }
}

#pragma mark 设置最大心率
- (void)setHRmax
{
    CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
    //NSLog(@"currenAccount.userHRMax = %@", currenAccount.userHRMax);
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
    NSInteger tapPos = [_chooseTapPos selectedRowInComponent:0];
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
        //button正显示开始，将改为暂停，背景颜色改变。说明将start程序
        //用户起时间长了就提交不了数据了，因为连接时间的请求只能是半个小时
        [NSTimer scheduledTimerWithTimeInterval:1700 target:self selector:@selector(connectSerVer) userInfo:nil repeats:YES];
        
        //
        speak = [NSTimer scheduledTimerWithTimeInterval:390 target:self selector:@selector(encourageSpeak) userInfo:nil repeats:YES];
        
        isStarted = NO;
        [[Function shareFunction] speak:[NSString stringWithFormat:@"前20分钟为热身阶段，请保持心率在%@以下",heart_min]];
        
        [_startOrEndButton setTitle:@"结束" forState:UIControlStateNormal];
        _startOrEndButton.backgroundColor = [UIColor colorWithRed:137.0f/255.0f green:137.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
        
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
        
        //初始化数据显示
        self.distanceLabel.text = @"0.00";
        self.speedLabel.text = @"0.0";
        self.calLabel.text = @"0";
        
        _calLable_.text = @"0";
        _distanceLable_.text = @"0.00";
        _speedLable_.text = @"0.0";
        
    } else { //button显示暂停，将改为开始。说明将pause程序
        isStarted = YES;
        [_startOrEndButton setTitle:@"开始" forState:UIControlStateNormal];
        _startOrEndButton.backgroundColor = [UIColor colorWithRed:1.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
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

//鼓励运动的话，毎6.5分钟调用
-(void)encourageSpeak
{
    srandom(time(0));
    int i = random() % 3;
    if (i == 1) {
        [[Function shareFunction] speak:@"表现不错，请继续加油哦"];
    }
    else  if (i == 2)
    {
        [[Function shareFunction] speak:@"亲很棒哦，请继续坚持"];
    }
    else
    {
        [[Function shareFunction] speak:@"踩得不错，效果很好！"];
    }
}

#pragma mark - 上传数据
- (void)uploadData
{
    //   "http://bikeme.duapp.com/InfoSubmit?mileage=%f&calorie=32&user_time=00:23:11&max_heart_rate=100&min_heart_rate=60&avg_heart_rate=80&user_red_area=0&user_anaerobic_area=10&user_aerobic_area=20&user_fat_burn_area=30&user_simple_area=40&user_other_area=50&ts=2014-04-14
    
    NSString *urlString = [NSString stringWithFormat:@"http://bikeme.duapp.com/InfoSubmit?mileage=%.2f&calorie=%.0f&user_time=%@&max_heart_rate=%.0f&min_heart_rate=60&avg_heart_rate=80&user_red_area=0&user_anaerobic_area=0&user_aerobic_area=0&user_fat_burn_area=0&user_simple_area=0&user_other_area=0&ts=%@",self.distance,self.calSum,self.timeLabel.text,_HRmax,_startTime];
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
        NSLog(@"ret = %d", ret);
        
        if (ret == 1) {
            //取消加载框
            [_tbActivityIndicatorView removeFromSuperview];
            
            [self performSegueWithIdentifier:@"trainingPlanEnd" sender:nil];
            //传递数据到账户单例
            CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
            //分别记录用户到达热身或燃脂等状态的次数
            currenAccount.levelCount0 = self.levelCount0;
            currenAccount.levelCount1 = self.levelCount1;
            currenAccount.levelCount2 = self.levelCount2;
            currenAccount.levelCount3 = self.levelCount3;
            currenAccount.distance = self.distance;
            currenAccount.calSum = self.calSum;
            
            currenAccount.planHeartView = YES; //是从训练计划跳转过来的
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
        
        NSInteger hour = (int)(countTime / 3600);
        NSInteger min = (int)((countTime - hour * 3600)/60);
        CGFloat sec = countTime - hour * 3600 - min * 60;
        NSString *timeForString = [NSString stringWithFormat:@"%02d:%02d:%04.1f", hour,min ,sec];
        
        //每次计算完时间，在主线程上更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            _timeLabel.text = timeForString;
            _timeLable_.text = timeForString;
            _timeLable_two.text = timeForString;
        });
    });
}

#pragma mark- 用户完成本次计划训练，强制弹到心率分布图
-(void)jumpHeartPic
{
    CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    [[Function shareFunction] speak:@"本次训练已结束，请注意适当休息"];
    [self.view addSubview:_tbActivityIndicatorView];
    [self uploadData];
    [self savePlanData];
    //保存用户上一次运动的时间，为了判断用户是否
    currentAccount.lastSportTime = [NSDate date];
}



#pragma mark - 真正开始播放语音提醒
-(void)speakState
{
   // NSLog(@"countTime = %f", countTime);
    //语音播报的时候，按照用户选择的训练功能进行播报
    NSString * fatStr;
    
    //所有的状态都是一样的，用户前20分钟为热身， 之后开始进入燃脂状态
    if ((int)countTime == 1200) {
        //燃脂
        if ([[CurrentAccount sharedCurrentAccount] fatFunc]) {
            fatStr = @"燃脂";
        }
        //有氧
        else if (![[CurrentAccount sharedCurrentAccount] fatFunc])
        {
            fatStr = @"有氧";
        }
        [[Function shareFunction] speak:[NSString stringWithFormat:@"现在进入%@阶段，请保持心率在%@至%@范围内",fatStr, heart_two, heart_three]];
        _trainingSection.text = fatStr;
        _heartRange.text = [NSString stringWithFormat:@"%@~%@",heart_two, heart_three];
    }
    
    /*
        播报用户进行放松状态,
        由于运动级别不同，用户进入放松时的时间不一样，进而进行区分
        exitTimeLimit 设置为了判断用户是否完成本次的训练计划
     
        当用户完成本次训练计划，则自动跳转到心率分布图
     */
    if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"开始1"]) {
        exitTimeLimit = 1800;
        if((int)countTime == 1800)
        {
            [self relaxState];
        }
        else if((int)countTime == 2100)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"开始2"]) {
        exitTimeLimit = 2100;
        if((int)countTime == 2100)
        {
            [self relaxState];
        }
        else if((int)countTime == 2400)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"改善1"]) {
        exitTimeLimit = 2400;
        if((int)countTime == 2400)
        {
            [self relaxState];
        }
        else if((int)countTime == 2700)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"改善2"]) {
        exitTimeLimit = 2700;
        if((int)countTime == 2700)
        {
            [self relaxState];
        }
        else if((int)countTime == 3000)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"改善3"]) {
        exitTimeLimit = 3000;
        if((int)countTime == 3000)
        {
            [self relaxState];
        }
        else if((int)countTime == 3300)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"强化1"]) {
        exitTimeLimit = 3000;
        if((int)countTime == 3000)
        {
           [self relaxState];
        }
        else if((int)countTime == 3300)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"强化2"]) {
        exitTimeLimit = 3300;
        if((int)countTime == 3300)
        {
            [self relaxState];
        }
        else if((int)countTime == 3600)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"强化3"]) {
        exitTimeLimit = 3600;
        if((int)countTime == 3600)
        {
            [self relaxState];
        }
        else if((int)countTime == 3900)
        {
            [self jumpHeartPic];
        }
    }
    else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"维持"]) {
        exitTimeLimit = 3600;
        if((int)countTime == 3600)
        {
            [self relaxState];
        }
        else if((int)countTime == 3900)
        {
            [self jumpHeartPic];
        }
    }
}

-(void)relaxState
{
     [[Function shareFunction] speak:[NSString stringWithFormat:@"现在进入放松阶段，请缓慢骑行5分钟以放松肌肉"]];
    _trainingSection.text = @"放松";
    _heartRange.text = [NSString stringWithFormat:@"%@以下",heart_min];
}

- (void)updateHeartTime{
    if (_timeHeart != 0) {
        _timeHeart -= 1.0;
    }
}

- (void)updateLoopTime{
    
    //在此处判断播报语音种类
    [self speakState];
    
    if (_timeLoop != 0) {
        _timeLoop -= 1.0;
    }
}

#pragma mark - 画图
#pragma mark 设置曲线图系统参数
- (void)setupCoreplotViews
{
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    // Create graph from theme: 设置主题
    //设置完主题，真特么难看啊，别设置此项。简约的气息更适合ios7+
    //目前支持五种主题：kCPTDarkGradientTheme, kCPTPlainBlackTheme, kCPTPlainWhiteTheme, kCPTSlateTheme,kCPTStocksTheme, 最后一种股票主题效果见上面的效果图
    //    CPTTheme * theme = [CPTTheme themeNamed:kCPTSlateTheme];
    //    [_graph applyTheme:theme];
    
    CGRect frame = CGRectMake(kXStartGraph,kYStartGraph, kGraphWidth, kGraphHeight);
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    [self.view addSubview:hostingView];
    hostingView.collapsesLayers = NO;
    hostingView.hostedGraph = _graph;
    
    // Setup plot space: 设置一屏内可显示的x,y量度范围
    _plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    _plotSpace.allowsUserInteraction = NO;
    _plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(kXRangeInView)];
    _plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(30.0) length:CPTDecimalFromFloat(63.0)];
    
    // Axes: 设置x,y轴属性，如原点，量度间隔，标签，刻度，颜色等
    //
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0;
    //线的颜色
    lineStyle.lineColor = [CPTColor redColor];
    
    
    
    // Create a red-blue plot area
    //
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor redColor];
    
    CPTScatterPlot * boundLinePlot  = [[CPTScatterPlot alloc] init];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource    = self;
    
    CPTXYAxis * yAxis = axisSet.yAxis;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"-1"); // 原点的 y 位置
    
    // 每一个数值标记为圆点
    //圆圈的外圈
    //CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    //symbolLineStyle.lineColor = [CPTColor blackColor];
    //symbolLineStyle.lineWidth = 2.0;
    //内圈
    //CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    //plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    //plotSymbol.lineStyle     = symbolLineStyle;
    //plotSymbol.size          = CGSizeMake(10.0, 10.0);
    //boundLinePlot.plotSymbol = plotSymbol;
    
    [_graph addPlot:boundLinePlot];
    
    
    CPTScatterPlot * dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    //dataSourceLinePlot.identifier = GREEN_PLOT_IDENTIFIER;
    dataSourceLinePlot.dataSource = self;
    
    dataSourceLinePlot.areaBaseValue= CPTDecimalFromString(@"1.75");
    
    // Animate in the new plot: 淡入动画
    dataSourceLinePlot.opacity = 5.0f;
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
    [_graph addPlot:dataSourceLinePlot];
    
    //update Data
    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
}

#pragma mark 获取画图数据并画图
- (void)getTrainingDataForPlot {
    [_graph reloadData];
    
    //    dispatch_async(_globalQueue, ^{
    
    if (_timeHeart == 0) {
        //没有心率输入
        _heartRateString = [NSString stringWithFormat:@"%d", 0];
        self.currentHeartRate = _heartRateString;
        self.heartRateLabel.text = self.currentHeartRate;
        _stateOfExercise.text = @"";
        [self drawArcWithHeartRatePercent:0];
    }else{
        //认为有心率输入
        if (self.datasParsered.count < kBLEDataToHeartRateThread ) {
            _heartRateString = [NSString stringWithFormat:@"%d", 75];
            self.currentHeartRate = _heartRateString;
            NSInteger yPercentInt = 100 * (int)_heartRateFloat / _HRmax ;
            [self drawArcWithHeartRatePercent:yPercentInt];
        }
        
        if (self.datasParsered.count >= kBLEDataToHeartRateThread) {//当数据足够计算心率时候，进行计算
            
            NSDate *dateBack =[[self.datasParsered objectAtIndex:kBLEDataToHeartRateThread - 1] dateForReceive];
            NSDate *datePre = [[self.datasParsered objectAtIndex:0] dateForReceive];
            NSTimeInterval timeInterval = [dateBack timeIntervalSinceDate:datePre];
            _heartRateFloat = 60.0f * (float)( kBLEDataToHeartRateThread - 1) / timeInterval;
            
            //初始化  历史心率值
            if (_heartRatePreFloat == 0.0) {
                _heartRatePreFloat = _heartRateFloat;
            }
            
            //心率数据相关
            if (_heartRateFloat - _heartRatePreFloat > 5.0) {
                _heartRateFloat = _heartRatePreFloat + 5.0;
            }else if(_heartRateFloat - _heartRatePreFloat < -5.0){
                _heartRateFloat = _heartRatePreFloat -5.0;
            }
            _heartRatePreFloat = _heartRateFloat;
            
            _heartRateString = [NSString stringWithFormat:@"%d", (int)_heartRateFloat];
            self.currentHeartRate = _heartRateString;
            self.heartRateLabel.text = self.currentHeartRate;
            
            xIndex++;
            id x = [NSNumber numberWithInt:xIndex];
            
            NSInteger yPercentInt = 100 * (int)_heartRateFloat / _HRmax ;
            //NSLog(@"yPercentInt -- > %D", yPercentInt);
            [self drawArcWithHeartRatePercent:yPercentInt];
            
            if (_dataForPlotTest.count != 0) {
                NSNumber * num = [[_dataForPlotTest lastObject] valueForKey:@"y"];
                NSInteger yPre = [num integerValue];
                
                if (abs((int)(yPre - yPercentInt)) > kThreadFilter) {
                    //画上一个
                    yPercentInt = _yPercentLastInt;
                }
            }
            _yPercentLastInt = yPercentInt;
            id yNumber = [NSNumber numberWithInteger:yPercentInt ];
            [_dataForPlotTest addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", yNumber, @"y", nil]];
            
            
            //考虑UI只有四个颜色，暂时去掉了乳酸区
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //1.更新当前锻炼状态
                if (yPercentInt < 60) {
                    _stateOfExercise.text = @"热身";
                    _stateOfExercise.textColor = [UIColor greenColor];
                    
                    _levelCount0++;
                }else if (yPercentInt < 70 ) {
                    _stateOfExercise.text = @"燃脂";
                    _stateOfExercise.textColor = [UIColor magentaColor];
                    _levelCount1++;
                }else if (yPercentInt < 80 ) {
                    _stateOfExercise.text = @"提升";
                    _stateOfExercise.textColor = [UIColor darkGrayColor];
                    
                    _levelCount2++;
                    //}else if (yPercentInt < 90 ){
                    // _stateOfExercise.text = @"乳酸";
                    // _stateOfExercise.textColor = [UIColor blueColor];
                }else{
                    _stateOfExercise.text = @"极限";
                    _stateOfExercise.textColor = [UIColor redColor];
                    [[Function shareFunction] speak:@"您已进入“无氧”状态，专家表示，有氧运动更有益于健康"];
                    _levelCount3++;
                }
                
                //当数据充满一个view的x轴后，开始移动曲线
                if (xIndex >= kXRangeInView) {
                    [self changePlotRange];
                }
                //[self setupCoreplotViews];
            });
        }
    }
}

#pragma mark 获取画图数据并更新UI，距离、速度、卡路里计算
- (void)getTrainingDataForUI
{
    float distance,speed;
    
    //距离
    if (self.datasParseredLoopNum.count > 0) {
        distance = [[[self.datasParseredLoopNum lastObject] loopNum] floatValue] * kDistanceEachLoop / 1000;
        self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f", distance];
        self.distance = distance;
        _distanceLable_.text = _distanceLabel.text;
    }
    else
    {
        distance = 0;
    }
    
    if (_timeLoop == 0) {
        //认为用户没有骑行
        speed = 0.0;
        self.speedLabel.text = @"0.0";
        _speedLable_.text = @"0.0";
        self.calLabel.text = [NSString stringWithFormat:@"%.0f", _calSum];
        _calLable_.text = _calLabel.text;
    }else{
        //用户骑行中
        //速度
        if (self.datasParseredLoopNum.count >= kICadeDataToSpeedThread) {
            //NSLog(@"count --> %lu",(unsigned long)self.datasParseredLoopNum.count);
            NSDate *dateBack =[[self.datasParseredLoopNum objectAtIndex:kICadeDataToSpeedThread - 1] dateForReceive];
            NSDate *datePre = [[self.datasParseredLoopNum objectAtIndex:0] dateForReceive];
            NSTimeInterval timeInterval = [dateBack timeIntervalSinceDate:datePre];
            speed = 3.6 * 3 * (float) kICadeDataToSpeedThread / timeInterval; //距离除以时间
            self.speedLabel.text = [NSString stringWithFormat:@"%.1f", speed];
            _speedLable_.text = _speedLabel.text;
            _calSum += [self getCal:_speedLabel.text];
            
            self.calLabel.text = [NSString stringWithFormat:@"%.0f", _calSum];
            _calLable_.text = _calLabel.text;
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
}

#pragma mark 播放器--暂停/开始
- (IBAction)pauseOrStart:(id)sender {
    if (_player.playing) {
        [_player pause];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"play2@2x.png"] forState:UIControlStateNormal];
        _beforeBtn.enabled = NO;
        _nextBtn.enabled = NO;
    }
    else
    {
        [_player play];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"play-1@2x.png"] forState:UIControlStateNormal];
        _beforeBtn.enabled = YES;
        _nextBtn.enabled = YES;
    }
}

//前后一首播放歌曲
- (IBAction)skipToPrevious:(id)sender {
    if (_object != 0) {
        _object--;
        [self loadMusic:[_musicItem objectAtIndex:_object]];
        [_player play];
    }
}

- (IBAction)skipToNext:(id)sender {
    if (_object != 2) {
        _object++;
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
            
            //构造模型，保存心跳总数和时间
            DataFromICade *dataFromICade = [DataFromICade initWithCurrentDateWithHeartBeatCount:self.heartBeatCount];
            
            //存入数组
            [self.datasParsered addObject:dataFromICade];
            
            //模型数量限制：总共有kBLEDataToHeartRateThread个数据（8）
            if (self.datasParsered.count > kBLEDataToHeartRateThread) {
                [self.datasParsered removeObjectAtIndex:0];
            }
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
            
            //模型数量限制：总共有kICadeDataToSpeedThread个数据（3）
            if (self.datasParseredLoopNum.count > kICadeDataToSpeedThread) {
                [self.datasParseredLoopNum removeObjectAtIndex:0];
            }
        }
    });
}

#pragma mark - TB加载框初始化
- (void)inittBActivityIndicatorView
{
    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"努力同步中"];
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
    //导航栏提醒框
    if (alertView.tag == 13) {
        switch (buttonIndex) {
            case 0:
                [self.navigationController popViewControllerAnimated:YES];
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
                //保存用户上一次运动的时间，为了判断用户是否该降级
                CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
                currentAccount.lastSportTime = [NSDate date];
                
                //如果不是游客，则上传运动数据到服务器
                if (!currentAccount.guestAccount) {
                    /*
                        方便测试，发布改回来
                     */
                    [self uploadData];
                    [self savePlanData];
                    
//                    // 用户在放松状态的时候才可以跳转到心率分布图， 发布版本使用
//                    if (countTime > exitTimeLimit) {
//                        //弹出加载框
//                        [self.view addSubview:_tbActivityIndicatorView];
//                        [self uploadData];
//                        [self savePlanData];
//                    }
//                    else
//                    {
//                        //如果用户没有完成本次训练计划，不退到显示心率的地方
//                        [self performSegueWithIdentifier:@"returnChooseTrain" sender:nil];
//                    }
                }
            }
                break;
            case 1:
            {
                //点击了取消
                isStarted = NO;
                [
                 _startOrEndButton setTitle:@"结束" forState:UIControlStateNormal];
                _startOrEndButton.backgroundColor = [UIColor colorWithRed:137.0f/255.0f green:137.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
                
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

#pragma mark 画心率进度弧线
- (void)drawArcWithHeartRatePercent:(NSInteger)heartRatePercent
{
    NSInteger degreeEnd;
    _arcView.center = self.progressBackground.center;
    //起始点为-225度，最大末尾点为45度。全程270度，将心率百分比映射到心率进度弧，得到心率弧末尾点。
    degreeEnd = kArcViewStartDegree + (kArcViewEndMaxDegree - kArcViewStartDegree) * heartRatePercent / 100;
    _arcView.degreeEnd = degreeEnd;
    [_arcView setNeedsDisplay];
}

#pragma mark 画图--询问多少个数据
//询问有多少个数据，在 CPTPlotDataSource 中声明的
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [_dataForPlotTest count];
}

#pragma mark 画图--画具体的每一个数据
//询问一个个数据值，在 CPTPlotDataSource 中声明的
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString * key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber * num = [[_dataForPlotTest objectAtIndex:index] valueForKey:key];
    return num;
}

#pragma mark 移动曲线图
-(void)changePlotRange
{
    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.xRange = [self CPTPlotRangeFromFloat:xIndex-9.0 length:kXRangeInView ];
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(xIndex-8);
}

-(CPTPlotRange *)CPTPlotRangeFromFloat:(float)location length:(float)length
{
    return [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(location) length:CPTDecimalFromFloat(length)];
}

#pragma mark - iPhone布局
-(void)iphone
{    // 自动布局失效，用笨方法解决的
    _timeLabel.hidden = YES;
    _calTitle.hidden = YES;
    _gongliLable.hidden = YES;
    _gongliHourLable.hidden = YES;
    _calLabel.hidden = YES;
    _distanceLabel.hidden = YES;
    _speedLabel.hidden = YES;
    
    _timeLable_ = [[UILabel alloc] init];
    _calTitle_ = [[UILabel alloc] init];
    _distanceTitle_ = [[UILabel alloc] init];
    _speedTitle_ = [[UILabel alloc] init];
    _calLable_ = [[UILabel alloc] init];
    _distanceLable_ = [[UILabel alloc] init];
    _speedLable_ = [[UILabel alloc] init];
    
//    [[iphoneLayout shareIphoneLayout] Time:_timeLable_ timeT:_timeLabel calT:_calTitle_ distanceT:_distanceTitle_ speedT:_speedTitle_ cal:_calLable_ distance:_distanceLable_ speed:_speedLable_ view:self.view];
}


#pragma mark - 音乐播放按钮,档位
-(void)createMusicBtn
{
    _playList  = [UIButton buttonWithType:UIButtonTypeCustom];
    _beforeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn addTarget:self action:@selector(pauseOrStart:) forControlEvents:UIControlEventTouchUpInside];
    [_beforeBtn addTarget:self action:@selector(skipToPrevious:) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn addTarget:self action:@selector(skipToNext:) forControlEvents:UIControlEventTouchUpInside];
    
    [[iphoneLayout shareIphoneLayout] craeteMusicPlay:_playBtn before:_beforeBtn next:_nextBtn viewHeight:self.view.frame.size.height view:self.view];
    [self jumpSysMusic]; //加载系统音乐
    
    //档位阻力
    UIImageView * tapImage = [[UIImageView alloc] initWithFrame:CGRectMake(650, 280, 339, 51)];
    tapImage.image = [UIImage imageNamed:@"档位.png"];
    [self.view addSubview:tapImage];
    _chooseTapPos = [[UIPickerView alloc] initWithFrame:CGRectMake(866, 226, 30, 10)];
    [[iphoneLayout shareIphoneLayout] tapPos:tapImage chooseTapPos:_chooseTapPos];
    [self pickViewSetting:_chooseTapPos tag:11]; //设置属性
}

#pragma mark pickView个性设置
//只有一组选择数据
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//本组有多少个数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_pickViewData count];
}
//设置每个选项的内容
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_pickViewData objectAtIndex:row];
}
//设置每行的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;{
    return 60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 20;
}

//设置每行的字体大小
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 26, 39)];
    lable.textColor = [UIColor colorWithRed:255/255 green:114/255 blue:0 alpha:0.6];
    lable.font = [UIFont fontWithName:@"FZLanTingHei-M-GBK" size:28.0f];
    lable.text = [_pickViewData objectAtIndex:row];
    return lable;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
