//
//  UserInfo.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo


- (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name
{
    self = [super init];
    if (self) {
        self.userBirthday = birthday;
        self.userSex = sex;
        self.userNickName = nickName;
        self.userHeight = height;
        self.userWeight = weight;
        self.userHeadID = headID;
        self.userHRMax = HRMax;
        self.userName = name;
    }
    
    return self;
}


- (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name weChatAccount:(NSString *)weChatAccount weChatImagePath:(NSString *)weChatImagePath
{
    self = [super init];
    if (self) {
        self.userBirthday = birthday;
        self.userSex = sex;
        self.userNickName = nickName;
        self.userHeight = height;
        self.userWeight = weight;
        self.userHeadID = headID;
        self.userHRMax = HRMax;
        self.userName = name;
        self.weChatAccount = weChatAccount;
        self.weChatImagePath = weChatImagePath;
    }
    
    return self;
}


+ (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name
{
    UserInfo *userInfo = [[UserInfo alloc] initWithBirthday:birthday Sex:sex NickName:nickName Height:height Weight:weight HeadID:headID HRMax:HRMax Name:name];
    return userInfo;
}

+ (id)initWithBirthday:(NSString *)birthday Sex:(NSString *)sex NickName:(NSString *)nickName Height:(NSString *)height Weight:(NSString *)weight HeadID:(NSString *)headID HRMax:(NSString *)HRMax Name:(NSString *)name weChatAccount:(NSString *)weChatAccount weChatImagePath:(NSString *)weChatImagePath

{
    UserInfo *userInfo = [[UserInfo alloc] initWithBirthday:birthday Sex:sex NickName:nickName Height:height Weight:weight HeadID:headID HRMax:HRMax Name:name weChatAccount:weChatAccount weChatImagePath:weChatImagePath];
    return userInfo;
}

#pragma mark - 编解码
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userBirthday forKey:@"birthday"];
    [aCoder encodeObject:self.userSex forKey:@"sex"];
    [aCoder encodeObject:self.userNickName forKey:@"nickName"];
    [aCoder encodeObject:self.userHeight forKey:@"height"];
    [aCoder encodeObject:self.userWeight forKey:@"weight"];
    [aCoder encodeObject:self.userHeadID forKey:@"headID"];
    [aCoder encodeObject:self.userHRMax forKey:@"HRMax"];
    [aCoder encodeObject:self.userName forKey:@"name"];
    [aCoder encodeObject:self.userPassword forKey:@"password"];
    [aCoder encodeObject:self.weChatAccount forKey:@"weChatAccount"];
    [aCoder encodeObject:self.weChatImagePath forKey:@"weChatImagePath"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setUserBirthday:[aDecoder decodeObjectForKey:@"birthday"]];
        [self setUserSex:[aDecoder decodeObjectForKey:@"sex"]];
        [self setUserNickName:[aDecoder decodeObjectForKey:@"nickName"]];
        [self setUserHeight:[aDecoder decodeObjectForKey:@"height"]];
        [self setUserWeight:[aDecoder decodeObjectForKey:@"weight"]];
        [self setUserHeadID:[aDecoder decodeObjectForKey:@"headID"]];
        [self setUserHRMax:[aDecoder decodeObjectForKey:@"HRMax"]];
        [self setUserName:[aDecoder decodeObjectForKey:@"name"]];
        [self setUserPassword:[aDecoder decodeObjectForKey:@"password"]];
        [self setWeChatAccount:[aDecoder decodeObjectForKey:@"weChatAccount"]];
        [self setWeChatImagePath:[aDecoder decodeObjectForKey:@"weChatImagePath"]];
    }
    
    return self;
}

@end