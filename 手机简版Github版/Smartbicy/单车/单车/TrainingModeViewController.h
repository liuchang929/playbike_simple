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
#import "WeekPlanView.h"

@interface TrainingModeViewController : UIViewController <CPTPlotDataSource, CPTAxisDelegate, UINavigationControllerDelegate, WXApiDelegate, UIActionSheetDelegate,UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

- (IBAction)startOrEnd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *startOrEndButton;


- (IBAction)shareWithPhoto:(UIButton *)sender;

//音乐部分


- (IBAction)pauseOrStart:(id)sender;
- (IBAction)skipToNext:(id)sender;

@property (weak, nonatomic) UIButton * localMusic;
@property (weak, nonatomic) UIButton * systemMusic;
@property (strong, nonatomic) AVAudioPlayer * player;
@property (strong, nonatomic) NSArray * musicItem; //存放本地音乐的数组

@property (strong, nonatomic)  UIButton *playList;
@property (strong, nonatomic)  UIButton *beforeBtn;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

//底下三个按键
- (IBAction)infoBtn:(id)sender;

- (IBAction)historyCheckButton:(UIButton *)sender;
- (IBAction)weekPlanButton:(id)sender;
- (IBAction)trainingPlanButton:(id)sender;

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


@property (assign, nonatomic) float distance;



//显示单次计划的view
@property (strong, nonatomic) NSMutableDictionary * weekPlanDic;//存放周计划的数据
@property (strong, nonatomic) UITextField * aimText;
@property (strong, nonatomic) NSArray * onePlanData;
@property (strong, nonatomic) IBOutlet UIPickerView * tenNum;
@property (strong, nonatomic) IBOutlet UIPickerView * Num;

//档位阻力
@property (strong, nonatomic) IBOutlet UIPickerView *chooseTapPos;
@property (strong, nonatomic) NSArray * pickViewData;
@property (weak, nonatomic) IBOutlet UITextField *posText;

@property (weak, nonatomic) IBOutlet UIButton *historyBtn;
@property (weak, nonatomic) IBOutlet UIButton *weekPlanBtn;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;

//按钮周边的图片
@property (weak, nonatomic) IBOutlet UIImageView *roundImageView;

@end
