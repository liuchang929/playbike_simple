//
//  HistoryDataViewController.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-8-25.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDataViewController : UIViewController

- (IBAction)back:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
