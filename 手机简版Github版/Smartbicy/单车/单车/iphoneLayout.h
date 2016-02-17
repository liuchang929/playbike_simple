//
//  iphoneLayout.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/4/29.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iphoneLayout : NSObject

+(iphoneLayout*)shareIphoneLayout;

//iphone设备布局
-(void) Time:(UILabel *) _timeLable_ timeT:(UILabel *)_timeTitle_ calT:(UILabel *) _calTitle_ distanceT:(UILabel *) _distanceTitle_ speedT:(UILabel *)_speedTitle_ cal:(UILabel *)calLable distance:(UILabel *)distance speed:(UILabel *)speed me:(UIButton *)_me_ data:(UIButton *)_data_ weekplan:(UIButton *)_weekplan_ view:(UIView *) view;

//创建音乐按钮
-(void) craeteMusicPlay:(UIButton *)playBtn before:(UIButton*)beforeBtn next:(UIButton*) nextBtn viewHeight:(float) height view:(UIView *) view;

//单次训练计划设置
-(void)GuestAccount:(BOOL) _guestAccount  Ten:(UIPickerView*) _tenNum num:(UIPickerView *) _Num closeBtn:(UIButton *) close dictionary:(NSDictionary*) dictionary;

//档位阻力视图布局
-(void) tapPos:(UIImageView*)tapImage chooseTapPos:(UIPickerView *) _chooseTapPos;
@end
