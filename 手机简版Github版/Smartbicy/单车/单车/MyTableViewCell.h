//
//  MyTableViewCell.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *Image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *video_desrc1;
//@property (weak, nonatomic) IBOutlet UILabel *Video_desrc2;

@property (weak, nonatomic) IBOutlet UILabel *downState;


@end
