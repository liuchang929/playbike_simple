//
//  AnalysisView.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-27.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "AnalysisView.h"
#import "CurrentAccount.h"

#define PROGRESS_LINE_WIDTH (self.bounds.size.width * 10 / 890.0f)
#define kPathNum 4
#define kRadius (self.bounds.size.width * 138 / 890.0f)
#define kLineWidth (self.bounds.size.width * 50 / 890.0f)
#define kArcCenterX (self.bounds.size.width / 2)
#define kArcCenterY (self.bounds.size.height / 2)
#define kRadiusForAnnotationPoint (self.bounds.size.width * 185 / 890.0f)
#define kLengthForIndicateLine (self.bounds.size.width * 250 / 890.0f)
#define kBackImageWidth (kRadiusForAnnotationPoint * 2)
#define kBackImageHeight (kRadiusForAnnotationPoint * 2)



@implementation AnalysisView
{
    UIImageView *_blueAnnotationPointView;
    UIImageView *_greenAnnotationPointView;
    UIImageView *_yellowAnnotationPointView;
    UIImageView *_redAnnotationPointView;
    
    //颜料盒
    NSArray *_colorArray;
    NSArray *_nameArray;
    NSArray *_levelPercentArray;
}

- (void)drawRect:(CGRect)rect {
    
    
    CurrentAccount *currenAccount = [CurrentAccount sharedCurrentAccount];
    int levelCount0 = currenAccount.levelCount0;
    int levelCount1 = currenAccount.levelCount1;
    int levelCount2 = currenAccount.levelCount2;
    int levelCount3 = currenAccount.levelCount3;

    //调试的时候使用
//    int levelCount0 = 20;
//    int levelCount1 = 20;
//    int levelCount2 = 20;
//    int levelCount3 = 20;
    
    //判断有无心率
    if(levelCount0 == 0 && levelCount1 == 0 && levelCount2 == 0 && levelCount3 == 0 )
    {
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kBackImageWidth, kBackImageHeight)];
        UIImage *back = [UIImage imageNamed:@"Distribution_bg"];
        [backView setImage:back];
        backView.center = CGPointMake(kArcCenterX, kArcCenterY);
        [self addSubview:backView];
    }
    else
    {
        [self drawAnalysisViewWithCount0:levelCount0 andCount1:levelCount1 andCount2:levelCount2 andCount3:levelCount3];
    }
}

