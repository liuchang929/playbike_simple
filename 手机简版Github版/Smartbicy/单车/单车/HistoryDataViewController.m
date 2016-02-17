//
//  HistoryDataViewController.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-25.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "HistoryDataViewController.h"
#import <AFNetworking.h>
#import "TBActivityIndicatorView.h"
#import "CurrentAccount.h"
#import "MobClick.h"

//画图
#define kXRangeInViewPad   10.0
#define kXRangeInViewPhone   5.0

@interface HistoryDataViewController ()
@end

@implementation HistoryDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{
//                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
//                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
//    //初始化TB菊花框
//    [self inittBActivityIndicatorView];
//    //添加加载提示框
//    [self.view addSubview:_tbActivityIndicatorView];
//
//    //下载历史数据
//    [self downloadHistoryData];
//
    [self connectSerVer];
    NSLog(@"%@,%@", [[CurrentAccount sharedCurrentAccount] userName],[[CurrentAccount sharedCurrentAccount] userPassword]);
    NSString * urlString = [NSString stringWithFormat:@"http://bikeme.duapp.com/test/jquerymobile.html?username=%@&password=%@", [[CurrentAccount sharedCurrentAccount] userName],[[CurrentAccount sharedCurrentAccount] userPassword]];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:urlRequest];
    
    
    /*
    float viewWidth = self.view.frame.size.width;
    float viewHeight = self.view.frame.size.height;
//    NSLog(@"%f,%f,%f,%f",self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width,self.view.bounds.size.height);
//    NSLog(@"%f,%f,%f,%f",_webView.bounds.origin.x,_webView.bounds.origin.y,_webView.bounds.size.width,_webView.bounds.size.height);
//    NSLog(@"%f,%f,%f,%f",_webView.frame.origin.x,_webView.frame.origin.y,_webView.frame.size.width,_webView.frame.size.height);
    //旋转屏幕，但是只旋转当前的View
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    self.view.bounds = CGRectMake(-30, 64, frame.size.height, viewWidth);
//    _webView.bounds = CGRectMake(_webView.bounds.origin.x,64,viewWidth,viewHeight);
//    _webView.frame = CGRectMake(0, 64, frame.size.height, viewWidth);
//    NSLog(@"%f,%f,%f,%f",self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width,self.view.bounds.size.height);
//    NSLog(@"%f,%f,%f,%f",_webView.bounds.origin.x,_webView.bounds.origin.y,_webView.bounds.size.width,_webView.bounds.size.height);
//     NSLog(@"%f,%f,%f,%f",_webView.frame.origin.x,_webView.frame.origin.y,_webView.frame.size.width,_webView.frame.size.height);
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"历史数据页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"历史数据页面"];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Routines
//
//#pragma mark - TB加载框初始化
//- (void)inittBActivityIndicatorView
//{
//    _tbActivityIndicatorView = [TBActivityIndicatorView activityIndicatorView];
//}
//
//#pragma mark -后端提取数据
//- (void)downloadHistoryData
//{
//    //NSLog(@"download");
//    _historyDataArray = [[NSMutableArray alloc] init];
//    
//    NSString *urlString = @"http://bikeme.duapp.com/InfoCheckOut";
//    //有中文，需要转换
//    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
//    
//    //连接、解析
//    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    op.responseSerializer = [AFJSONResponseSerializer serializer];
//    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //NSLog(@"JSON: %@", responseObject);
//
//        //        http://bikeme.duapp.com/InfoCheckOut
//        //        查询成功 {“ret”:1 } json串数据。
//        //        查询失败 {“ret”: -1}
//        
//        
//        NSDictionary *dictionary = responseObject;
//        //解析数据
//        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];
//        
//        if (ret == 1) {
//            NSArray *content = [dictionary objectForKey:@"content"];
//            
//            NSInteger dataCount = [content count];
//            for (NSInteger i =0; i < dataCount; i++) {
//                //提取JSON中所需数据
//                NSDictionary *dataDictionary = content[i];
//                NSDictionary *dateDictionary = [dataDictionary objectForKey:@"ts"];
//                
//                HistoryData *historyData = [HistoryData
//                                           dataWithDistance:[dataDictionary objectForKey:@"mileage"]
//                                           WithYear:[NSString stringWithFormat:@"%ld",[[dateDictionary objectForKey:@"year"] integerValue] + 1900]
//                                           WithMonth:[NSString stringWithFormat:@"%ld",[[dateDictionary objectForKey:@"month"] integerValue] + 1]
//                                           WithDay:[dateDictionary objectForKey:@"date"]
//                                           WithHour:[dateDictionary objectForKey:@"hours"]
//                                           WithMinute:[dateDictionary objectForKey:@"minutes"]
//                                            WithSecond:[dateDictionary objectForKey:@"seconds"]];
//                
//                [_historyDataArray addObject:historyData];
//                //NSLog(@"distance -- > %@",historyData.distance);
//                //NSLog(@"data-->%@", dataDictionary);
//
//            }
//            //NSLog(@"didDownload _historyDataCount --> %d", [_historyDataArray count]);
//            //加载历史数据
//            [self loadHistoryData];
//            //移除加载提示框
//            [_tbActivityIndicatorView removeFromSuperview];
//            //初始化画图参数并显示（绘制时调用数据源）
//            [self setupCoreplotViews];
//
//        }
//        else{
//            [_tbActivityIndicatorView removeFromSuperview];
//            [self showAlertWithString:@"网络异常"];
//        }
//        
//        }
//        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //NSLog(@"Error: %@",error);
//            [_tbActivityIndicatorView removeFromSuperview];
//        //[self showAlertWithString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
//        [self showAlertWithString:@"网络异常"];
//        
//        
//    }];
//    [[NSOperationQueue mainQueue] addOperation:op];
//}
//
//#pragma mark - 画图
//#pragma mark -载入画图数据
//- (void)loadHistoryData
//{
//    _dataForPlot = [[NSMutableArray alloc] init];
//    
//    for (NSInteger i = [_historyDataArray count] - 1; i >= 0; i--) {
//        HistoryData *historyData = (HistoryData *)_historyDataArray[i];
//        //NSLog(@"distance --> %@",historyData.distance);
//        id yIndex = [NSNumber numberWithFloat:[historyData.distance floatValue]];
//        id xIndex = [NSNumber numberWithInteger:[_historyDataArray count] - i];//+1:在横坐标0处不现实数据，从横坐标的1开始显示
//        //id xIndex = @"2014-11-11";
//        [_dataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:xIndex, @"x", yIndex, @"y", nil]];
//
//    }
//}
//#pragma mark -设置曲线图系统参数
//- (void)setupCoreplotViews
//{
//    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
//    
//    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
//    // Create graph from theme: 设置主题
//    //设置完主题，真特么难看啊，别设置此项。简约的气息更适合ios7+
//    //目前支持五种主题：kCPTDarkGradientTheme, kCPTPlainBlackTheme, kCPTPlainWhiteTheme, kCPTSlateTheme,kCPTStocksTheme, 最后一种股票主题效果见上面的效果图
//    //    CPTTheme * theme = [CPTTheme themeNamed:kCPTSlateTheme];
//    //    [_graph applyTheme:theme];
//    
//    float xStart = [UIScreen mainScreen].bounds.size.width * 0.05f;
//    float yStart = [UIScreen mainScreen].bounds.size.height * 0.1f;
//    float width = [UIScreen mainScreen].bounds.size.width * 0.9f;
//    float height = [UIScreen mainScreen].bounds.size.height * 0.8f;
//    CGRect frame = CGRectMake(xStart,yStart, width, height);
//    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:frame];
//    
//    //CPTGraphHostingView * hostingView = (CPTGraphHostingView *)self.view;
//    // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
//    [self.view addSubview:hostingView];
//    hostingView.collapsesLayers = YES;
//    //[hostingView setHostedGraph:_graph];
//    hostingView.hostedGraph = _graph;
//    
////    _graph.paddingLeft = _graph.paddingRight = 10.0;
////    _graph.paddingTop = _graph.paddingBottom = 15.0;
//    
//    // Setup plot space: 设置一屏内可显示的x,y量度范围
//    _plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
//    _plotSpace.allowsUserInteraction = YES;
//    
//    //根据不同设备设定X、Y轴上显示数据的数据范围
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        //Phone
//        _plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(kXRangeInViewPhone)];
//        _plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-15) length:CPTDecimalFromFloat(100)];
//    }else{
//        //Pad
//        _plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(kXRangeInViewPad)];
//        _plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-5) length:CPTDecimalFromFloat(100)];
//    }
//    
//    //设置x、y轴的滚动范围，如果不设置，默认是无线长的
//    NSInteger xMaxRange = MAX([_historyDataArray count], 10);
//    _plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(xMaxRange)];
//    
//    //根据不同设备设定X、Y轴上显示数据的数据范围
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        //Phone
//        _plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-15) length:CPTDecimalFromFloat(1000)];
//    }else{
//        _plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-5) length:CPTDecimalFromFloat(1000)];
//    }
//    
//    // Axes: 设置x,y轴属性，如原点，量度间隔，标签，刻度，颜色等
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
//    
//    lineStyle.miterLimit = 1.0f;
//    lineStyle.lineWidth = 0.5f;
//    //线的颜色
//    lineStyle.lineColor = [CPTColor orangeColor];
//    
//    
//    
//    CPTXYAxis * x = axisSet.xAxis;
//    // 设置X轴label
//    x.labelingPolicy = CPTAxisLabelingPolicyNone;
//    NSMutableArray *labelArray=[NSMutableArray arrayWithCapacity:[_historyDataArray count]];
//    //for (NSInteger i = [_historyDataArray count] -1; i >= 0 ;i--)
//    for (NSInteger i = 0; i < [_historyDataArray count];i++)
//    {
//        HistoryData *historyData = (HistoryData *)_historyDataArray[i];
//        CPTAxisLabel *newLabel ;
//        NSString *label = [NSString stringWithFormat:@"%@.%@.%@-%@",historyData.year,historyData.month,historyData.day,historyData.hour];
//        newLabel = [[CPTAxisLabel alloc] initWithText:label textStyle:x.labelTextStyle];
//        
//        newLabel.tickLocation=[[NSNumber numberWithInt:[_historyDataArray count] - i] decimalValue];
//        newLabel.offset=x.labelOffset+x.majorTickLength;
//        [labelArray addObject:newLabel];
//        
//
//    }
//    x.title = @"时间";
//    //x.majorTickLocations = [NSSet setWithArray:labelArray];
//    x.axisLabels=[NSSet setWithArray:labelArray];
//    
//    //根据不同设备设定X轴位置
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        //Phone
//        x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); // 原点的 x 位置
//        x.majorIntervalLength = CPTDecimalFromString(@"1");   // x轴主刻度：显示数字标签的量度间隔
//        //x.minorTicksPerInterval = 2;    // x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
//        x.minorTickLineStyle = lineStyle;
//        x.majorGridLineStyle = lineStyle;//这里设置x轴中主刻度的栅格，平行于y轴
//        //固定y轴，也就是在你水平移动时，y轴是固定在左/右边不动的，以此类推x轴
//        //x.axisConstraints = [CPTConstraints constraintWithLowerOffset:30];//这里是固定x坐标轴在最下边（距离可视下边界有30个像素距离，一边显示标签）
//    }else{
//        //Pad
//        x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); // 原点的 x 位置
//        x.majorIntervalLength = CPTDecimalFromString(@"1");   // x轴主刻度：显示数字标签的量度间隔
//        //x.minorTicksPerInterval = 2;    // x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
//        x.minorTickLineStyle = lineStyle;
//        x.majorGridLineStyle = lineStyle;//这里设置x轴中主刻度的栅格，平行于y轴
//        //固定y轴，也就是在你水平移动时，y轴是固定在左/右边不动的，以此类推x轴
//        x.axisConstraints = [CPTConstraints constraintWithLowerOffset:30];//这里是固定x坐标轴在最右边（距离可视右边界有30个像素距离，一边显示标签）
//    }
//
//    CPTXYAxis * y = axisSet.yAxis;
//    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); // 原点的 y 位置
//    y.majorIntervalLength = CPTDecimalFromString(@"50");   // y轴主刻度：显示数字标签的量度间隔
//    y.minorTicksPerInterval = 2;    // y轴细分刻度：每一个主刻度范围内显示细分刻度的个数
//    y.minorTickLineStyle = lineStyle;
//    y.majorGridLineStyle = lineStyle;//这里设置y轴中主刻度的栅格，平行于x轴
//    
//    //固定y轴，也就是在你水平移动时，y轴是固定在左/右边不动的，以此类推x轴
//    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:44];//这里是固定y坐标轴在最右边（距离可视右边界有40个像素距离，一边显示标签）
//    
//    // Create a red-blue plot area
//    //
//    lineStyle.miterLimit        = 1.0f;
//    lineStyle.lineWidth         = 3.0f;
//    lineStyle.lineColor         = [CPTColor redColor];
//    
//    CPTScatterPlot * boundLinePlot  = [[CPTScatterPlot alloc] init];
//    boundLinePlot.dataLineStyle = lineStyle;
//    boundLinePlot.dataSource    = self;
//    
//    
////     每一个数值标记为圆点
////    圆圈的外圈
//    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
//    symbolLineStyle.lineColor = [CPTColor blackColor];
//    symbolLineStyle.lineWidth = 2.0;
////    内圈
//    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
//    plotSymbol.lineStyle     = symbolLineStyle;
//    plotSymbol.size          = CGSizeMake(10.0, 10.0);
//    boundLinePlot.plotSymbol = plotSymbol;
//    
//    [_graph addPlot:boundLinePlot];
//    
//    
//    CPTScatterPlot * dataSourceLinePlot = [[CPTScatterPlot alloc] init];
//    dataSourceLinePlot.dataLineStyle = lineStyle;
//    //dataSourceLinePlot.identifier = GREEN_PLOT_IDENTIFIER;
//    dataSourceLinePlot.dataSource = self;
//    
//    dataSourceLinePlot.areaBaseValue= CPTDecimalFromString(@"1.75");
//    
//    // Animate in the new plot: 淡入动画
//    dataSourceLinePlot.opacity = 5.0f;
//    
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration            = 3.0f;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode            = kCAFillModeForwards;
//    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
//    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
//    
//    [_graph addPlot:dataSourceLinePlot];
//    
//}
//
//
//#pragma mark -询问多少个数据
////询问有多少个数据，在 CPTPlotDataSource 中声明的
//-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
//{
//    return [_dataForPlot count];
//}
//
//#pragma mark -画具体的每一个数据
////询问一个个数据值，在 CPTPlotDataSource 中声明的
//-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
//{
//    
//    NSString * key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
//    NSNumber * num = [[_dataForPlot objectAtIndex:index] valueForKey:key];
//    //NSLog(@"每一个数据-->%@",num);
//    return num;
//}
//
//
//#pragma mark - 文字提示框
//- (void)showAlertWithString:(NSString *)string
//{
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alertView show];
//}
//
#pragma mark - ACTION
- (IBAction)back:(UIButton *)sender {
    [self performSegueWithIdentifier:@"历史数据回运动" sender:nil];
}
@end
