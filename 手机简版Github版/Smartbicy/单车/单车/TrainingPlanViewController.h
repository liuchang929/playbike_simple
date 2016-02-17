//
//  TrainingPlanViewController.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/5/4.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainingPlanViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)back:(id)sender;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

- (IBAction)fatBurn:(id)sender; //燃脂
- (IBAction)aerobic:(id)sender; //增强心肺，有氧
@property (weak, nonatomic) IBOutlet UIButton *fatBtn;
@property (weak, nonatomic) IBOutlet UIButton *aerobicBtn;

@property (strong, nonatomic) UIPickerView *heartPicker;
@property (strong, nonatomic) UIPickerView *agePicker;
@property (strong, nonatomic) UIPickerView *sportPicker;

@property (weak, nonatomic) IBOutlet UITextField *heartTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *sportTimeTextField;

@property (weak, nonatomic) IBOutlet UILabel *limis;
@property (weak, nonatomic) IBOutlet UILabel *limisOne;
@property (weak, nonatomic) IBOutlet UILabel *limisTwo;
@property (weak, nonatomic) IBOutlet UILabel *limisThree;
@property (weak, nonatomic) IBOutlet UILabel *limisFour;


@property (weak, nonatomic) IBOutlet UILabel *sportLevel;//阶段


@property (weak, nonatomic) IBOutlet UILabel *monthTimes;
@property (weak, nonatomic) IBOutlet UILabel *weekTimes;
@property (weak, nonatomic) IBOutlet UILabel *remainTimes; //本周剩余

@property (weak, nonatomic) IBOutlet UILabel *fatOrAerobic; //有氧或者燃脂

@property (weak, nonatomic) IBOutlet UILabel *timeOne;
@property (weak, nonatomic) IBOutlet UILabel *timeTwo;
@property (weak, nonatomic) IBOutlet UILabel *timeThree;

@property (weak, nonatomic) IBOutlet UILabel *heartOne;
@property (weak, nonatomic) IBOutlet UILabel *heartTwo;
@property (weak, nonatomic) IBOutlet UILabel *heartThree;

@property (weak, nonatomic) IBOutlet UIImageView *sexImage;
@property (weak, nonatomic) IBOutlet UILabel *planTitle;

@property (weak, nonatomic) IBOutlet UIView *PlanView; //整个计划视图

@end
