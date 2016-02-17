//
//  DirectorVideoDownLoadViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "DirectorVideoDownLoadViewController.h"
#import "DirectorViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "CurrentAccount.h"
#import "TBAppDelegate.h"
#import "MobClick.h"

@interface DirectorVideoDownLoadViewController ()<DirectorViewCellDelegate,NSURLSessionDownloadDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
{
    CurrentAccount * current;
    NSString *savePath; //真实保存路径
}

@property (nonatomic, strong) NSMutableArray * moiveList;
@property (nonatomic, strong) NSMutableArray * localMoiveArray;
@end

@implementation DirectorVideoDownLoadViewController


-(NSMutableArray * ) moiveList
{
    if (_moiveList == nil) {
        _moiveList = [NSMutableArray array];
    }
    return _moiveList;
}

-(NSMutableArray * ) localMoiveArray
{
    if (_localMoiveArray == nil) {
        _localMoiveArray = [NSMutableArray array];
    }
    return _localMoiveArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    current = [CurrentAccount sharedCurrentAccount];
    
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [backImage setImage:[UIImage imageNamed:@"整体背景"]];
    [self.tableView setBackgroundView:backImage];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [self getMoiveList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"指导视频下载页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"指导视频下载页面"];
}

-(void)back
{
    current.page = 0;
    [self performSegueWithIdentifier:@"directList" sender:nil];
}

-(void)getMoiveList
{

    NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/guidanceVideoServlet?type=getlist",current.serverName];

   //有中文，需要转换
   
   urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   
   NSURL *url = [NSURL URLWithString:urlString];
   
   NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];

   //连接、解析
   
   AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
   
   op.responseSerializer = [AFJSONResponseSerializer serializer];
   
   [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        
        NSDictionary *dictionary = responseObject;
        
        //解析数据
        
        NSInteger ret = [[dictionary objectForKey:@"ret"] intValue];

        if (ret == 1) {
            self.moiveList = [dictionary objectForKey:@"content"];
            
            //沙盒根路径
            NSString *docDirPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            //获取存放本地视频plist文件的路径, 先将读取数据到字典中
            NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            docPath = [docPath stringByAppendingPathComponent:@"dir_localMiove.plist"];
            
            
            //先判断本地是否有已经存在的文件
            for (int num = 0; num < _moiveList.count; num++) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp4", docDirPath , [self.moiveList[num] objectForKey:@"video_id"]];
                NSLog(@"filePath = %@",filePath);
                BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
                //将已经存在的文件添加到plist文件中
                if (blHave) {
                    [self.localMoiveArray addObject:_moiveList[num]];
                }
            }
            [self.localMoiveArray writeToFile:docPath atomically:YES];
            
            NSMutableArray * array = [NSMutableArray arrayWithArray:self.moiveList];
            
            //将本地存在的视频移除,并且创建一个本地的plist文件存储视频信息
            if (self.localMoiveArray.count != 0)
            {
                for(NSDictionary * dic_loc in self.localMoiveArray)
                {
                    [array removeObject:dic_loc];
                }
            }
            
            self.moiveList = array;
            
            [self.tableView reloadData];

            
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"失败了 %@", error);
        
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 185;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.moiveList.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str = @"director";
    DirectorViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        
        //使用xib 进行cell 构建
        //cell = [[[NSBundle mainBundle] loadNibNamed:@"LCGroupBugingCell" owner:nil options:nil] lastObject];
        
        //使用xib加载的另一种形式
        UINib * nib = [UINib nibWithNibName:@"DirectorViewCell" bundle:nil];
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cell.frame.size.height);
        cell.downBtn.tag = indexPath.row;
        cell.delegate = self;
        
        //设置cell的具体内容
        if (self.moiveList.count  > indexPath.row)
        {
            NSDictionary * dic = [self.moiveList objectAtIndex:indexPath.row];
            //NSLog(@"idc = %@, name = %@, text = %@", dic,[dic objectForKey:@"name"],[dic objectForKey:@"video_desrc1"]);
            cell.name.text = [NSString stringWithFormat:@"%@ |",[dic objectForKey:@"name"]];
            cell.video_desrc1.text = [NSString stringWithFormat:@"%@ | ",[dic objectForKey:@"video_desrc1"]];
            cell.downState.text = @"未下载";
            
            //电影图片
            //加载网络头像
            NSString * imageStr = [dic objectForKey:@"video_img_url"];
            //NSString * imageStr = @"http://7xpf48.com1.z0.glb.clouddn.com/6hongniubisai.jpg";
            NSURL * imageUrl = [NSURL URLWithString:imageStr];
            [cell.Image sd_setImageWithURL:imageUrl];
            
            if (current.dir_downloadCell.downBtn.tag == indexPath.row && current.dir_isLoading && !current.road_isLoading) {
                
                current.dir_downloadCell = cell;
                
                [cell.downBtn setImage:[UIImage imageNamed:@"暂停下载"] forState:UIControlStateNormal];
                cell.downState.text = @"正在下载";
                cell.persent.hidden = NO;
            }
        }
    }
    return cell;
}

