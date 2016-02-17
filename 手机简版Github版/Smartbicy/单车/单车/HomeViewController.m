//
//  HomeViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 16/2/2.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import "HomeViewController.h"
#import "MobClick.h"
#import "AFNetworking.h"
#import "CurrentAccount.h"

@interface HomeViewController () <UIScrollViewDelegate>
{
    CurrentAccount *currentAccount;
    NSInteger currentPage;
    NSTimer *  timer ;
}

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentAccount = [CurrentAccount sharedCurrentAccount];
    [self getServerUrl];
    
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    
    for (int i = 0; i < 3; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"背景%d.jpg",i + 1]];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        
        imageView.frame = CGRectMake(i * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(3 * self.view.frame.size.width, self.view.frame.size.height);
    
    [self addTimer];
}

-(void)addTimer
{
    timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)nextPage
{
    if (_pageControl.currentPage < 2) {
        ++_pageControl.currentPage;
        [UIView animateWithDuration:0.5 animations:^
         {
             _scrollView.contentOffset = CGPointMake(self.view.frame.size.width + _scrollView.contentOffset.x, _scrollView.contentOffset.y);
         }];
    }
    else if  (_pageControl.currentPage == 2)
    {
        _pageControl.currentPage = 0;
        [UIView animateWithDuration:0.1  animations:^
         {
             _scrollView.contentOffset = CGPointMake(0,0);
         }];
        
    }
}

#pragma mark - delegate 方法

//判断当前的页面是第几页
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
     
     //当前便宜距离除以每页的宽度就可计算出是第几页
     int pageNum =  scrollView.contentOffset.x / scrollView.frame.size.width;
     
     */
    
    //由于上面计算第几页的方式在用户翻到一半后还没有显示，所以我们详细更新一下算法
    int pageNum =  (scrollView.contentOffset.x + self.view.frame.size.width/2)/ scrollView.frame.size.width;
    
    _pageControl.currentPage = pageNum;
}

#pragma mark - scrollView将要被拖拽，已经拖拽完毕
//解决定时器小问题
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //停止定时器
    [timer invalidate];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"home页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"home页面"];
}

#pragma  mark - 获取服务器
- (void)getServerUrl
{
    //测试版
    //NSString *urlString = [NSString stringWithFormat:@"http://bikemeurl.duapp.com/servlet/Url?url=test"];
    //发布版
    NSString *urlString = [NSString stringWithFormat:@"http://bikemeurl.duapp.com/servlet/Url"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dictionary = responseObject;
        int ret = [[dictionary objectForKey:@"ret"] intValue];
        
        if (ret == 1) {
            currentAccount.serverName = [dictionary objectForKey:@"url"];
            
        }else{
            //[self showAlertWithString:@"网络异常"];
            currentAccount.serverName = @"bikeme.duapp.com";
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@", error);
        currentAccount.serverName = @"bikeme.duapp.com";
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}
@end
