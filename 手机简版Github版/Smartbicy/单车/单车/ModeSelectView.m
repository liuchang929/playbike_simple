//
//  ModeSelectView.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-4.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "ModeSelectView.h"

#define kNumberOfMode 3

@interface ModeSelectView() <UIScrollViewDelegate> {
    
    UIPageControl *_pageControl;
    UIButton *_button;
    NSArray *_modeNameArray;
}

@end

@implementation ModeSelectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initModeView];
        [self initModeSelectButton];
        [self initData];
    }
    return self;
}

#pragma mark 初始化选择按钮
- (void)initModeSelectButton
{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 320, 50);
    _button.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height - 100);
    _button.backgroundColor = [UIColor blueColor];
    [_button setBackgroundImage:[UIImage imageNamed:@"buttonBackground.png"] forState:UIControlStateNormal];
    [_button setTitle:@"训练模式" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(enterMode) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_button];
}

#pragma mark 初始化模式视图
-(void)initModeView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 150);
    scrollView.contentSize = CGSizeMake( self.bounds.size.width * kNumberOfMode, 0);
    scrollView.pagingEnabled = YES;
    scrollView.delegate =self;
    
    for (NSInteger i = 0; i<kNumberOfMode; i++) {
        NSString *imageName = [NSString stringWithFormat:@"modeImage%d.png", i];
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = CGRectMake(i * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height - 150);
        
        [scrollView addSubview:imageView];
    }
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height *0.7);
    _pageControl.bounds = CGRectMake(0, 0, 150, 50);
    _pageControl.numberOfPages = kNumberOfMode;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    
    [self addSubview:scrollView];
    [self addSubview:_pageControl];
}

#pragma mark 初始化数据
- (void)initData
{
    _modeNameArray = [NSArray arrayWithObjects:@"训练模式",@"游戏模式",@"骑行模式", nil];
//     NSLog(@"arrayMode--->%@",_modeNameArray[0]);
}

#pragma mark 按钮点击
- (void)enterMode
{
    [self.delegate modeDidSelect:_pageControl.currentPage];
}

#pragma mark -代理方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //更新pageControl
     _pageControl.currentPage = scrollView.contentOffset.x / self.bounds.size.width;
    
    //更新按钮UI
    [_button setTitle:_modeNameArray[_pageControl.currentPage] forState:UIControlStateNormal];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
