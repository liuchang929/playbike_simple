//
//  WeekPlanViewController.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/20.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekPlanViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (strong, nonatomic) UIPickerView * aimPicker;
@property (strong, nonatomic) NSArray * dataChoose;
@property (strong, nonatomic) NSString * aimSaveStr; //读取出存储的目标

//设置周计划目标的视图
@property (weak, nonatomic) IBOutlet UIView * planView;

//设置周计划
- (IBAction)settingWeekPlan:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *aimText;
@property (weak, nonatomic) IBOutlet UILabel *doneText;
@property (weak, nonatomic) IBOutlet UILabel *donePercent;
@property (weak, nonatomic) IBOutlet UILabel *lastWeekDone;//上周完成
@property (weak, nonatomic) IBOutlet UILabel *lastWeekPercent;//上周完成率


@end
