//
//  CurrentAccount.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-7-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "CurrentAccount.h"

static CurrentAccount *sharedCurrentAccountInstance;

@implementation CurrentAccount

+ (id)sharedCurrentAccount
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCurrentAccountInstance = [[CurrentAccount alloc] init];
    });
    
    return sharedCurrentAccountInstance;
}

@end
