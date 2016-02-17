//
//  TBAppDelegate.m
//  单车
//
//  Created by comfouriertech on 14-6-4.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "TBAppDelegate.h"
#import "CurrentAccount.h"
#import <AFNetworking.h>
#import "WXAPP.h"

#import "MobClick.h"
#import "UMCheckUpdate.h"

@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //应用统计
    //[MobClick setLogEnabled:YES];
    //[MobClick startWithAppkey:@"56ab12ae67e58eebf60008dd" reportPolicy:BATCH channelId:@"Official"];
    [MobClick startWithAppkey:@"569eead9e0f55ac5be001479"];
    
    //更新
    [UMCheckUpdate checkUpdate:@"发现最新版本，赶紧体验！" cancelButtonTitle:@"考虑一下" otherButtonTitles:@"马上更新" appkey:@"56ab12ae67e58eebf60008dd" channel:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //初始化导航栏背景(全局)
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"工具栏.png"] forBarMetrics:4];
    [[UINavigationBar appearance] setTranslucent:NO]; //关闭导航条半透明
    //设置字体
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"FZLTZHUNHK--GBK1-0" size:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [WXApi registerApp:WXAPPID];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 分享
#pragma mark WX
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}


#pragma mark - 微信登陆

-(void)onResp:(BaseResp *)resp
{
    /*
     返回值	说明
     ErrCode	ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code	用户换取access_token的code，仅在ErrCode为0时有效
     state	第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang	微信客户端当前语言
     country	微信用户当前国家信息
     */
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
    }else{
        SendAuthResp *aresp = (SendAuthResp *)resp;
        //NSLog(@"aresp --> %d", aresp.errCode);
        if (aresp.errCode == 0) {
            _wxCode = aresp.code;
            //NSDictionary *dic = @{@"code":_wxCode};
            //通过代理，弹出菊花框
            [self.delegate respBegin];
            
            [self getAccess_token];
        }
    }

}

-(void)getAccess_token
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAPPID,WXAPP_SECRET,self.wxCode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                //NSLog(@"dic2 --> %@",dic);
                self.access_token = [dic objectForKey:@"access_token"];
                self.openid = [dic objectForKey:@"openid"];
                //NSLog(@"access_token --> %@", self.access_token);
                //NSLog(@"openid --> %@", self.openid);
                
                [self getUserInfo];
                
            }
        });
    });
}

-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token,self.openid];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                //NSLog(@"dic --> %@", dic);
                
                //[self initActivityIndicatorViewWithBackgroud];
                
                 CurrentAccount *currentAccount = [CurrentAccount sharedCurrentAccount];
                 currentAccount.userNickName = [dic objectForKey:@"nickname"];
                 currentAccount.headimgurl = [dic objectForKey:@"headimgurl"];
                NSString *weChatSex = [dic objectForKey:@"sex"];
                if ([weChatSex integerValue] == 1) {
                    //男
                    currentAccount.userSex = @"male";
                }else if([weChatSex integerValue] == 2){
                    //nv
                    currentAccount.userSex = @"female";
                }else{
                    currentAccount.userSex = nil;
                }
                 //currentAccount.userSex = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"sex"] integerValue] - 1];
                currentAccount.unionid = [dic objectForKey:@"unionid"];
                [self.delegate didGetUnion];
            }
        });
        
    });
}
@end
