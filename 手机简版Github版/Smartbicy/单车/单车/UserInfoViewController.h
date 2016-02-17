//
//  UserInfoViewController.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-8.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHRmaxDefault   190.0

@protocol UserInfoViewControllerDelegate <NSObject>

- (void)userInfoDidSavedWithString:(NSString *)string;

@end

@interface UserInfoViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nickNameText;
@property (weak, nonatomic) IBOutlet UITextField *heightText;
@property (weak, nonatomic) IBOutlet UITextField *weightText;
@property (weak, nonatomic) IBOutlet UITextField *sexText;
@property (weak, nonatomic) IBOutlet UITextField *birthdayText;
@property (weak, nonatomic) IBOutlet UITextField *placeText;
@property (weak, nonatomic) IBOutlet UITextField *headText;
//@property (weak, nonatomic) IBOutlet UITextView *signNameText;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UITextField *signNameText;

//用户数据
//@property (strong, nonatomic) NSDictionary *infoDictionary;
@property (strong, nonatomic) NSString *userBirthday;
@property (strong, nonatomic) NSString *userSex;
@property (strong, nonatomic) NSString *userNickName;
@property (strong, nonatomic) NSString *userHeight;
@property (strong, nonatomic) NSString *userWeight;
@property (strong, nonatomic) NSString *userHeadID;
@property (strong, nonatomic) NSString *userHRMax;
@property (strong, nonatomic) NSString *userCity;
@property (strong, nonatomic) NSString *userDeclaration;
@property (strong, nonatomic) NSString *nickName;

- (IBAction)backForModel:(id)sender;


@property (weak, nonatomic) id<UserInfoViewControllerDelegate> delegate;

- (IBAction)save:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *BMI;


@end
