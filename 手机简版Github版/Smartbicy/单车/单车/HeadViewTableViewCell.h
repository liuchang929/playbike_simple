//
//  HeadViewTableViewCell.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeadViewTableViewCellDelegate <NSObject>

-(void)jumpRank;

@end

@interface HeadViewTableViewCell : UITableViewCell

//总卡路里
@property (weak, nonatomic) IBOutlet UILabel *totalCal;
//累计时间
@property (weak, nonatomic) IBOutlet UILabel *time;

//今天的卡路里
@property (weak, nonatomic) IBOutlet UILabel *todayCal;

//签到
@property (weak, nonatomic) IBOutlet UILabel *sign;
//排名
@property (weak, nonatomic) IBOutlet UILabel *rank;

@property (nonatomic, strong) id<HeadViewTableViewCellDelegate> delegate;

@end