- (void) drawAnalysisViewWithCount0:(int)levelCount0 andCount1:(int)levelCount1 andCount2:(int)levelCount2 andCount3:(int)levelCount3
{
    
    int sumCounts;
    float levelPercent0, levelDegree0;
    float levelPercent1, levelDegree1;
    float levelPercent2, levelDegree2;
    float levelPercent3;
    
    sumCounts = levelCount0 + levelCount1 + levelCount2 + levelCount3;
    //NSLog(@"sumCounts --> %d",sumCounts);
    levelPercent0 = (float)levelCount0 / sumCounts;
    levelPercent1 = (float)levelCount1 / sumCounts;
    levelPercent2 = (float)levelCount2 / sumCounts;
    levelPercent3 = (float)levelCount3 / sumCounts;
//    NSLog(@"levelPercent0 --> %f",levelPercent0);
//    NSLog(@"levelPercent1 --> %f",levelPercent1);
//    NSLog(@"levelPercent2 --> %f",levelPercent2);
//    NSLog(@"levelPercent3 --> %f",levelPercent3);
    
    levelDegree0 = levelPercent0 * 2 * M_PI;
    levelDegree1 = levelPercent1 * 2 * M_PI + levelDegree0;
    levelDegree2 = levelPercent2 * 2 * M_PI + levelDegree1;
    float levelDegree3 = 2 * M_PI - (levelDegree0 + levelDegree1 + levelDegree2) + levelDegree2;
    
    NSArray *levelDegreeArray = @[
                                  [NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:levelDegree0],
                                  [NSNumber numberWithFloat:levelDegree1],
                                  [NSNumber numberWithFloat:levelDegree2],
                                  [NSNumber numberWithFloat:M_PI * 2]
                                  ];
   
    _levelPercentArray = @[
                           [NSNumber numberWithFloat:levelPercent0],
                           [NSNumber numberWithFloat:levelPercent1],
                           [NSNumber numberWithFloat:levelPercent2],
                           [NSNumber numberWithFloat:levelPercent3],
                           ];
    _nameArray = @[@"热身",@"燃脂",@"提升",@"极限"];
    
    //颜料盒。蓝、绿、黄、红
    _colorArray = @[
                            [UIColor colorWithRed:25.0/255.0 green:147.0/255.0 blue:211.0/255.0 alpha:1.0],
                            [UIColor colorWithRed:23.0/255.0 green:189.0/255.0 blue:105.0/255.0 alpha:1.0],
                            [UIColor colorWithRed:241.0/255.0 green:164.0/255.0 blue:29.0/255.0 alpha:1.0],
                            [UIColor colorWithRed:242.0/255.0 green:58.0/255.0 blue:48.0/255.0 alpha:1.0]
                            ];

    //制作路径
    //路径数组，存放制作好的路径
    NSMutableArray *mutablePathArray = [NSMutableArray array];
    for (NSInteger i = 0; i < kPathNum ; i++) {
        CGMutablePathRef mutablePath = CGPathCreateMutable();
        CGPathAddArc(mutablePath, 0, kArcCenterX, kArcCenterY, kRadius,  [levelDegreeArray[i] floatValue], [levelDegreeArray[i+1] floatValue], NO);
        UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:mutablePath];
        [mutablePathArray addObject:path];
        CGPathRelease(mutablePath);
    }
    
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //绘制路径
    for (NSInteger i = 0; i < kPathNum; i++) {
        UIBezierPath *path = mutablePathArray[i];
        CGContextAddPath(context, path.CGPath);
        CGContextSetLineWidth(context, kLineWidth);
        [(UIColor *)_colorArray[i] set];
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //绘制阴影层
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.bounds = CGRectMake(0, 0, kRadius * 2 -20 , kRadius * 2 - 20);
    shadowLayer.position = CGPointMake(kArcCenterX, kArcCenterY);
    shadowLayer.cornerRadius = kRadius - 10;
    shadowLayer.backgroundColor = [UIColor whiteColor].CGColor;
    shadowLayer.opacity = 0.5;
    [self.layer addSublayer:shadowLayer];
    
    
    //绘制标注图标（圆点）
    [self initAnnotationPointWithLevelDegree0:levelDegree0 LevelDegree1:levelDegree1 LevelDegree2:levelDegree2 LevelDegree3:levelDegree3 WithPercent0:levelPercent0 Percent1:levelPercent1 WithPercent2:levelPercent2 WithPercent3:levelPercent3];
    
}

- (void)initAnnotationPointWithLevelDegree0:(float)levelDegree0 LevelDegree1:(float)levelDegree1 LevelDegree2:(float)levelDegree2 LevelDegree3:(float)levelDegree3 WithPercent0:(float)levelPercent0 Percent1:(float)levelPercent1 WithPercent2:(float)levelPercent2 WithPercent3:(float)levelPercent3
{
    //蓝、绿、黄、红
    if (levelPercent0 > 0.0001) {
        //如果有数据，基本是有热身区的数据，在此处，初始化背景
        //初始化背景
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kBackImageWidth, kBackImageHeight)];
        UIImage *back = [UIImage imageNamed:@"Distribution_bg"];
        [backView setImage:back];
        backView.center = CGPointMake(kArcCenterX, kArcCenterY);
        [self addSubview:backView];

        [self drawAnnotationPoint:_blueAnnotationPointView WithName:@"Point_blue.png"WithAngle:levelDegree0 / 2 WithPercent:levelPercent0 WithTag:0];
    }
    if (levelPercent1 > 0.0001) {
        [self drawAnnotationPoint:_greenAnnotationPointView WithName:@"Point_green.png"WithAngle:(levelDegree0 + levelDegree1) / 2 WithPercent:levelPercent1 WithTag:1];
    }
    if (levelPercent2 > 0.0001) {
        [self drawAnnotationPoint:_yellowAnnotationPointView WithName:@"Point_yellow.png"WithAngle:(levelDegree1 + levelDegree2) / 2 WithPercent:levelPercent2 WithTag:2];
    }
    if (levelPercent3 > 0.0001) {
        [self drawAnnotationPoint:_redAnnotationPointView WithName:@"Point_red.png"WithAngle:(levelDegree2 + M_PI * 2) / 2 WithPercent:levelPercent3 WithTag:3];
    }
}

