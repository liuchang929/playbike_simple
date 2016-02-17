//
//  ModeSelectView.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-4.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModeSelectViewDelegate <NSObject>

-(void)modeDidSelect:(NSInteger)modeNum;

@end

@interface ModeSelectView : UIView
@property (weak, nonatomic) id<ModeSelectViewDelegate> delegate;
@end
