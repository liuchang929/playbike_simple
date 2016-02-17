//
//  HeartRateAnalysisViewController.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-27.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "HeartRateAnalysisViewController.h"
#import "CurrentAccount.h"
#import <AFNetworking.h>
#import "MobClick.h"

@interface HeartRateAnalysisViewController ()<UIActionSheetDelegate>
{
    //截图
    UIImage *_currentImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *backImg;
@property (weak, nonatomic) IBOutlet UIImageView *sexImg;
@property (weak, nonatomic) IBOutlet UIButton *clockInBtn;
@property (weak, nonatomic) IBOutlet UIView *clockView;
@property (weak, nonatomic) IBOutlet UILabel *sportDay;

@end

@implementation HeartRateAnalysisViewController

#pragma mark - 初始化方法
#pragma mark 初始化并显示里程
- (void)initDistance
{
    UIFont * textFont = [UIFont fontWithName:@"FZLTTHK--GBK1-0" size:36];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        textFont = [UIFont fontWithName:@"FZLTTHK--GBK1-0" size:20];
    }
    self.TextLable.font = textFont;
    self.hotDog.font = textFont;
    
    CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    
    //不是从训练计划界面跳过来的
    if( !currentAccount.planHeartView)
    {
        
        self.TextLable.text = [NSString stringWithFormat:@"本次运动里程  %.2f  公里", currentAccount.distance];

        if (currentAccount.calSum != 0) {
            self.hotDog.text = [NSString stringWithFormat:@"相当于消耗  %d  根红肠", (int)currentAccount.calSum/150];
        }
        else
        {
            self.hotDog.text = [NSString stringWithFormat:@"相当于消耗  0  根红肠"];
        }
    }
    
    //是从训练计划跳过来的
    else
    {
        srandom(time(0));
        int i = random() % 2;
        
        //燃脂
        if (currentAccount.fatFunc) {
            if (i == 1) {
                self.TextLable.text = @"您今天又给自己甩掉了不少肉肉，明天要继续坚持哦~";
            }
            else
            {
                self.TextLable.text = @"肉肉天天甩，美男天天来！";
            }
        }
        
        //有氧
        else
        {
            if (i == 1) {
                self.TextLable.text = @"今天的锻炼让您每次呼吸所吸收的氧气更多啦~";
            }
            else
            {
                self.TextLable.text = @"继续锻炼，您的心肺可能会强大到可以放下一个宇宙。";
            }
        }
        NSString * path = [self datafilePath];
        NSMutableDictionary * trainingPlanDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        int remainTime = [[trainingPlanDic objectForKey:@"remainTimes"] intValue];
        self.hotDog.text = [NSString stringWithFormat:@"本周还有 %d 次任务没有完成",remainTime];
    }
}

-(NSString *)datafilePath
{   //返回数据文件的完整路径名。
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:@"trainingPlan.plist"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"打卡页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"打卡页面"];
}

//把头像变成圆
- (void)viewWillLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];

    _headImage.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = _headImage.frame.size.width/2;

    
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
//                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back:)];
    
    [self initShareButton];
    [self getSportsDay];
    
    CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];
    
    //微信用户
    if ([currentAccount.isWeChat intValue]) {

        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:currentAccount.headimgurl]];
        _headImage.image = [UIImage imageWithData:data];
    }
    else
    {
        NSInteger headID = [currentAccount.userHeadID integerValue];
        NSString *headName = [NSString stringWithFormat:@"head%02ld.png", (long)headID];
        _headImage.image = [UIImage imageNamed:headName];
    }
    _nikeName.text = currentAccount.userNickName;
    _cal.text = [NSString stringWithFormat:@"%d",(int)currentAccount.calSum];
    _distance.text = [NSString stringWithFormat:@"%.2f",currentAccount.distance];
    _sportTime.text = currentAccount.sportTime;
    
    NSDate * now = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy.MM.dd   HH:mm"];
    NSString * nowStr = [formatter stringFromDate:now];
    _nowTime.text = nowStr;
    
    //获取用户的性别
    NSString * sex = currentAccount.userSex;
    NSLog(@"sex = %@",sex);
    //男女
    if ([sex isEqualToString:@"male"]) {
        _sexImg.image = [UIImage imageNamed:@"男.png"];
        _backImg.image = [UIImage imageNamed:@"背景男"];
    }
    else
    {
        _sexImg.image = [UIImage imageNamed:@"女.png"];
        _backImg.image = [UIImage imageNamed:@"女背景"];
    }
}

