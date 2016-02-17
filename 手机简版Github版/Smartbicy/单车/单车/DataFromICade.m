//
//  DataFromICade.m
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import "DataFromICade.h"

@implementation DataFromICade

+ (id) initWithCurrentDateWithHeartBeatCount:(int)heartBeatCount
{
    DataFromICade *dataFromICade = [[DataFromICade alloc] initWithCurrentDateWithHeartBeatCount:heartBeatCount];
    
    return dataFromICade;
}

+  (id) initWithCurrentDateWithLoopNum:(NSInteger)loopNum
{
    DataFromICade *dataFromICade = [[DataFromICade alloc] initWithCurrentDateWithLoopNum:loopNum];
    
    return dataFromICade;
}

- (id) initWithCurrentDateWithHeartBeatCount:(int)heartBeatCount
{
    self = [super init];
    if (self) {
        self.heartBeatCountNumber =[NSNumber numberWithInt:heartBeatCount];
        NSDate *currentDate = [NSDate date];
        self.dateForReceive = currentDate;
        
    }
    return self;
}

-  (id) initWithCurrentDateWithLoopNum:(NSInteger)loopNum
{
    self = [super init];
    if (self) {
        self.loopNum =[NSNumber numberWithInteger:loopNum];
        NSDate *currentDate = [NSDate date];
        self.dateForReceive = currentDate;
        
    }
    return self;
}

@end
