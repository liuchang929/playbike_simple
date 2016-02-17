//
//  DownLoadTableViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "DownLoadTableViewController.h"
#import "MyTableViewCell.h"
#import "loadMoreView.h"
#import "UIImageView+WebCache.h"
#import "CurrentAccount.h"
#import "MobClick.h"

@interface DownLoadTableViewController ()<loadMoreViewDelegate>
{
    loadMoreView * loadView;
    NSMutableArray * moiveArray;
    CurrentAccount * current;
}

@end

@implementation DownLoadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"街景";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton * rigthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rigthBtn setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    [rigthBtn setFrame:CGRectMake(0, 0, 24, 24)];
    [rigthBtn addTarget:self action:@selector(downMoive) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rigth = [[UIBarButtonItem alloc] initWithCustomView:rigthBtn];
    self.navigationItem.rightBarButtonItem = rigth;
    
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [backImage setImage:[UIImage imageNamed:@"自由训练背景"]];
    [self.tableView setBackgroundView:backImage];
    
    [self addLoadView];
    [self getMoive];
    
    
    
    current = [CurrentAccount sharedCurrentAccount];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"已下载街景页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"已下载街景页面"];
}

#pragma mark - 跳转到下载界面
-(void)downMoive
{
    [self performSegueWithIdentifier:@"downMoive" sender:nil];
}


#pragma mark - 添加发现
-(void)addLoadView
{
    loadView = [[[NSBundle mainBundle] loadNibNamed:@"loadMore" owner:nil options:nil] lastObject];
    loadView.frame = CGRectMake(loadView.frame.origin.x, loadView.frame.origin.y, self.view.frame.size.width, loadView.frame.size.height);
    loadView.delegate = self;
    //    loadView.action.layer.cornerRadius = 5;
    //    loadView.layer.masksToBounds = YES;
    self.tableView.tableFooterView = loadView;
}

-(void)loadMore:(UIButton *)button
{
    [self downMoive];
}

//获取下载视频的列表
-(void)getMoive
{
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    docPath = [docPath stringByAppendingPathComponent:@"road_localMiove.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
        //先将读取数据到字典中
        moiveArray =[[NSMutableArray alloc] initWithContentsOfFile:docPath];
    }
    else
    {
        moiveArray = [NSMutableArray array];
        //self.tableView.tableFooterView.hidden = YES;
    }
    
    if (moiveArray.count == 0)
    {
        loadView.hidden = YES;
        
        UIImageView * backImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
        [backImage setImage:[UIImage imageNamed:@"无街景背景"]];
        [self.tableView setBackgroundView:backImage];
    }
    [self.tableView reloadData];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str = @"downLoad";
    MyTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        
        //使用xib 进行cell 构建
        //cell = [[[NSBundle mainBundle] loadNibNamed:@"LCGroupBugingCell" owner:nil options:nil] lastObject];
        
        //使用xib加载的另一种形式
        UINib * nib = [UINib nibWithNibName:@"MyTableViewCell" bundle:nil];
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cell.frame.size.height);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary * dic = [moiveArray objectAtIndex:indexPath.row];
    //NSLog(@"idc = %@, name = %@, text = %@", dic,[dic objectForKey:@"name"],[dic objectForKey:@"video_desrc1"]);
    cell.name.text = [NSString stringWithFormat:@"%@ |",[dic objectForKey:@"video_name"]];
    cell.video_desrc1.text = [NSString stringWithFormat:@"%.2f公里 | ",[[dic objectForKey:@"mile_long"] floatValue] / 1000.0];
    cell.downState.text = @"已下载";
    
    //电影图片
    //加载网络头像
    NSString * imageStr = [dic objectForKey:@"video_img_url"];
    NSURL * imageUrl = [NSURL URLWithString:imageStr];
    [cell.Image sd_setImageWithURL:imageUrl];
    
    return cell;
}

#pragma mark - table属性
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
    return moiveArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",indexPath.row);
    current.roadMoive = [moiveArray[indexPath.row] objectForKey:@"video_id"];
    [self performSegueWithIdentifier:@"localMoive" sender:nil];
}

#pragma mark - 添加左划删除按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        editingStyle = UITableViewCellEditingStyleNone;
    }
    else
    {
        editingStyle = UITableViewCellEditingStyleDelete;
    }
}

-(NSArray * )tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction * deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                              {//title可自已定义
                                                  NSLog(@"删除已下载的指导视频");
                                                  
                                                  //删除视频
                                                  NSString * deleteFileName = [NSString stringWithFormat:@"%@/%@.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] , [moiveArray[indexPath.row] objectForKey:@"video_id"]];
                                                  NSLog(@"dele = %@", deleteFileName);
                                                  
                                                  
                                                  NSFileManager * fileManager = [NSFileManager defaultManager];
                                                  BOOL blHave = [fileManager fileExistsAtPath:deleteFileName];
                                                  if(blHave)
                                                  {
                                                      BOOL blDele = [fileManager removeItemAtPath:deleteFileName error:nil];
                                                      if (blHave) {
                                                          NSLog(@"删除已下载的指导视频");
                                                      }
                                                  }
                                                  
                                                  //删除列表
                                                  [moiveArray removeObjectAtIndex:indexPath.row];
                                                  NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                                  docPath = [docPath stringByAppendingPathComponent:@"road_localMiove.plist"];
                                                  [moiveArray writeToFile:docPath atomically:YES];
                                                  
                                                  //复位
                                                  [self getMoive];
                                                  
                                              }];//此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    //    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
    //        NSLog(@"取消删除");
    //        MyTableViewCell * cell = (MyTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    //        cell.editingStyle =
    //    }];
    //    editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];//可以定义RowAction的颜色
    //    return @[deleteRoWAction, editRowAction];
    return @[deleteRoWAction];
    
}


@end
