//
//  NewFeaturesController.m
//  单车
//
//  Created by comfouriertech on 14-6-4.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "NewFeaturesController.h"
#import "QuartzCore/QuartzCore.h"

@interface NewFeaturesController()  <UIScrollViewDelegate> {
    UIPageControl *_pageControl;
}
@end

@implementation NewFeaturesController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //载入featuresImages.plist 其中存放的为新特性图片的图片名
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"featuresImages.plist" ofType:nil];
    NSArray *featuresImages = [NSArray arrayWithContentsOfFile:path];
    
    //提取全屏尺寸，方便后续赋值
    CGFloat height = _scrollView.frame.size.width;
    CGFloat width = _scrollView.frame.size.height;
    //NSLog(@"--NewFeatureController.m--> width--%f   height---%f", width, height);

    //添加新特性的图片
    //当改动新特性图片时：
    //1.修改plist中的图片名，确保plist中的单元个数与图片张数一致
    //2.将新特性图片放入库，推荐-->images中
    for (int i=0; i<featuresImages.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:featuresImages[i]];
        imageView.frame = CGRectMake(i * width, 0, width, height);
        [_scrollView addSubview:imageView];
    }

    //设置立即体验Button
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(width * featuresImages.count - 650, height - 200, 300, 80)];
    btn.hidden = NO;
    //字体颜色。不按为黑色
    btn.tintColor = [UIColor blackColor];
    //按下与松开的按钮Action
    [btn addTarget:self action:@selector(enter:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    //设置按钮上文字
    [btn setTitle:@"立即体验" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:35.0];   //字体
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; //颜色。普通状态下
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];    //颜色。按下的状态
    
    //[btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [btn.layer setBorderWidth:3.0]; //边框宽度
    
    //设置边框的颜色，默认是黑色。使用argb模式
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1}); //白色
//    [btn.layer setBorderColor:colorref];
    [_scrollView addSubview:btn];
    
    //设置能显示的尺寸
    _scrollView.contentSize = CGSizeMake(width *featuresImages.count, 0);
    //设置分页
    _scrollView.pagingEnabled = YES;
    //是否显示滑动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    //内容显示模式
    _scrollView.contentMode = UIViewContentModeCenter;

    //设置pageControl
    _pageControl = [[UIPageControl alloc] init];
    //设置pageControl位置
    _pageControl.center = CGPointMake(height * 0.5, height - 60);
    _pageControl.bounds = CGRectMake(0, 0, 100, 37);
    //设置pageControl数目，就是图片张数。根据plist中
    _pageControl.numberOfPages = featuresImages.count;
    //设置pageControl的颜色-->两种
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
    //是否可以点击。取消
    _pageControl.enabled = NO;
    [self.view addSubview:_pageControl];
 
}

#pragma 按下按钮
- (void)touchDown :(UIButton *)btn {
    //按下按钮，改变边框颜色为白色。此时字体颜色也为白色
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1});
    [btn.layer setBorderColor:[UIColor grayColor].CGColor];
}

#pragma 松开按钮
- (void)enter :(UIButton *)btn{
    //松开按钮，改变边框颜色为黑色。此时字体颜色也为黑色
    CGColorRef colorref = [UIColor blackColor].CGColor;
    [btn.layer setBorderColor:colorref];
    //进入下一个viewController
    [self performSegueWithIdentifier:@"Welcome2" sender:self];
}

#pragma 更新pageControl状态
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //设置pageControl动态显示。第几张图对应第几个点
    int pageNum = scrollView.contentOffset.x / _scrollView.frame.size.width;
    _pageControl.currentPage = pageNum;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
