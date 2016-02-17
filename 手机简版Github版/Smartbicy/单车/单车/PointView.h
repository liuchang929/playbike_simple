//
//  PointView.h
//  SmartBicycle
//
//  Created by 王伟志 on 16/1/11.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointView : UIView

//背景
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

//头像
@property (weak, nonatomic) IBOutlet UIImageView *headImage;

+(PointView *)instancePointView;
@end
