//
//  LocalTrainViewController.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LocalTrainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *settingView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *calLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

//心率
//@property (weak, nonatomic) IBOutlet UILabel *heartLevelText;
@property (assign, nonatomic) int heartBeatCount;
@property (strong, nonatomic) NSMutableArray *datasParsered;
@property (strong, nonatomic) NSString *currentHeartRate; //记录心率数据
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;//心率

@property (assign, nonatomic) float distance;

@end
