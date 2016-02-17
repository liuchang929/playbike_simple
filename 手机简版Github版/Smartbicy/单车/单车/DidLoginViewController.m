//
//  DidLoginViewController.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "DidLoginViewController.h"
#import "CurrentAccount.h"

//#define kModeSelectViewWidth 717
//#define kModeSelectViewHeight 538

#define kOffset [UIScreen mainScreen].bounds.size.width * 9 / 20.0f



@interface DidLoginViewController ()

@end

@implementation DidLoginViewController



-(NSString *)datafilePath
{   //返回数据文件的完整路径名。
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:@"trainingPlan.plist"];
}

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName:[UIFont fontWithName:@"DINCondensed-Bold" size:28],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"RunRunFast";
    [self.view setTag:101];
    

    //用户如果一个星期没有按照计划骑行，提示一下
    CurrentAccount * currentAccount = [CurrentAccount sharedCurrentAccount];
    if(!currentAccount.guestAccount)
    {   int daySub = [self dateSub:[NSDate date] setTime:currentAccount.lastSportTime];
        if (daySub == 7)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经一个星期没有按照训练计划训练了!要持续训练哦！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        //用户运动等级降级
        if(daySub == 14 || daySub > 14)
        {
            
            NSString * path = [self datafilePath];
            NSMutableDictionary * trainingPlanDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            // 用户不是开始1的等级，就进行降级
            if (![[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"开始1"])
            {
                if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"开始2"]) {
                    [trainingPlanDic setValue:@"开始1" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"改善1"]) {
                    [trainingPlanDic setValue:@"开始2" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"改善2"]) {
                    [trainingPlanDic setValue:@"改善1" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"改善3"]) {
                    [trainingPlanDic setValue:@"改善2" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"强化1"]) {
                    [trainingPlanDic setValue:@"改善3" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"强化2"]) {
                    [trainingPlanDic setValue:@"强化1" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"强化3"]) {
                    [trainingPlanDic setValue:@"强化2" forKey:@"sportLevel"];
                }
                else if ([[trainingPlanDic objectForKey:@"sportLevel"] isEqual:@"维持"]) {
                    [trainingPlanDic setValue:@"强化3" forKey:@"sportLevel"];
                }
                //说明用户一周内完成了目标，将weekDone++
                [trainingPlanDic setValue:[NSDate date] forKey:@"saveTime"];
                [trainingPlanDic writeToFile:path atomically:YES];
                NSLog(@"用户降级后存入 %@",trainingPlanDic);
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经两个个星期没有按照训练计划训练了!为了您的身心健康，运动等级将会下降一级。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

//计算两个日期之间的天数之差
-(int)dateSub:(NSDate*) now setTime:(NSDate*) setTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlag = NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlag fromDate:setTime toDate:now options:0];
    int days = [components day];
    return days;
}

#pragma mark - ACTION，进入三种不同的模式
- (IBAction)practicingButton:(UIButton *)sender {
    [self performSegueWithIdentifier:@"trainingModeChoose" sender:nil];
}

- (IBAction)ridingButton:(UIButton *)sender {
     [self performSegueWithIdentifier:@"ridingMode" sender:nil];
}

- (IBAction)playingButton:(UIButton *)sender {
     [self performSegueWithIdentifier:@"gameMode" sender:nil];
}


- (IBAction)openLeftView:(id)sender {

    if (self.navigationController.view.frame.origin.x == 0) {
        self.navigationController.view.frame  = CGRectMake(kOffset, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }else if(self.navigationController.view.frame.origin.x != 0){
        self.navigationController.view.frame  = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
}
@end
