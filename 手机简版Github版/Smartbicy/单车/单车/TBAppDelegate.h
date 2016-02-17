//
//  TBAppDelegate.h
//  单车
//
//  Created by comfouriertech on 14-6-4.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@protocol TBAppDelegateDelegate <NSObject>

- (void)respBegin;
- (void)didGetUnion;

@end

@interface TBAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, WXApiDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic)  id<TBAppDelegateDelegate> delegate;
//微信登陆
@property (strong, nonatomic) NSString *wxCode;
@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *openid;

@property (assign, nonatomic) UIBackgroundTaskIdentifier dir_backgroundUpdateTask;

@property (copy) void (^dir_backgroundSessionCompletionHandler)();
@end
