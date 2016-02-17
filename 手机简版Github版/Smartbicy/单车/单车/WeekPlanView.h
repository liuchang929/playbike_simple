//
//  WeekPlanView.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/29.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface WeekPlanView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

//显示单次计划的view
@property (strong, nonatomic) UIImageView * onePlanView;
@property (strong, nonatomic) NSMutableDictionary * weekPlanDic;//存放周计划的数据
@property (strong, nonatomic) UITextField * aimText;
@property (strong, nonatomic) NSArray * onePlanData;




@end
