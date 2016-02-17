//
//  TrainingModeViewController.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-6-6.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataFromICade.h"
#import "ArcView.h"
#import <CorePlot-CocoaTouch.h>
#import "WXApi.h"
#import <AVFoundation/AVFoundation.h>

@interface TrainingPlanModeViewController : UIViewController <CPTPlotDataSource, CPTAxisDelegate, UINavigationControllerDelegate, WXApiDelegate, UIActionSheetDelegate,UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)startOrEnd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *startOrEndButton;


- (IBAction)shareWithPhoto:(UIButton *)sender;

//音乐部分

//- (IBAction)choose:(id)sender;
- (IBAction)pauseOrStart:(id)sender;
- (IBAction)skipToPrevious:(id)sender;
- (IBAction)skipToNext:(id)sender;

@property (weak, nonatomic) UIButton * localMusic;
@property (weak, nonatomic) UIButton * systemMusic;
@property (strong, nonatomic) AVAudioPlayer * player;
@property (strong, nonatomic) NSArray * musicItem; //存放本地音乐的数组

@property (weak, nonatomic) IBOutlet UIButton *playList;
@property (weak, nonatomic) IBOutlet UIButton *beforeBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;


//@property (weak, nonatomic) IBOutlet UIButton *pauseOrStartButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//- (IBAction)reset:(UIButton *)sender;
//- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet ArcView *arcView;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *stateOfExercise;
@property (weak, nonatomic) IBOutlet UILabel *calLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

//用户数据
@property (strong, nonatomic) NSDictionary *infoDictionary;
@property (strong, nonatomic) NSString *userBirthday;
@property (strong, nonatomic) NSString *userSex;
@property (strong, nonatomic) NSString *userNickName;
@property (strong, nonatomic) NSString *userHeight;
@property (strong, nonatomic) NSString *userWeight;

//数据分析图数据记录
@property (assign, nonatomic) int levelCount0;
@property (assign, nonatomic) int levelCount1;
@property (assign, nonatomic) int levelCount2;
@property (assign, nonatomic) int levelCount3;

@property (assign, nonatomic) float distance;

//UI布局

@property (weak, nonatomic) IBOutlet UILabel *calTitle;
@property (weak, nonatomic) IBOutlet UILabel *gongliLable;
@property (weak, nonatomic) IBOutlet UILabel *gongliHourLable;

@property (weak, nonatomic) IBOutlet UILabel *speedTitle;

@property (weak, nonatomic) IBOutlet UILabel *calorieTitle;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitle;
@property (weak, nonatomic) IBOutlet UILabel *timeTitle;

@property (weak, nonatomic) IBOutlet UIImageView *progressBackground;
@property (strong, nonatomic) UILabel * timeLable_two;// 替换timeLable频闪的问题

//档位阻力
@property (strong, nonatomic) IBOutlet UIPickerView *chooseTapPos;
@property (strong, nonatomic) NSArray * pickViewData;

@property (weak, nonatomic) IBOutlet UIImageView *backImage;

//当前运动的阶段：热身，燃脂。放松
@property (weak, nonatomic) IBOutlet UILabel *trainingSection;
//心率范围
@property (weak, nonatomic) IBOutlet UILabel *heartRange;


@end
