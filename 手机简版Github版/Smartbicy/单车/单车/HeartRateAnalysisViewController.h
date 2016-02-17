//
//  HeartRateAnalysisViewController.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-27.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface HeartRateAnalysisViewController : UIViewController
- (IBAction)back:(id)sender;
- (IBAction)share:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *TextLable;

@property (weak, nonatomic) IBOutlet UILabel *hotDog;

//UI控件
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nikeName;
@property (weak, nonatomic) IBOutlet UILabel *nowTime;
@property (weak, nonatomic) IBOutlet UILabel *cal;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *sportTime;


@end
