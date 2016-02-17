//
//  Function.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/28.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Function : NSObject

+(Function *) shareFunction;

//语音提醒
-(void)speak:(NSString *)string;
-(void)remind:(int) aimDistance distance:(float) distance;

//截图分享
- (UIImage *)captureScreen;
- (void) sendImageContentWithImage:(UIImage *)image InScene:(int)scene;

//获取计算卡路里的met值
-(float)unAccountTapPos:(NSInteger)tapPos speed:(NSString *) speed;
-(float)accountTapPos:(NSInteger)tapPos speed:(NSString *) speed;

//获取运动开始时间
- (NSString *)saveStartTime;




@end
