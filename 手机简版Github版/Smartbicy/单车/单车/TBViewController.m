//
//  TBViewController.m
//  单车
//
//  Created by comfouriertech on 14-6-4.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "TBViewController.h"

@interface TBViewController () {
    NSDictionary *_settings;
}
@end
@implementation TBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //获得settings.plist内容。存放在NSDictionnary *_settings中
   _settings = [[NSDictionary alloc] initWithContentsOfFile:[self filePath]];
//    NSLog(@"---_settings-->%@", _settings);
    
}

#pragma 获得settings.plist文件的路径，用于后续的初始化NSDictionnary
- (NSString *)filePath
{
    //模拟器上用此方法可行，真机有问题
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *path = [bundle pathForResource:@"settings.plist" ofType:nil];
    
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *docPath = [doc objectAtIndex:0];
    NSString *path = [docPath stringByAppendingString:@"settings.plist"];
    return path;
}

#pragma 判断进入NewFeatureController还是MainViewController
- (void)viewDidAppear:(BOOL)animated {
    //settings文件用于保存程序的一些参数，使用的是dictionnary。
    //目前保存的参数就一个，  key: isNewFeature   value: YES/NO
    //当程序第一次被打开，value:YES，会进入新特性画面，并设置value为NO，之后在打开程序，不会进入新特性画面
    
    //获得settings.plist中的 isNewFeature参数值
    BOOL isNewFeature =[_settings[@"isNewFeature"] boolValue];
    
    //延迟动画。刚进入程序，会有一个类似logo的图画，停留2s，进入其他viewController
     [NSThread sleepForTimeInterval:2.0];
    
    //是否进入 ： NeaFeaturesController
    if(isNewFeature == YES){
//        NSLog(@"isNewFeature is YES-->%d", isNewFeature);
        NSNumber *isNewFeature = [[NSNumber alloc] initWithBool:NO];
        NSDictionary *array = [[NSDictionary alloc] initWithObjects:@[isNewFeature] forKeys:@[@"isNewFeature"]];
//        NSMutableArray *array = [[NSMutableArray alloc] init];
//        [array insertObject:isNewFeature atIndex:0];
        [array writeToFile:[self filePath] atomically:YES];
//        NSLog(@"---%@", array);
        [self performSegueWithIdentifier:@"NewFeature" sender:self];
    }else {
        //跳转到MainViewController，也就是主菜单界面
        [self performSegueWithIdentifier:@"Welcome" sender:self];
    }
}

@end
