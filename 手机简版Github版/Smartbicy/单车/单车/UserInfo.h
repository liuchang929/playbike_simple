//
//  UserInfo.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject <NSCoding>
@property (strong, nonatomic) NSString *userBirthday;
@property (strong, nonatomic) NSString *userSex;
@property (strong, nonatomic) NSString *userNickName;
@property (strong, nonatomic) NSString *userHeight;
@property (strong, nonatomic) NSString *userWeight;
@property (strong, nonatomic) NSString *userHeadID;
@property (strong, nonatomic) NSString *userHRMax;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *routeSelected;
@property (strong, nonatomic) NSString *userCity;
@property (strong, nonatomic) NSString *userDeclaration;

@property (assign, nonatomic) int levelCount0;
@property (assign, nonatomic) int levelCount1;
@property (assign, nonatomic) int levelCount2;
@property (assign, nonatomic) int levelCount3; //心率数据，分别占有的比例

@property (assign, nonatomic) NSString * isWeChat;
@property (strong, nonatomic) NSString *weChatAccount;
@property (strong, nonatomic) NSString *weChatImagePath;


@property (assign, nonatomic) float distance;
@property (assign, nonatomic) float calSum;
@property (nonatomic,strong) NSString * sportTime;//运动时间

- (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name;
- (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name weChatAccount:(NSString *)weChatAccount weChatImagePath:(NSString *)weChatImagePath;
+ (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name;
+ (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name weChatAccount:(NSString *)weChatAccount weChatImagePath:(NSString *)weChatImagePath;

@end
