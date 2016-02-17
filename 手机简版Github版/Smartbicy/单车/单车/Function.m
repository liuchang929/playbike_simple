//
//  Function.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/28.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "Function.h"
#import <AVFoundation/AVFoundation.h>
#import "WXApi.h"

@implementation Function

static Function * shareFunction;

+(Function*)shareFunction
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareFunction = [[Function alloc] init];
    });
    
    return shareFunction;
}

#pragma mark 播放语音
-(void)speak:(NSString *)string
{
    AVSpeechSynthesizer * av = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance * utterance = [[AVSpeechUtterance alloc] initWithString:string];
    AVSpeechSynthesisVoice * voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"];
    utterance.voice = voice;
    utterance.rate = 0.15;//播放速度
    [av speakUtterance:utterance];
}
//提醒距离目标还有多远
-(void)remind:(int) aimDistance distance:(float) distance
{
    if(aimDistance != 0)
    {
        if ( aimDistance - distance < 9.999 && aimDistance - distance >9.993) {
            [[Function shareFunction] speak:@"离目标完成还有10公里路程，坚持哦！"];
        }
        else if (aimDistance - distance < 4.999 && aimDistance - distance > 4.993) {
            [[Function shareFunction] speak:@"还剩下5公里路程就完成今天的目标啦。"];
        }
        else if (aimDistance - distance < 1.999 && aimDistance - distance > 1.993) {
            [[Function shareFunction] speak:@"今天很棒，还有最后2公里路程。"];
        }
        else if (aimDistance - distance < 0.009 && aimDistance - distance > 0.003 ) {
            [[Function shareFunction] speak:@"今天的目标已完成，要适当休息哦！"];
        }
        else if (distance - aimDistance < 4.999 && distance - aimDistance > 4.993) {
            [[Function shareFunction] speak:@"超越目标5公里，好棒。但是要注意劳逸结合哦！"];
        }
        else if (distance - aimDistance < 9.999 && distance - aimDistance > 9.993) {
            [[Function shareFunction] speak:@"请勿过量运动，专家表示，运动适量更有益于身体健康哦！"];
        }
    }
}

#pragma mark 截图
- (UIImage *)captureScreen
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void) sendImageContentWithImage:(UIImage *)image InScene:(int)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"152.png"]];
    
    WXImageObject *ext = [WXImageObject object];
    /*
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res5thumb" ofType:@"png"];
     NSLog(@"filepath :%@",filePath);
     ext.imageData = [NSData dataWithContentsOfFile:filePath];
     */
    
    //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    //UIImage* image = [UIImage imageWithData:ext.imageData];
    
    ext.imageData = UIImagePNGRepresentation(image);
    
    //    UIImage* image = [UIImage imageNamed:@"res5thumb.png"];
    //    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    //message.title = @"title";
    //message.description = @"description";
    
    [WXApi sendReq:req];
}

#pragma mark 卡路里的met值
-(float)unAccountTapPos:(NSInteger)tapPos speed:(NSString *) speed
{
    float met;
    switch (tapPos) {
        case 0:
        case 1:
            if ([speed intValue] >= 20) {
                met = 12.5;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 10.5;
            }
            else
            {
                met = 7.0;
            }
            break;
        case 2:
        case 3:
            if ([speed intValue] >= 20) {
                met = 10.5;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 7.0;
            }
            else
            {
                met = 5.5;
            }
            break;
        case 4:
        case 5:
            if ([speed intValue] >= 20) {
                met = 7.0;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 5.5;
            }
            else
            {
                met = 3.0;
            }
            break;
        case 6:
        case 7:
            if ([speed intValue] >= 20) {
                met = 5.5;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 3.0;
            }
            else
            {
                met = 3.0;
            }
            break;
        default:
            break;
    }
    return met;
}

-(float)accountTapPos:(NSInteger)tapPos speed:(NSString *) speed
{
    float met;
    switch (tapPos) {
        case 0:
        case 1:
            if ([speed intValue] >= 20) {
                met = 12.5;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 10.5;
            }
            else
            {
                met = 7.0;
            }
            break;
        case 2:
        case 3:
            if ([speed intValue] >= 20) {
                met = 10.5;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 7.0;
            }
            else
            {
                met = 5.5;
            }
            break;
        case 4:
        case 5:
            if ([speed intValue] >= 20) {
                met = 7.0;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 5.5;
            }
            else
            {
                met = 3.0;
            }
            break;
        case 6:
        case 7:
            if ([speed intValue] >= 20) {
                met = 5.5;
            }
            else if ([speed intValue] > 10 && [speed intValue] <20)
            {
                met = 3.0;
            }
            else
            {
                met = 3.0;
            }
            break;
        default:
            break;
    }
    return met;
}

#pragma mark -获取运动起始时间
- (NSString *)saveStartTime
{
    NSDateFormatter *dateFormtter=[[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormtter stringFromDate:[NSDate date]];
    //NSLog(@"%@",dateString);
    return dateString;
}




@end
