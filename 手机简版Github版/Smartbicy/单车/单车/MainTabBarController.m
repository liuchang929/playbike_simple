//
//  MainTabBarController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/30.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "MainTabBarController.h"
#import "CurrentAccount.h"
#import "MobClick.h"

@interface MainTabBarController ()<UITabBarControllerDelegate>
{
    CurrentAccount * current;
}

/**
 *  当前选中的按钮
 */
@property(nonatomic,weak)UIButton *selectedBtn;

@end

@implementation MainTabBarController

#pragma mark - 添加底部按钮
-(void)viewDidLoad{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"tabBar页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"tabBar页面"];
}

- (void)viewWillLayoutSubviews
{
    self.tabBar.backgroundColor = [UIColor blackColor];
    //自己写一个tabbar 替换 系统Tabbar
    //自定义一个tabbar (减一是为了去除一条白线)
    
    //按钮宽度与高度
    CGFloat btnW = self.view.bounds.size.width / 5;
    CGFloat btnH = self.tabBar.bounds.size.height;
    
    CGRect frame =  CGRectMake(self.tabBar.bounds.origin.x, self.tabBar.bounds.origin.y - 1, btnW * 5, self.tabBar.bounds.size.height +2);
    UIView *mTabbar = [[UIView alloc] initWithFrame:frame];
    NSLog(@"%f",mTabbar.bounds.size.width);
    
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:mTabbar.frame];
    [backImage setImage:[UIImage imageNamed:@"菜单背景"]];
    [mTabbar addSubview:backImage];
    
    //切换切面(训练还是街景)
    current = [CurrentAccount sharedCurrentAccount];
    [self setSelectedIndex:current.page];
    
    
    //自定义的tabbar添加5个按钮
    for (NSInteger i = 0; i < 5; i++) {
        // 获取普通状态的图片名称
        NSString *normalImg = [NSString stringWithFormat:@"menu%ld", i];
        
        // 获取选中的图片
        NSString *selImg = [NSString stringWithFormat:@"menuSel%ld", i];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:selImg] forState:UIControlStateSelected];
        
        //设置按钮的frm
        btn.frame = CGRectMake(btnW * i, 0, btnW, btnH);
        
        //监听事件
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        //绑定tag
        btn.tag = i;
        [mTabbar addSubview:btn];
        
        //选中按钮
        if (i == current.page) {
            btn.selected = YES;
            self.selectedBtn = btn;
        }
    }
    
    //把自定义的tabbar添加到 系统的tabbar上
    [self.tabBar addSubview:mTabbar];
}
#pragma marp 自定义tabbar按钮的监听
-(void)btnClick:(UIButton *)btn{
    NSLog(@"%ld",btn.tag);
    
    //取消之前选中
    self.selectedBtn.selected = NO;
    current.page = btn.tag;
    
    //设置当前选中
    btn.selected = YES;
    self.selectedBtn = btn;
    
    //切换 tabbar的子控制器
    //设置tabbar控制器的selectedIndex属性就能切换子控制器
    self.selectedIndex = btn.tag;
    
    //友盟数据统计
    if(btn.tag == 2)
    {
        //周计划
        [MobClick event:@"weekplan_icon"];
    }
    else if (btn.tag == 3)
    {
        //历史数据
        [MobClick event:@"history_icon"];
    }
}

#pragma mark - 代码切换横屏
- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    
//    NSArray * array = [self viewControllers];
//    NSLog(@"%@", array);
//    
//
//    //设置tabBar选中效果
//    
//    self.tabBar.tintColor = [UIColor whiteColor];
//
//    //设置代理
//    self.delegate = self;
//    //添加绿色的背景
//    _imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"注册.png"]];
//    CGFloat w = [UIScreen mainScreen].bounds.size.width;
//    _imageView1.frame = CGRectMake(0, 0, w/5, 49);
//    [self.tabBar insertSubview:_imageView1 belowSubview:self.tabBarItem];
//}
//
////完成代理方法
//-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    CGFloat w = [UIScreen mainScreen].bounds.size.width;
//    NSInteger a = tabBarController.selectedIndex;
//    NSLog(@"a = %ld",a);
//    _imageView1.frame = CGRectMake(a* w/5, 0, w/5, 49);
//    
//}

@end