- (void)drawAnnotationPoint:(UIImageView *)annotationView WithName:(NSString *)pointName WithAngle:(float)angle WithPercent:(float)levelPercent WithTag:(NSInteger)tag
{
    //初始化圆点
    annotationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    annotationView.center = CGPointMake(self.bounds.size.width - kRadiusForAnnotationPoint, kArcCenterY);
    UIImage *colorAnnotationPoint = [UIImage imageNamed:pointName];
    annotationView.image = colorAnnotationPoint;
    
    [self addSubview:annotationView];
    
    //旋转圆点
    [self rotateAngle:angle ForAnnotationImageView:annotationView];
    
    //绘制指示线
    [self drawIndicateLineWithAnnotationView:annotationView WithLevelPercent:levelPercent WithTag:tag];
    
    
}

#pragma mark 旋转图标点的角度
- (void)rotateAngle:(float)angle ForAnnotationImageView:(UIImageView *)annotationImageView
{
    float centerX, centerY;
    centerX = kArcCenterX + kRadiusForAnnotationPoint * cosf(angle);
    centerY = kArcCenterY + kRadiusForAnnotationPoint * sinf(angle);
    annotationImageView.center = CGPointMake(centerX, centerY);
    
}

#pragma mark 绘制指示线
- (void)drawIndicateLineWithAnnotationView:(UIImageView *)annotationView WithLevelPercent:(float)levelPercent WithTag:(NSInteger)tag
{
    CGPoint pointBounds = [annotationView convertPoint:annotationView.bounds.origin toView:self];
    
    //获取的pointBounds为rect的左上角点，需要获取rect中心点位置
    CGPoint pointCenter;
    pointCenter.x = pointBounds.x + 12;
    pointCenter.y = pointBounds.y + 12;
    
    //绘制指示线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    //根据圆点位置，判断指示线方向（左、右）
    //在大圆圆心右侧，指示线方向为右，反之为左
    if (pointCenter.x > self.bounds.size.width / 2) {
        [self rightPercentLabelWithPointCenter:pointCenter WithPath:path WithPercent:levelPercent WithTag:tag];
    }else{
        [self leftPercentLabelWithPointCenter:pointCenter WithPath:path WithPercent:levelPercent WithTag:tag];
    }
    
    CGContextAddPath(context, path);
    
    //设置线属性
    CGContextSetLineWidth(context, 2);
    [[UIColor grayColor] set];
    CGFloat lengths[1] = {8.0};
    CGContextSetLineDash(context, 0, lengths, 1);
    
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

- (void)rightPercentLabelWithPointCenter:(CGPoint)pointCenter WithPath:(CGMutablePathRef)path WithPercent:(float)levelPercent WithTag:(NSInteger)tag
{
    CGPathMoveToPoint(path, NULL, pointCenter.x + 15, pointCenter.y);
    CGPathAddLineToPoint(path, NULL, pointCenter.x + kLengthForIndicateLine, pointCenter.y);
    
    float percentLabelX = pointCenter.x + kLengthForIndicateLine/ 2;
    float percentLabelY = pointCenter.y + 10;
    [self percentLabelAndTextLabelWithX:percentLabelX WithY:percentLabelY WithTag:tag];
    
}

- (void)leftPercentLabelWithPointCenter:(CGPoint)pointCenter WithPath:(CGMutablePathRef)path WithPercent:(float)levelPercent WithTag:(NSInteger)tag
{
    CGPathMoveToPoint(path, NULL, pointCenter.x - 15, pointCenter.y);
    CGPathAddLineToPoint(path, NULL, pointCenter.x - kLengthForIndicateLine, pointCenter.y);
    
    float percentLabelX = pointCenter.x - kLengthForIndicateLine;
    float percentLabelY = pointCenter.y + 10;
    
    [self percentLabelAndTextLabelWithX:percentLabelX WithY:percentLabelY WithTag:tag];
    
}

- (void)percentLabelAndTextLabelWithX:(float)percentLabelX WithY:(float)percentLabelY WithTag:(NSInteger)tag
{
    UILabel *percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(percentLabelX, percentLabelY, 200, 30)];
    percentLabel.text = [NSString stringWithFormat:@"%.2f%%",[_levelPercentArray[tag] floatValue] * 100];
    percentLabel.textColor = _colorArray[tag];
    
    //根据不同设备设置字体大小
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        percentLabel.font = [UIFont fontWithName:@"Courier-Oblique" size:30];
    }else{
        percentLabel.font = [UIFont fontWithName:@"Courier-Oblique" size:40];
    }
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(percentLabelX +40, percentLabelY - 50, 200, 30)];
    textLabel.text = _nameArray[tag];
    textLabel.font = [UIFont fontWithName:@"Georgia" size:30];
    
    [self addSubview:textLabel];
    [self addSubview:percentLabel];
    
}

@end
