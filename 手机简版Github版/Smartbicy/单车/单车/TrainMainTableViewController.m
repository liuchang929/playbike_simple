//
//  TrainMainTableViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TrainMainTableViewController.h"
#import "MyTableViewCell.h"
#import "HeadViewTableViewCell.h"
#import "loadMoreView.h"
#import "AFNetworking.h"
#import "CurrentAccount.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"

@interface TrainMainTableViewController ()<loadMoreViewDelegate,HeadViewTableViewCellDelegate>
{
    HeadViewTableViewCell * myHeadView;
    loadMoreView * loadView;
    CurrentAccount * currentAccount;
    NSMutableArray * moiveArray;
}

@end

@implementation TrainMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton * rigthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rigthBtn setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    [rigthBtn setFrame:CGRectMake(0, 0, 24, 24)];
    [rigthBtn addTarget:self action:@selector(downDirect) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rigth = [[UIBarButtonItem alloc] initWithCustomView:rigthBtn];
    self.navigationItem.rightBarButtonItem = rigth;


    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [backImage setImage:[UIImage imageNamed:@"整体背景"]];
    [self.tableView setBackgroundView:backImage];

    
    currentAccount = [CurrentAccount sharedCurrentAccount];
    
    [self getMoive];
    //添加Foot视图
    [self addLoadView];
    
    //添加head视图, 作为第一的cell
    [self addHeadView];
    
    //获取签到信息
    [self loadSignInfo];
    //获取总卡路里
    [self loadTotalCal];
    //获取今天消耗
    [self loadTodayCal];
    //获取排名
    [self loadRank];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"主页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"主页面"];
}

//获取下载视频的列表
-(void)getMoive
{
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"dir_localMiove.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
        //先将读取数据到字典中
        moiveArray =[[NSMutableArray alloc] initWithContentsOfFile:docPath];
    }
    else
    {
        moiveArray = [NSMutableArray array];
    }
    [self.tableView reloadData];
}

#pragma mark - 跳转到下载界面
-(void)downDirect
{
    [self performSegueWithIdentifier:@"downDirect" sender:nil];
}

-(void)addHeadView
{
    myHeadView = [[[NSBundle mainBundle] loadNibNamed:@"HeadViewTableViewCell" owner:nil options:nil] lastObject];
    myHeadView.frame = CGRectMake(myHeadView.frame.origin.x, myHeadView.frame.origin.y, self.view.frame.size.width, 136);
    myHeadView.delegate = self;
    //后面删除cell时，会导致header跟着滑动，所以设置成cell
    //self.tableView.tableHeaderView = myHeadView;
}

-(void)jumpRank
{
    [self performSegueWithIdentifier:@"rank" sender:nil];
}

-(void)addLoadView
{
    loadView = [[[NSBundle mainBundle] loadNibNamed:@"loadMore" owner:nil options:nil] lastObject];
    loadView.frame = CGRectMake(loadView.frame.origin.x, loadView.frame.origin.y, self.view.frame.size.width, loadView.frame.size.height);
    loadView.delegate = self;
//    loadView.action.layer.cornerRadius = 5;
//    loadView.layer.masksToBounds = YES;
    self.tableView.tableFooterView = loadView;
}

#pragma mark - 跳转到下载知道视频界面
-(void)loadMore:(UIButton *) button
{
    [self downDirect];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0) {
        return 136;
    }
    return 183;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(moiveArray.count == 0)
    {
        return 2;
    }
    else
    {
        return moiveArray.count + 2;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str = @"main";
    MyTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    cell.backgroundColor = [UIColor clearColor];
    if (cell == nil) {
        
        //使用xib 进行cell 构建
        //cell = [[[NSBundle mainBundle] loadNibNamed:@"LCGroupBugingCell" owner:nil options:nil] lastObject];
        
        //使用xib加载的另一种形式
        UINib * nib = [UINib nibWithNibName:@"MyTableViewCell" bundle:nil];
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cell.frame.size.height);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //取消header的用户交互
        if (indexPath.row == 0) {
            [cell addSubview:myHeadView];
        }
        else if (indexPath.row == 1) {
            cell.Image.image = [UIImage imageNamed:@"自由训练.jpg"];
            cell.name.text = @"自由训练";
        }
        
        //设置指导训练的标题
        else
        {
            NSDictionary * dic = [moiveArray objectAtIndex:indexPath.row - 2];
            //NSLog(@"idc = %@, name = %@, text = %@", dic,[dic objectForKey:@"name"],[dic objectForKey:@"video_desrc1"]);
            cell.name.text = [NSString stringWithFormat:@"%@ |",[dic objectForKey:@"name"]];
            cell.video_desrc1.text = [NSString stringWithFormat:@"%@ | ",[dic objectForKey:@"video_desrc1"]];
            cell.downState.text = @" 已下载";
            
            //电影图片
            //加载网络头像
            NSString * imageStr = [dic objectForKey:@"video_img_url"];
            //NSString * imageStr = @"http://7xpf48.com1.z0.glb.clouddn.com/6hongniubisai.jpg";
            NSURL * imageUrl = [NSURL URLWithString:imageStr];
            [cell.Image sd_setImageWithURL:imageUrl];
        }
    }

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",indexPath.row);
    //自由训练界面
    if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"freeTrain" sender:nil];
    }
    
    else
    {
        currentAccount.dirMoive = [[moiveArray objectAtIndex:indexPath.row -2] objectForKey:@"video_id"];
        [self performSegueWithIdentifier:@"directTrain" sender:nil];
    }
}

