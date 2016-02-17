//
//  WeekPlanView.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/29.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "WeekPlanView.h"
#import "CurrentAccount.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@implementation WeekPlanView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self showOnePlan];
    }
    return self;
}

-(NSString *)datafilePath//返回数据文件的完整路径名。
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:@"weekPlan.plist"];
}

-(void)showOnePlan
{
    //_onePlanView为刚进入练一把弹出提示的界面背景
    _onePlanView = [[UIImageView alloc] initWithFrame:self.frame];
    _onePlanView.image = [UIImage imageNamed:@"clearBG.png"];
    [self addSubview:_onePlanView];
    NSString * plistPath = [self datafilePath];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    //messageView为提示的背景图片
    UIImageView * messageView = [[UIImageView alloc] initWithFrame:CGRectMake(298, 289, 428, 200)];
    
    CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
    if (!currentAccount.guestAccount)
    {
        //根据用户有没有设置周计划而显示不同的view
        //用户没有设置目标
        if ([[dictionary objectForKey:@"aim"] intValue] == 0)
        {
            messageView.image = [UIImage imageNamed:@"tips1.png"];
    
            
            //iPhone6Plus
            if(SCREEN_WIDTH == 414 && SCREEN_HEIGHT == 736)
            {
                messageView.frame = CGRectMake(26, 218, 361, 194);
            }
            
            //iPhone5/5s
            if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
            {
                 messageView.frame = CGRectMake(20, 169, 280, 150);
            }
            
            //iPhone6
            if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
            {
                messageView.frame = CGRectMake(23, 198, 328, 176);
            }
        }
        else
        {
            messageView.image = [UIImage imageNamed:@"tipsL.png"];
            
            //获取距离目标数还有多远
            float trainingGoal, completeGoal;
            trainingGoal = [[dictionary objectForKey:@"aim"] intValue];
            completeGoal = [[dictionary objectForKey:@"complete"] intValue];
            //NSLog(@"trainingGoal = %f, completeGoal = %f",trainingGoal,completeGoal);
            NSString * distanceStr = [[NSString alloc] initWithFormat:@"%d", (int)(trainingGoal-completeGoal)];
            
            UILabel * distanceLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 74, 40)];
            distanceLable.text = distanceStr;
            distanceLable.font = [UIFont fontWithName:@"FZLanTingHei-M-GBK" size:24.0f];
            distanceLable.textColor = [UIColor colorWithRed:255/255 green:114/255 blue:0 alpha:0.5];
            distanceLable.textAlignment = NSTextAlignmentCenter; //文字居中
            
            
            //iPhone6Plus
            if(SCREEN_WIDTH == 414 && SCREEN_HEIGHT == 736)
            {
                messageView.frame = CGRectMake(26, 218, 423, 258);
                distanceLable.frame = CGRectMake(228, 84, 103, 52);
            }
            
            //iPhone5/5s
            if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
            {
                messageView.frame = CGRectMake(20, 169, 280, 150);
                distanceLable.frame = CGRectMake(177, 65, 80, 40);
            }
            
            //iPhone6
            if(SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 667)
            {
                messageView.frame = CGRectMake(23, 197, 328, 176);
                distanceLable.frame = CGRectMake(207, 76, 94, 47);
            }
            
           [messageView addSubview:distanceLable];
        }
        
    }
    //游客
    else
    {
        messageView.image = [UIImage imageNamed:@"tips2.png"];
        
        //iPhone6Plus
        if(SCREEN_WIDTH == 414 && SCREEN_HEIGHT == 736)
        {
            messageView.frame = CGRectMake(26, 218, 423, 258);
        }
        //iPhone5/5s
        if(SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 568)
        {
             messageView.frame = CGRectMake(20, 169, 280, 150);
        }
        //iPhone6
        if(SCREEN_WIDTH == 667 && SCREEN_HEIGHT == 375)
        {
            messageView.frame = CGRectMake(23, 197, 328, 176);
        }
    }
    [self addSubview:messageView];
}

@end
