//
//  PointView.m
//  SmartBicycle
//
//  Created by 王伟志 on 16/1/11.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import "PointView.h"

@implementation PointView

+(PointView *)instancePointView
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"PointView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

@end
