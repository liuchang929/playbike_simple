//
//  loadMoreView.h
//  团购
//
//  Created by 王伟志 on 15/9/24.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol loadMoreViewDelegate <NSObject>

-(void)loadMore:(UIButton *) button;

@end

@interface loadMoreView : UIView

@property (weak, nonatomic) IBOutlet UIButton *action;

@property (nonatomic, strong) id<loadMoreViewDelegate> delegate;

@end
