//
//  LeftNavigationController.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-15.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftNavigationController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *headImage;
- (IBAction)headIMageButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *nickName;//user name



@property (weak, nonatomic) IBOutlet UIButton *historyCheckButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *settingButtonOutlet; //setting selfinfomation
@property (weak, nonatomic) IBOutlet UIButton *weekPlan;
@property (weak, nonatomic) IBOutlet UIButton *trainingPlan;



@property (weak, nonatomic) IBOutlet UIImageView *personalSettingIcon;
@property (weak, nonatomic) IBOutlet UIImageView *historyCheckIcon;
@property (weak, nonatomic) IBOutlet UIImageView *separation1;
@property (weak, nonatomic) IBOutlet UIImageView *separation2;
@property (weak, nonatomic) IBOutlet UIImageView *separation3;


@end
