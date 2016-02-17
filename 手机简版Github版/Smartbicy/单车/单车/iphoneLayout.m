//
//  iphoneLayout.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/29.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "iphoneLayout.h"
#import "LeftNavigationController.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@implementation iphoneLayout

static iphoneLayout * shareIphoneLayout;
UILabel * timeTitle;
UILabel * cal;
UILabel * km;

+(iphoneLayout*)shareIphoneLayout
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareIphoneLayout = [[iphoneLayout alloc] init];
    });
    
    return shareIphoneLayout;
}


#pragma mark- view上Lable得布局
-(void) Time:(UILabel *) timeLable timeT:(UILabel*) timeTitle calT:(UILabel *) calTitle distanceT:(UILabel *) distanceTitle speedT:(UILabel *)speedTitle cal:(UILabel *)calLable distance:(UILabel *)distance speed:(UILabel *)speed me:(UIButton *)me data:(UIButton *)data weekplan:(UIButton *)weekplan view:(UIView *) view
{
    
    timeTitle = [[UILabel alloc] init];
    cal = [[UILabel alloc] init];
    km = [[UILabel alloc] init];
    
    
    //iPhone5/5s
    if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
    {
        [timeLable setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:22.0f]];
        [timeTitle setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:15.0f]];
        UIFont * fontTitle = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:15.0f];
        UIFont * fontLable = [UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:28.0f];
      
        //卡路里，运动时间，里程
        calTitle.frame = CGRectMake(25, 306, 50, 32);
        timeTitle.frame = CGRectMake(129, 306, 80, 32);
        distanceTitle.frame = CGRectMake(255, 306, 50, 32);
        calTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];

        timeTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];

        distanceTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];

        
        //卡路里，运动时间，里程数据
        calLable.frame = CGRectMake(35, 346, 80, 58);
        timeLable.frame = CGRectMake(95, 346, 200, 58);
        distance.frame = CGRectMake(252, 346, 100, 58);
        calLable.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        timeLable.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        distance.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        
          //cal km  由于cal单位和km单位不要了，所以把cal按钮拿来当“档位”用，km拿来当“音乐”用
          cal.frame = CGRectMake(32, 403, 50, 32);
          km.frame = CGRectMake(255, 403, 50, 32);
          cal.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
          km.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];

        
        
        //速度标题与数据
        speedTitle.frame =CGRectMake(116, 402, 120, 32);
        speed.frame = CGRectMake(128, 450, 60, 58);
        speedTitle.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];

        speed.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        
        //        //三个按键
        //        me.frame = CGRectMake(20, 518, 50, 50);
        //        data.frame = CGRectMake(200, 518, 50, 50);
        //        weekplan.frame = CGRectMake(250, 518, 50, 50);
        
        calTitle.font = fontTitle;
        timeTitle.font = fontTitle;
        distanceTitle.font = fontTitle;
        speedTitle.font = fontTitle;
        calLable.font = fontLable;
        distance.font = fontLable;
        speed.font = fontLable;
        timeLable.font = fontLable;
        cal.font = fontTitle;
        km.font = fontTitle;
        
    }
    
    //iPhone6
    if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
    {
        [timeLable setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:35.0f]];
        [timeTitle setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:35.0f]];
        UIFont * fontTitle = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:15.0f];
        UIFont * fontLable = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:22.0f];
        
        
        //卡路里，运动时间，里程
        calTitle.frame = CGRectMake(35, 105, 59, 37);
        timeTitle.frame = CGRectMake(160, 105, 94, 37);
        distanceTitle.frame = CGRectMake(304, 105, 59, 37);
        calTitle.textColor = [UIColor whiteColor];
        timeTitle.textColor = [UIColor whiteColor];
        distanceTitle.textColor = [UIColor whiteColor];
        
        //卡路里，运动时间，里程数据
        calLable.frame = CGRectMake(49, 123, 94, 68);
        timeLable.frame = CGRectMake(117, 123, 234, 68);
        distance.frame = CGRectMake(292, 123, 117, 68);
        calLable.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        timeLable.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        distance.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];

        
        //cal km
        cal.frame = CGRectMake(47, 164, 59, 37);
        km.frame = CGRectMake(307, 164, 59, 37);
        cal.textColor = [UIColor yellowColor];
        km.textColor = [UIColor orangeColor];
        
        
        //速度标题与数据
        speedTitle.frame =CGRectMake(310, 372, 59, 37);
        speed.frame = CGRectMake(304, 386, 70, 68);
        speedTitle.textColor = [UIColor whiteColor];
        speed.textColor = [UIColor colorWithRed:254.0f/255.0f green:185.0f/255.0f blue:19.0f/255.0f alpha:1.0f];
        
        //        //三个按键
        //        me.frame = CGRectMake(20, 518, 50, 50);
        //        data.frame = CGRectMake(200, 518, 50, 50);
        //        weekplan.frame = CGRectMake(250, 518, 50, 50);
        
        
        
        
        calTitle.font = fontTitle;
        timeTitle.font = fontTitle;
        distanceTitle.font = fontTitle;
        speedTitle.font = fontTitle;
        calLable.font = fontLable;
        distance.font = fontLable;
        speed.font = fontLable;
        cal.font = fontTitle;
        km.font = fontTitle;
        
    }
    
    
    //iPhone6Plus
    if(SCREEN_WIDTH == 736 && SCREEN_HEIGHT == 414)
    {
        
        [timeLable setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:35.0f]];
        [timeTitle setFont:[UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:35.0f]];
        UIFont * fontTitle = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:15.0f];
        UIFont * fontLable = [UIFont fontWithName:@"FZLTZCHK--GBK1-0" size:22.0f];
        

        
        //卡路里，运动时间，里程
        calTitle.frame = CGRectMake(39, 116, 65, 41);
        timeTitle.frame = CGRectMake(177, 116, 103, 41);
        distanceTitle.frame = CGRectMake(335, 116, 65, 41);
        calTitle.textColor = [UIColor whiteColor];
        timeTitle.textColor = [UIColor whiteColor];
        distanceTitle.textColor = [UIColor whiteColor];
        
        //卡路里，运动时间，里程数据
        calLable.frame = CGRectMake(54, 135, 103, 75);
        timeLable.frame = CGRectMake(129, 135, 258, 75);
        distance.frame = CGRectMake(333, 135, 129, 75);
        calLable.textColor = [UIColor yellowColor];
        timeLable.textColor = [UIColor yellowColor];
        distance.textColor = [UIColor yellowColor];
        
        //cal km
        cal.frame = CGRectMake(52, 181, 65, 41);
        km.frame = CGRectMake(338, 181, 65, 41);
        cal.textColor = [UIColor yellowColor];
        km.textColor = [UIColor yellowColor];
        
        
        //速度标题与数据
        speedTitle.frame =CGRectMake(342, 410, 65, 41);
        speed.frame = CGRectMake(335, 426, 77, 75);
        speedTitle.textColor = [UIColor whiteColor];
        speed.textColor = [UIColor yellowColor];
        
        //        //三个按键
        //        me.frame = CGRectMake(20, 518, 50, 50);
        //        data.frame = CGRectMake(200, 518, 50, 50);
        //        weekplan.frame = CGRectMake(250, 518, 50, 50);
        
        
        
        
        calTitle.font = fontTitle;
        timeTitle.font = fontTitle;
        distanceTitle.font = fontTitle;
        speedTitle.font = fontTitle;
        calLable.font = fontLable;
        distance.font = fontLable;
        speed.font = fontLable;
        cal.font = fontTitle;
        km.font = fontTitle;


    }

    timeLable.text = @"00:00:00";
    calTitle.text = @"卡路里";
    timeTitle.text = @"运动时间";
    distanceTitle.text = @"公里";
    speedTitle.text = @"速度(km/h)";
    cal.text = @"档位";
    km.text = @"音乐";
  
    
    [view addSubview:timeLable];
    [view addSubview:timeTitle];
    [view addSubview:calTitle];
    [view addSubview:distanceTitle];
    [view addSubview:speedTitle];
    [view addSubview:calLable];
    [view addSubview:distance];
    [view addSubview:speed];
    [view addSubview:cal];
    [view addSubview:km];
    
    
    [view addSubview:me];
    [view addSubview:data];
    [view addSubview:weekplan];

}

