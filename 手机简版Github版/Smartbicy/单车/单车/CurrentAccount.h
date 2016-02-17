//
//  CurrentAccount.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "UserInfo.h"
#import "DirectorViewCell.h"

@interface CurrentAccount : UserInfo

@property (strong, nonatomic) NSString * serverName; // 服务器的名字

@property (assign, nonatomic) BOOL guestAccount;
@property (assign, nonatomic) BOOL setTrainingPlan;      //是否设置训练计划了
@property (assign, nonatomic) BOOL fatFunc;              //训练计划采用的是燃脂功能
@property (assign, nonatomic) BOOL planHeartView;        //是不是训练计划跳转过来的

@property (strong, nonatomic) NSDate * lastSportTime;    //上一次的运动时间
@property (strong, nonatomic) NSString *route3Distance;
@property (strong, nonatomic) NSString *route4Distance;

@property (strong, nonatomic) NSString *unionid;
@property (strong, nonatomic) NSString *headimgurl;

@property (assign, nonatomic) BOOL infoEmpty;

+ (id)sharedCurrentAccount;

//周计划部分
@property (assign, nonatomic) BOOL setWeekPlan;          //是否设置了周计划
@property (assign, nonatomic) BOOL restartWeekPlan;      //是否重置周计划
@property (strong, nonatomic) NSString * aimText;         // 周计划目标
@property (strong, nonatomic) NSString * doneText;        // 完成目标
@property (strong, nonatomic) NSString * lastWeekDone;    // 上周完成里程
@property (strong, nonatomic) NSString * lastWeekPercent; // 上周完成比例
@property (strong, nonatomic) NSString * lastWeekPlanDate;// 最后一次设定周计划的目标

//切换到那个页面
@property (nonatomic,assign) NSUInteger * page;


//指导视频的
@property (nonatomic, strong) DirectorViewCell * dir_downloadCell;
//断点下载管理任务
@property (nonatomic , strong) NSURLSessionDownloadTask * dir_sessionTask;
//全局的下载会话 （断点下载部分）
@property (nonatomic, strong) NSURLSession * dir_session_progress;
@property (copy, nonatomic) NSString * dir_downLoadMoiveId;
@property (assign, nonatomic) BOOL dir_isLoading;             //指导视频正在缓存
@property (assign, nonatomic) BOOL road_isLoading;            //街景正在缓存
@property (assign, nonatomic) NSUInteger  dir_downBtnTag;     //正在下载的cell按钮的tag
//@property (assign, nonatomic) BOOL dir_loadingDone;          //下载完成

@property (nonatomic, copy) NSString * dirMoive; //指导视频的名字
@property (nonatomic, copy) NSString * roadMoive;//街景视频的名字

@end
