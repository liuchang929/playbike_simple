//
//  DataFromICade.h
//  SmartBicycle
//
//  Created by comfouriertech on 14-11-29.
//  Copyright (c) 2014年 comfouriertech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataFromICade : NSObject

@property (strong, nonatomic) NSDate *dateForReceive;
@property (strong, nonatomic) NSNumber *heartBeatCountNumber;
@property (strong, nonatomic) NSNumber *loopNum;

+ (id) initWithCurrentDateWithHeartBeatCount:(int)heartBeatCount;
+ (id) initWithCurrentDateWithLoopNum:(NSInteger)loopNum;

-  (id) initWithCurrentDateWithHeartBeatCount:(int)heartBeatCount;
-  (id) initWithCurrentDateWithLoopNum:(NSInteger)loopNum;

@end
