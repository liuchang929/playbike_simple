//
//  myAccount.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-25.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myAccount : UIViewController
- (IBAction)logout:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *myAccountLabel;
@property (weak, nonatomic) IBOutlet UIButton *myAccountButton;
@property (weak, nonatomic) IBOutlet UIImageView *headPhoto;
- (IBAction)back:(UIBarButtonItem *)sender;

@end
