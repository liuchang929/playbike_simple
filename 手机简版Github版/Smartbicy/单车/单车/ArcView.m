//
//  ArcView.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-25.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "ArcView.h"

#define kLineWidth     (self.bounds.size.width * 56 / 300.0f)
#define kXArcViewRadius ([UIScreen mainScreen].bounds.size.width * 90.0f / 1024.0f)


@implementation ArcView


- (void)drawRect:(CGRect)rect {
    
    float degreeEnd = self.degreeEnd;
    [self drawArcWithDegreeEnd:degreeEnd];
    
}

- (void) drawArcWithDegreeEnd:(float)degreeEnd
{
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //设置渐变属性
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[8] = {
                                                1.0, 1.0, 0.0, 1.0,
                                                1.0, 0.0, 0.0, 1.0
                                                };
    CGFloat locations[2] = {
                                            0.0, 1.0
                                        };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    
    //设置上下文属性
    CGContextSetLineWidth(context, kLineWidth);
    
    //绘制圆弧
    CGContextAddArc(context, self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f, kXArcViewRadius, - (M_PI_4 + M_PI), 2 * M_PI * (degreeEnd / 360.0f), NO);
    CGContextReplacePathWithStrokedPath(context);
    
    //裁剪路径区域
    CGContextClip(context);
    
    //渐变区域
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(160.0, 0.0), kCGGradientDrawsAfterEndLocation);
    
    //释放
    CGGradientRelease(gradient);
    
}


@end