#pragma mark - 档位设定以及档位设定的调节按钮
//_chooseTapPos为调节档位的数字
-(void) tapPos:(UIImageView*)tapImage chooseTapPos:(UIPickerView *) _chooseTapPos
{
    
    //iPhone5/5s
    if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
    {
        //tapImage.frame = CGRectMake(7, 326, 80, 51);
        tapImage.frame = CGRectMake(0, 0, 0, 0);
        _chooseTapPos.frame = CGRectMake(36, 400, 30, 50);
        _chooseTapPos.backgroundColor = [UIColor whiteColor];
        
    }
    
    //iPhone6
    if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
    {
        tapImage.frame = CGRectMake(0, 0, 0, 0);
        _chooseTapPos.frame = CGRectMake(29, 339, 35, 59);
    }
    
    //iPhone6Plus
    if(SCREEN_WIDTH == 414 && SCREEN_HEIGHT == 736)
    {
        tapImage.frame = CGRectMake(0, 0, 0, 0);
        _chooseTapPos.frame = CGRectMake(32, 374, 39, 65);
        
    }

}

#pragma mark - 创建音乐按钮
-(void) craeteMusicPlay:(UIButton *)playBtn before:(UIButton*)beforeBtn next:(UIButton*) nextBtn viewHeight:(float) height view:(UIView *) view
{

//    [beforeBtn setFrame:CGRectMake(89,height - 90, 50, 50)];
//    [playBtn setFrame:CGRectMake(149,height - 105, 80, 80)];
//    [nextBtn setFrame:CGRectMake(239,height - 90, 50, 50)];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        [beforeBtn setFrame:CGRectMake(50,height - 50, 30, 30)];
//        [playBtn setFrame:CGRectMake(90,height - 58, 45, 45)];
//        [nextBtn setFrame:CGRectMake(145,height - 50, 30, 30)];
//    }
//    beforeBtn = [[UIButton alloc] init];
//    playBtn = [[UIButton alloc] init];
//    nextBtn = [[UIButton alloc] init];
    
    [beforeBtn setFrame:CGRectMake(10, 528, 30, 30)];
    [playBtn setFrame:CGRectMake(230, 455, 40, 40)];
    [nextBtn setFrame:CGRectMake(272, 455, 40, 40)];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        [beforeBtn setFrame:CGRectMake(50, 50, 30, 30)];
//        [playBtn setFrame:CGRectMake(90, 58, 45, 45)];
//        [nextBtn setFrame:CGRectMake(145, 50, 30, 30)];
//    }

    
    [playBtn setBackgroundImage:[UIImage imageNamed:@"音乐开启@2x.png"] forState:UIControlStateNormal];
    
    [beforeBtn setBackgroundImage:[UIImage imageNamed:@"before1@2x.png"] forState:UIControlStateNormal];
    [beforeBtn setBackgroundImage:[UIImage imageNamed:@"before2@2x.png"] forState:UIControlStateHighlighted];
    
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"下一首@2x.png"] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"下一首@2x.png"] forState:UIControlStateHighlighted];
    
    [view addSubview:playBtn];
 //   [view addSubview:beforeBtn];
    [view addSubview:nextBtn];
    
    //在没有开始的时候前后按钮不可用
    beforeBtn.enabled = NO;
    nextBtn.enabled = NO;
}

