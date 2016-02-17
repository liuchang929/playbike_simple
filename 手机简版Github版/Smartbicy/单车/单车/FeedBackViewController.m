//
//  FeedBackViewController.m
//  SmartBicycle
//
//  Created by 王伟志 on 15/10/15.
//  Copyright (c) 2015年 王伟志. All rights reserved.
//

#import "FeedBackViewController.h"
#import "CurrentAccount.h"
#import "AFNetworking.h"
#import "MobClick.h"

@interface FeedBackViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *QQNumber;
@property (weak, nonatomic) IBOutlet UITextView *suggest;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    _suggest.delegate = self;
    _suggest.backgroundColor= [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    _phoneNumber.backgroundColor= [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(clearText)  name:UITextViewTextDidBeginEditingNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"反馈页面"];//("PageOne"为页面名称，可自定义)
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"反馈页面"];
}

-(void)clearText
{
    if ([_suggest.text isEqualToString:@"尽量详尽的描述您遇到的问题和现象，也欢迎对我们吐槽您不爽的地方，感谢您给我们提出宝贵的意见！"]) {
        _suggest.text = @"";
    }
}

- (void)back {
    CurrentAccount * current = [CurrentAccount sharedCurrentAccount];
    current.page = 4;
    [self performSegueWithIdentifier:@"feedBack" sender:nil];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]){
        return YES;
    }
    
    NSString * aString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (self.suggest == textView)
    {
        if ([aString length] > 1000)
        {
            textView.text = [aString substringToIndex:500];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"超过可输入范围了，请适当删减！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
    }
        return YES;
}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    //用户输入反馈内容，向上滑
//    [UIView animateWithDuration:0.5 animations:^{
//        float y = -1.0 * self.view.frame.size.height * 0.45/2.0;
//        self.view.frame = CGRectMake(0, y, self.view.frame.size.width,self.view.frame.size.height);
//    }];
//    return YES;
//}


#pragma mark - 发送建议
- (IBAction)sendSuggest:(id)sender {

    if ([_suggest.text isEqualToString:@"尽量详尽的描述您遇到的问题和现象，也欢迎对我们吐槽您不爽的地方，感谢您给我们提出宝贵的意见！"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"亲，请您填写建议哦" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
        if (_suggest.text.length > 1000)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"亲，提交的建议过长，可以再精简点哦" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            
            UIDevice *device = [[UIDevice alloc] init];
            //NSLog(@"localizedModel= %@,\ndevice.systemName = %@,\ndevice.systemVersion = %@，\nuuid = %@",device.localizedModel,device.systemName,device.systemVersion, device.identifierForVendor);
            
            NSString *urlString = [NSString stringWithFormat:@"http://%@/servlet/feedback?type=inderInformationFeedback&username=%@&phone_number=%@&&QQ_number=%@&advice=%@&system=%@&equipment=IOS&type_number=%@", [[CurrentAccount sharedCurrentAccount] serverName], [[CurrentAccount sharedCurrentAccount] userName],_phoneNumber.text,@"",_suggest.text,device.systemVersion,device.model];
            
            
            NSLog(@"发送建议url= %@",urlString);
            //有中文，需要转换
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            op.responseSerializer = [AFJSONResponseSerializer serializer];
            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"JSON: %@", responseObject);
                
                NSDictionary *dictionary = responseObject;
                int ret = [[dictionary objectForKey:@"ret"] intValue];
                
                //对服务器返回数据进行判断
                if (ret == 1) {
                    [self showAlertWithString:@"发送成功"];
                    [self back];
                }
                else if (ret == -1)
                {
                    [self showAlertWithString:@"发送失败"];
                    [self.view endEditing:YES];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self showAlertWithString:@"网络异常"];
                
            }];
            [[NSOperationQueue mainQueue] addOperation:op];
            
        }

}

-(void)showAlertWithString:(NSString *) string
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
