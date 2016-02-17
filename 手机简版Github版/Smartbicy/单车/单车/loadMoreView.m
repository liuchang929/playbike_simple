//
//  loadMoreView.m
//  团购
//
//  Created by 王伟志 on 15/9/24.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "loadMoreView.h"

@implementation loadMoreView


- (IBAction)action:(id)sender {
    UIButton * button = (UIButton *) sender;
    [self.delegate loadMore:button];
}


@end
