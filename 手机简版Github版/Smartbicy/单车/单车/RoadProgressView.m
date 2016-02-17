//
//  RoadProgressView.m
//  SmartBicycle
//
//  Created by 王伟志 on 16/1/11.
//  Copyright (c) 2016年 王伟志. All rights reserved.
//

#import "RoadProgressView.h"

@implementation RoadProgressView

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetRGBStrokeColor(context, 234.0/255.0, 151.0/255.0, 0.0, 1.0);//设置颜色
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:234.0/255.0 green:151.0/255.0 blue:0.0 alpha:1.0].CGColor);
    
    CGContextAddRect(context, CGRectMake(0, 0, self.progress, self.bounds.size.height));
    
    //将画图区域填充
    CGContextFillPath(context);
}


@end