#pragma mark - 进入练一把时的提示界面
-(void)GuestAccount:(BOOL) _guestAccount  Ten:(UIPickerView*) _tenNum num:(UIPickerView *) _Num closeBtn:(UIButton *) close dictionary:(NSDictionary*) dictionary
{
    if (!_guestAccount)
    {
        //_tenNum为今日目标的十位数；_Num为今日目标的个位数；close为关闭按钮
        //用户没有设置目标
        if ([[dictionary objectForKey:@"aim"] intValue] == 0)
        {
            _tenNum.frame = CGRectMake(145, 200, 30, 90);
            _Num.frame = CGRectMake(167, 225, 30, 40);
            [close setFrame:CGRectMake(260, 172, 33, 33)];
            
            //iPhone6Plus
            if(SCREEN_WIDTH == 414 && SCREEN_HEIGHT == 736)
            {
                _tenNum.frame = CGRectMake(130, 163, 30, 90);
                _Num.frame = CGRectMake(152, 163, 30, 40);
                close.frame = CGRectMake(260, 172, 33, 33);
            }
            //iPhone5/5s
            if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
            {
                _tenNum.frame = CGRectMake(145, 163, 30, 90);
                _Num.frame = CGRectMake(167, 163, 30, 40);
                close.frame = CGRectMake(260, 172, 33, 33);
            }
            
            //iPhone6
            if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
            {
                _tenNum.frame = CGRectMake(104, 260, 35, 105);
                _Num.frame = CGRectMake(130, 260, 35, 47);
                close.frame = CGRectMake(304, 201, 39, 39);
            }
        }
        else
        {
            _tenNum.frame = CGRectMake(89, 220, 30, 90);
            _Num.frame = CGRectMake(111, 220, 30, 40);
            [close setFrame:CGRectMake(260, 172, 33, 33)];
            
            //iPhone6Plus
            if(SCREEN_WIDTH == 736 && SCREEN_HEIGHT == 414)
            {
                _tenNum.frame = CGRectMake(115, 219, 39, 116);
                _Num.frame = CGRectMake(143, 219, 39, 51);
                close.frame = CGRectMake(335, 222, 43, 43);
            }
            
            //iPhone5/5s
            if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
            {
                _tenNum.frame = CGRectMake(89, 170, 30, 90);
                _Num.frame = CGRectMake(111, 170, 30, 40);
                close.frame = CGRectMake(260, 172, 33, 33);
                
            }
            
            //iPhone6
            if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
            {
                _tenNum.frame = CGRectMake(104, 199, 35, 105);
                _Num.frame = CGRectMake(130, 199, 35, 47);
                close.frame = CGRectMake(304, 201, 39, 39);
            }
            
        }
    }
    //游客
    else
    {
        _tenNum.frame = CGRectMake(145, 172, 30, 90);
        _Num.frame = CGRectMake(167, 172, 30, 40);
        [close setFrame:CGRectMake(260, 172, 33, 33)];
        
//        //iPhone6Plus
//        if(SCREEN_WIDTH == 736 && SCREEN_HEIGHT == 414)
//        {
//            _tenNum.frame = CGRectMake(340, 201, 30, 90);
//            _Num.frame = CGRectMake(371, 201, 30, 40);
//            close.frame = CGRectMake(524, 180, 33, 33);
//        }
        //iPhone5/5s
        if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
        {
            _tenNum.frame = CGRectMake(145, 172, 30, 90);
            _Num.frame = CGRectMake(167, 172, 30, 40);
            close.frame = CGRectMake(260, 172, 33, 33);
        }
        //iPhone6
        if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
        {
            _tenNum.frame = CGRectMake(170, 201, 35, 105);
            _Num.frame = CGRectMake(195, 201, 35, 47);
            close.frame = CGRectMake(304, 201, 39, 39);
        }
    }
}

@end