-(void)getSportsDay
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/signinServlet?type=getdata&username=%@",[[CurrentAccount sharedCurrentAccount] serverName],[[CurrentAccount sharedCurrentAccount] userName]];
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url= [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dictionary = responseObject;
        NSLog(@"--===-%@",dictionary);
        //解析数据
        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];
        
        if (ret == 1) {
            if ([[dictionary objectForKey:@"content"] count] != 0)
            {
                NSArray * array = [dictionary objectForKey:@"content"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",[[array objectAtIndex:0] objectForKey:@"register"]);
                    _sportDay.text = [NSString  stringWithFormat:@"%@",[[array objectAtIndex:0] objectForKey:@"register"]];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _sportDay.text = @"0";
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _sportDay.text = @"0";
            });
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败了 %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];

}
#pragma mark - 打卡
- (IBAction)clockIn:(id)sender {
    
    [_clockInBtn setImage:[UIImage imageNamed:@"已打卡.png"] forState:UIControlStateNormal];
    
    NSDate * date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * dateStr = [formatter stringFromDate:date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/signinServlet?type=signin&username=%@&date=%@", [[CurrentAccount sharedCurrentAccount] serverName],[[CurrentAccount sharedCurrentAccount] userName],dateStr];
    
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
             NSLog(@"打卡成功");
            [self getSportsDay];
            _clockView.hidden = NO;
        }else{
            //账号登陆失败，帮用户进行注册、登陆
            NSLog(@"打卡失败");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"打卡失败Error: %@",error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    
}

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"反馈返回" sender:nil];
}

#pragma mark - 截图分享

- (void)initShareButton
{
    if (![WXApi isWXAppInstalled]) {
        self.shareButton.hidden = YES;
    }
}

#pragma mark 截图
- (UIImage *)captureScreen
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void) sendImageContentWithImage:(UIImage *)image InScene:(int)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"152.png"]];
    
    WXImageObject *ext = [WXImageObject object];
    /*
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res5thumb" ofType:@"png"];
     NSLog(@"filepath :%@",filePath);
     ext.imageData = [NSData dataWithContentsOfFile:filePath];
     */
    
    //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    //UIImage* image = [UIImage imageWithData:ext.imageData];
    
    
    
    ext.imageData = UIImagePNGRepresentation(image);
    
    //    UIImage* image = [UIImage imageNamed:@"res5thumb.png"];
    //    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    //message.title = @"title";
    //message.description = @"description";
    
    
    [WXApi sendReq:req];
}


#pragma mark - UIActionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //分享至 微信
            [MobClick event:@"share_wechat"];
            [self sendImageContentWithImage:_currentImage InScene:0];
            break;
            
        case 1:
            //分享至 朋友圈
            [MobClick event:@"share_moments"];
            [self sendImageContentWithImage:_currentImage InScene:1];
            break;
            
        default:
            break;
    }
}

- (IBAction)share:(id)sender {
    
    [MobClick event:@"share_icon"];
    
    //截图,并保存至当前图片  _currentImage
    _currentImage = [self captureScreen];
    
    //保存至设备相册
    UIImageWriteToSavedPhotosAlbum(_currentImage, self,nil, nil);
    
    
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"分享至" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"朋友圈", nil];
    shareSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [shareSheet showInView:self.view];
    

}
@end
