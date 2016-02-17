//
//  ActivityIndicatorView.m
//  SmartBicycle
//
//  Created by Demon on 15-2-28.
//  Copyright (c) 2015年 Demon. All rights reserved.
//

#import "TBActivityIndicatorView.h"

#define kAlpha 0.5f
#define kFontSize 20

@interface TBActivityIndicatorView()

@end

@implementation TBActivityIndicatorView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - 加载框初始化
+ (id)activityIndicatorView
{
    TBActivityIndicatorView *indicatorView = [TBActivityIndicatorView activityIndicatorViewWithString:@"努力加载中"];
    
    return indicatorView;
}

+ (id)activityIndicatorViewWithString:(NSString *)string
{
    /*背部黑框*/
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float xCenter = screenWidth * 0.5f;
    float yCenter = screenHeight * 0.5f;
    float sideLength = screenWidth * 0.2f;
    
    UIView *_backgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sideLength, sideLength)];
    _backgroudView.center = CGPointMake(xCenter, yCenter);
    _backgroudView.backgroundColor = [UIColor blackColor];
    _backgroudView.alpha = kAlpha;
    
    /*菊花框*/
    UIActivityIndicatorView *_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = CGPointMake(_backgroudView.bounds.size.width *0.5, _backgroudView.bounds.size.height *0.5);
    [_activityIndicatorView startAnimating];
    
    /*文字标签*/
    float labelWidth = screenWidth / 6;
    float labelHeight = screenHeight / 6;
    float labelXCenter = _backgroudView.bounds.size.width * 0.5f;
    float labelYCenter = _backgroudView.bounds.size.height * 0.75f;
    
    // 登陆中 or 注销
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth, labelHeight)];
    label.center =CGPointMake(labelXCenter, labelYCenter);
    label.text = string;
    NSLog(@"string = %@",string);
    label.font = [UIFont boldSystemFontOfSize:kFontSize];
    label.textAlignment = NSTextAlignmentCenter; //设置文字位置
    label.adjustsFontSizeToFitWidth = YES;//设置字体大小适应label宽度
    label.textColor = [UIColor whiteColor];
    
    [_backgroudView addSubview:label];
    [_backgroudView addSubview:_activityIndicatorView];
    
    
    return _backgroudView;
    
}

@end
