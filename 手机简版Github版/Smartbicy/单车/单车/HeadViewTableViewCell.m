//
//  HeadViewTableViewCell.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "HeadViewTableViewCell.h"
#import "MobClick.h"

@implementation HeadViewTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cheakRank:(id)sender {
    NSLog(@"查看排名");
    [self.delegate jumpRank];
    
    //友盟数据统计:排名
    [MobClick event:@"rank_icon"];
}


@end