#pragma mark - 添加左划删除按钮
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 0) {
//        editingStyle = UITableViewCellEditingStyleNone;
//    }
//    else
//    {
//        editingStyle = UITableViewCellEditingStyleDelete;
//    }
//}
//
//-(NSArray * )tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//        UITableViewRowAction * deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//                                                  {//title可自已定义
//                                                      if (indexPath.row > 1) {
//                                                          
//                                                          //删除视频
//                                                          NSString * deleteFileName = [NSString stringWithFormat:@"%@/%@.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] , [moiveArray[indexPath.row - 2] objectForKey:@"video_id"]];
//                                                          NSLog(@"dele = %@", deleteFileName);
//                                                          
//                                                          
//                                                          NSFileManager * fileManager = [NSFileManager defaultManager];
//                                                          BOOL blHave = [fileManager fileExistsAtPath:deleteFileName];
//                                                          if(blHave)
//                                                          {
//                                                              BOOL blDele = [fileManager removeItemAtPath:deleteFileName error:nil];
//                                                              if (blDele) {
//                                                                  NSLog(@"删除已下载的指导视频");
//                                                              }
//                                                          }
//                                                          
//                                                          //删除列表
//                                                          [moiveArray removeObjectAtIndex:indexPath.row - 2];
//                                                          NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                                                          docPath = [docPath stringByAppendingPathComponent:@"dir_localMiove.plist"];
//                                                          [moiveArray writeToFile:docPath atomically:YES];
//                                                          
//                                                         
//                                                          
//                                                      }
//                                                      //复位
//                                                      [tableView reloadData];
//                                                      
//
//                                                  }];
//    //此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
//    //    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//    //        NSLog(@"取消删除");
//    //        MyTableViewCell * cell = (MyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    //        cell.editingStyle = 
//    //    }];
//    //    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
//    //    return @[deleteRoWAction, editRowAction];
//        return @[deleteRoWAction];
//
//}

#pragma mark - 获取签到信息
-(void)loadSignInfo
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/signinServlet?type=getdata&username=%@",currentAccount.serverName,currentAccount.userName];
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
                    myHeadView.sign.text = [NSString  stringWithFormat:@"连续打卡%@天",[[array objectAtIndex:0] objectForKey:@"register"]];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    myHeadView.sign.text = @"连续打卡0天";
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                myHeadView.sign.text = @"连续打卡0天";
            });
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败了 %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - 获取distance总里程；time总时间；totalcal总消耗卡路里
-(void)loadTotalCal
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/RankServlet?type=gettotaldata&username=%@",currentAccount.serverName,currentAccount.userName];
    
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url= [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dictionary = responseObject;
        //解析数据
        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];
        
        //字典-》数组-》字典，真是醉了！！
        if (ret == 1)
        {
            if ([[dictionary objectForKey:@"content"] count] != 0)
            {
                NSArray * dic = [dictionary objectForKey:@"content"];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //显示总卡路里
                    NSString * totalStr = nil;
                    CGFloat totalCal = [[dic[0] objectForKey:@"totalcal"] floatValue];
                    if (totalCal > 1000.0) {
                        totalStr = [NSString stringWithFormat:@"%.1fK",totalCal/1000.0];
                    }
                    else
                    {
                        totalStr = [NSString stringWithFormat:@"%.1f",totalCal];
                    }
                    
                    
                    CGFloat time = [[dic[0] objectForKey:@"time"] floatValue] / 3600.0;
                    NSString * timeStr = [NSString stringWithFormat:@"%.2f",time];
                    
                    myHeadView.totalCal.text = totalStr;
                    myHeadView.time.text = timeStr;
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    myHeadView.sign.text = @"签到 0 天";
                });
            }
            
            
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败了 %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

#pragma mark - 获取今日消耗
-(void)loadTodayCal
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@/RankServlet?type=getdaycal",currentAccount.serverName];
    
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url= [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dictionary = responseObject;
        //解析数据
        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];
        
        if (ret == 1) {
            
            NSString * todayCal = [NSString stringWithFormat:@"%ld",[[dictionary objectForKey:@"content"] integerValue]];
            
            CGFloat Cal = [[dictionary objectForKey:@"content"] floatValue];
            if (Cal > 1000.0) {
                todayCal = [NSString stringWithFormat:@"%.1fK",Cal/1000.0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //NSLog(@"%@", todayCal);
                myHeadView.todayCal.text = todayCal;
            });
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败了 %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}


#pragma mark - 获取排名
-(void)loadRank
{
    NSDate * date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString * todayStr = [formatter stringFromDate:date];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/RankServlet?type=allusersdayCalCheck&date=%@",currentAccount.serverName,todayStr];
    
    //有中文，需要转换
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url= [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    //连接、解析
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dictionary = responseObject;
        //NSLog(@"排名返回%@",dictionary);
        
        //解析数据
        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];
        
        if (ret == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger totalUserNumber = [[dictionary objectForKey:@"totalUserNumber"] intValue];
                myHeadView.rank.text = [NSString stringWithFormat:@"今日排名%ld名",totalUserNumber];
            });
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败了 %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}



@end