#pragma mark -  下载视频触发（显示进度）
-(void)down:(UIButton *)sender
{
    NSLog(@"tag = %ld",sender.tag);
    NSLog(@"list = %@", self.moiveList);
    //获取当前正在下载的cell,显示进度
    DirectorViewCell * cell =  (DirectorViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];

    //有视频指导视频正在下载,没有街景视频下载,不执行操作
    if ((current.dir_isLoading && cell.downBtn.tag != current.dir_downBtnTag) || current.road_isLoading) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"一次仅能下载一个视频!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
 
    
    //下载
    if ([cell.downState.text isEqualToString:@"未下载"])
    {
        current.dir_downloadCell = cell;
        current.dir_isLoading = YES;
        current.road_isLoading = NO;
        current.dir_downBtnTag = sender.tag;
        
        [cell.downBtn setImage:[UIImage imageNamed:@"暂停下载"] forState:UIControlStateNormal];
        cell.downState.text = @"正在下载";
        cell.persent.hidden = NO;
        cell.persent.text = @"已下载 0%";
        
        NSDictionary * dic = _moiveList[sender.tag];
        //NSLog(@"全部电影 = %@ ----------\n待下载的电影 = %@",moiveArray,moiveArray[button.tag]);
        
        //NSURL *url = [NSURL URLWithString:@"http://v.jxvdy.com/sendfile/jbBDIpe0t2tobTb-QXzOz2ZFHSH2exjqsoeiTcHDlVEVbILeP_7tK8LtgbzMjlM2c2MuWd8Zwoem8a-jFlY58VE5qDVtzQ"];//请求地址
        
        NSURL * url = [NSURL URLWithString:[dic objectForKey:@"video_down_url"]];//请求地址
        NSLog(@"url = %@",url);
        
        //专门用来管理session的类(可以配置全局访问网络的参数), 是一个单例的类
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fluency.download"];
        [config setHTTPMaximumConnectionsPerHost:900];
        //delegateQueue: 指定一个回调方法执行的线程, 也可以是nil也是子线程
        current.dir_session_progress = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        current.dir_sessionTask = [current.dir_session_progress downloadTaskWithURL:url];
        [current.dir_sessionTask resume];
        
        //NSString * path = NSHomeDirectory();//该方法得到的是应用程序目录的路径
        NSString * path =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSLog(@"path = %@", path);
        
        
        //目的路径，设置一个目的路径用来存储下载下来的文件
        NSString * string = [NSString stringWithFormat:@"%@.mp4",[dic objectForKey:@"video_id"]];
        current.dir_downLoadMoiveId = string;
        savePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:string];
        
    }
    //取消下载
    else  if ([cell.downState.text isEqualToString:@"正在下载"])
    {
        [cell.downBtn setImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
        cell.downState.text = @"未下载";
        cell.persent.hidden = YES;
        
        current.dir_downloadCell = nil;
        current.dir_isLoading = NO;
        
        //取消下载
        [current.dir_session_progress invalidateAndCancel];
        //释放会话
        current.dir_session_progress = nil;
        current.dir_sessionTask = nil;
    }
}

#pragma mark - 代理方法
// 1. 下载完成后被调用的方法 ios7、8都必须实现
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"下载完成");
    
    //取消下载
    [current.dir_session_progress invalidateAndCancel];
    //释放会话
    current.dir_session_progress = nil;
    current.dir_sessionTask = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        current.dir_downloadCell = nil;
        current.dir_isLoading = NO;
        
        NSLog(@"list = %@", self.moiveList);
        //更新
        [self.localMoiveArray addObject:[self.moiveList objectAtIndex:current.dir_downBtnTag]];
            
        [self.moiveList removeObjectAtIndex:current.dir_downBtnTag];
        [self.tableView reloadData];
        
        //获取存放本地视频plist文件的路径
        NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        docPath = [docPath stringByAppendingPathComponent:@"dir_localMiove.plist"];
        [self.localMoiveArray writeToFile:docPath atomically:YES];
    });
    
    NSString *caches= [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  lastObject];
    NSString* filename=[caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    //     NSFileManager *fileManager = [NSFileManager defaultManager];
    //    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    //    if (!fileExists)
    //    {//如果不存在则创建,因为下载时,不会自动创建文件夹
    //
    //        [fileManager createDirectoryAtPath:savePath
    //               withIntermediateDirectories:YES
    //                                attributes:nil
    //                                     error:nil];
    //    }
    NSData * data = [NSData dataWithContentsOfFile:location.path];
    [data writeToFile:savePath atomically:YES];
    
}


// 2. 下载进度变化被调用的 ios7必须实现 ios8不用必须
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    /*
     bytesWritten               本次写入的字节数
     totalBytesWritten          已经写入的字节数
     totalBytesExpectedToWrite  下载文件总字节数
     */
    
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@" %@ ,progress = %f",[NSThread currentThread],progress);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DirectorViewCell * cell = current.dir_downloadCell;
        float percent = progress * 100.00;
        cell.persent.text = [NSString stringWithFormat:@"%0.1f%%",percent];
    });
    
}

// 3. 断点续传被调用（一般什么都不用写） ios7必须实现 ios8不用必须
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        NSLog(@"任务: %@ 成功完成", task);
    } else {
        NSLog(@"任务: %@ 发生错误: %@", task, [error localizedDescription]);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
    TBAppDelegate *appDelegate = (TBAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.dir_backgroundSessionCompletionHandler) {
        
        void (^completionHandler)() = appDelegate.dir_backgroundSessionCompletionHandler;
        
        appDelegate.dir_backgroundSessionCompletionHandler = nil;
        
        completionHandler();
        
    }
    NSLog(@"All tasks are finished");
    
}



@end
