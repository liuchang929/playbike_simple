//
//  DirectorViewCell.h
//  SmartBicycle
//
//  Created by 王伟志 on 15/12/22.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DirectorViewCellDelegate <NSObject>

-(void)down:(UIButton *)sender;

@end

@interface DirectorViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *Image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *video_desrc1;
//@property (weak, nonatomic) IBOutlet UILabel *Video_desrc2;

//下载按钮
@property (weak, nonatomic) IBOutlet UIButton *downBtn;

//下载量
@property (weak, nonatomic) IBOutlet UILabel *persent;

//下载状态
@property (weak, nonatomic) IBOutlet UILabel *downState;

@property (nonatomic, strong) id<DirectorViewCellDelegate> delegate;


- (IBAction)down:(UIButton *)sender;


@end
