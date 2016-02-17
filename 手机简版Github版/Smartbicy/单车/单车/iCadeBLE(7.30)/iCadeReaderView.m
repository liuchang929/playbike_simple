/*
 Copyright (C) 2011 by Stuart Carnie
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "iCadeReaderView.h"
#import "UUID.h"
#pragma mark BLE 1

#define begin_space   857


//static const char *ON_STATES  = "wdxayhujikol";
//static const char *OFF_STATES = "eczqtrfnmpgv";
//
#pragma mark BLE 2
@interface iCadeReaderView ()
{
    int countnumber;
    NSData *data;
    NSData *lastdata;
    NSDate *datetime;
    long long miliSeconds;
    NSString* date;
    NSString *timeNow;
    int testi;
    
    int milsecond;
    int second;
    int minute;
    int hour;
    int totaltime;
    int lasttotaltime;
    int beat_space_time; //两次心率脉冲时间间隔
    int sum ;              //连续12个心率脉冲试讲间隔相加，结果用sum表示
    int heart_rate ;       //心率次数
    int lastheart_rate;
    int average  ;          //12个脉冲的平均时间间隔 average = sum/12
    int lastaverage ;
   
    int averageheart_rate;
    int lastaverageheart_rate;
    int countnumberforheart_rate;
    int storeheart_rate;
    
    NSMutableArray *span;
    //int begin_space = 857;
    //int countnumber = 0;
    int resnumber ;
    int lastaverage_beat_space_time ;

}

@end

@implementation iCadeReaderView
int begin_flag = 0;

@synthesize iCadeState=_iCadeState, delegate=_delegate, active;

#pragma mark BLE 3
#pragma mark 开始蓝牙配置


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSMutableString *stringForCentralManagerState = [NSMutableString stringWithString:@"UpdateState:"];
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            [stringForCentralManagerState appendString:@"Unkown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [stringForCentralManagerState appendString:@"Unsupported\n"];
        case CBCentralManagerStateUnauthorized:
            [stringForCentralManagerState appendString:@"Unauthorized\n"];
        case CBCentralManagerStateResetting:
            [stringForCentralManagerState appendString:@"Resetting\n"];
        case CBCentralManagerStatePoweredOff:
            [stringForCentralManagerState appendString:@"PowerOff\n"];
        case CBCentralManagerStatePoweredOn:
            //设备支持BLE并且可用
            [stringForCentralManagerState appendString:@"PoweredOn\n"];
            
            //开始搜索
            [self scan];
            break;
        default:
            [stringForCentralManagerState appendString:@"none\n"];
            break;
    }
    NSLog(@"%@", stringForCentralManagerState);
    
}

#pragma mark 扫描
- (void)scan
{
    
    //第一个参数如果设置为nil，会寻找所有service
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    
    NSLog(@"Scanning started");
}

#pragma mark 发现设备,连接
//一旦符合要求的设备被发现，就会回调此方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // 设置能连接的设备的信号质量范围
    //    if (RSSI.integerValue > -15) {
    //        NSLog(@"未连接，因为信号不在有效范围内");
    //        return;
    //    }
    //    if (RSSI.integerValue < -35) {
    //        NSLog(@"未连接，因为信号不 在有效范围内");
    //        return;
    //    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // 连接
        NSLog(@"Connecting to peripheral %@", peripheral);

        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

#pragma mark 未能连接的处理方法
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    
    //    [self cleanup];
}

#pragma mark 当连接上设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // 已连接上设备，故停止搜索
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // 寻找指定UUID的Service
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];

    //通知控制器蓝牙连接
    
    //创建通知中心
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    
    // 2. 订阅通知 （必须限订阅才可以接收发布的通知）
    [center addObserver:self.delegate selector:@selector(blueToothConnect:)
                   name:@"connect" object:self];
    [center postNotificationName:@"connect" object:self
                        userInfo:nil];
    
//    //////////显示框弹出蓝牙已经连接
//    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"连接状况" message:@"蓝牙已连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"关闭", nil];
//    
//    [alert1 show];
  //  [alert1 dismissWithClickedButtonIndex:0 animated:YES];

}

#pragma mark 发现设备上指定Service会回调此处
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        //        [self cleanup];
        return;
    }
    
    // 寻找指定UUID的Characteristic
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}
#pragma mark 找到指定UUID的Characteristic会回调此处
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //       [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            NSLog(@"find the characteristic");
            
            /*对于characteristic的value,有两种读取方式：
             *1.readValueForCharacteristic
             *直接读取，不保证每个值都被读取到，这取决于读取数据的频率
             *2.notify
             *每个变化的值都会接受到
             *
             *两种方式的调用方法不同，在使用前，请先确定读取方式，然后选择正确的读取方式。对于同一个characteristic，如果它可以被
             *读取，那么读取方式只有一种。
             */
            
            //2.notify
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error){
        
                
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    //NSLog(@"value --> %@",characteristic.value);

    //初始化各种变量
    if (countnumber == 0){
        lastdata = characteristic.value;
        span = [NSMutableArray arrayWithCapacity:8];
        average = 857;
        lastaverage = 857;
        NSNumber *aNumber1 = [NSNumber numberWithInteger:begin_space];
        
        for (int i = 0; i < 8; i ++ ) {
            [span addObject:aNumber1];
        }
         countnumber ++ ;
    }
    else
    {
        data = characteristic.value;
        Byte *testByte = (Byte *)[data bytes];
        Byte *lastByte = (Byte *)[lastdata bytes];
        
        if(testByte[5] != lastByte[5] ){
            if (lastByte[5] == 16){
 //               NSLog(@"检测出来心率信号了");
//                [self.delegate buttonDown:iCadeJoystickDown];
                NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
                [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
                date = [formatter stringFromDate:[NSDate date]];
                timeNow = [[NSString alloc] initWithFormat:@"%@", date];
                milsecond = [[timeNow substringWithRange:NSMakeRange(20,3)] intValue];
                second = [[timeNow substringWithRange:NSMakeRange(17,2)] intValue];
                minute = [[timeNow substringWithRange:NSMakeRange(14,2)] intValue];
                hour   = [[timeNow substringWithRange:NSMakeRange(11,2)] intValue];
                totaltime = milsecond + second*1000 + minute*60*1000 + hour*60*60*1000 ;
                beat_space_time = totaltime - lasttotaltime ;
                lastaverage_beat_space_time = lastaverage - beat_space_time;
                //心率的最大值定位200，最小值定为55，超过范围的滤掉
                if (beat_space_time > 300 && beat_space_time < 1091){
                    if ( (lastaverage_beat_space_time < 500) && (lastaverage_beat_space_time > -500)){
                        [span exchangeObjectAtIndex:0 withObjectAtIndex:1];
                        [span exchangeObjectAtIndex:1 withObjectAtIndex:2];
                        [span exchangeObjectAtIndex:2 withObjectAtIndex:3];
                        [span exchangeObjectAtIndex:3 withObjectAtIndex:4];
                        [span exchangeObjectAtIndex:4 withObjectAtIndex:5];
                        [span exchangeObjectAtIndex:5 withObjectAtIndex:6];
                        [span exchangeObjectAtIndex:6 withObjectAtIndex:7];
                        
                        NSNumber *aNumber = [NSNumber numberWithInteger:beat_space_time];
                        [span replaceObjectAtIndex:7 withObject:aNumber] ;
  //                      NSLog(@"数组为-->%@", span);
                        for (int i = 0; i < 8; i++) {
                            NSInteger anInteger = [span[i] integerValue];
                            sum = sum + anInteger;
                        }
                        average = (int)(sum / 8) ;
                        
                        heart_rate = 60000 * 8 / sum ;
                        
                        //卡尔曼滤波，进一步减小心率的浮动
                        if (countnumberforheart_rate == 0) {
                            
                            averageheart_rate = heart_rate;
                            countnumberforheart_rate ++;
                            storeheart_rate = heart_rate;
                            
                        }else if (countnumberforheart_rate == 1){
                            
                            averageheart_rate = (averageheart_rate + heart_rate) / 2;
                            lastaverageheart_rate = averageheart_rate;
                            countnumberforheart_rate ++;
                            
                        }else{
                            
                            averageheart_rate = (averageheart_rate + lastaverageheart_rate + heart_rate)/3 ;
                        }
                        
                        lastaverageheart_rate = averageheart_rate;
                        
                        
                        NSLog(@"心率为-->%d", averageheart_rate);
                        
                        //此时这句话用到检测不到心率时显示0
                        [self.delegate buttonDown:iCadeJoystickDown];
                        
   //                     NSLog(@"countnumberforheart_rate-->@%d",countnumberforheart_rate);
                        if (countnumber < 5) {
                            countnumber ++ ;
                            heart_rate = 70;
                        }
                    }
                }
                
            }
        }
        
        if(testByte[6] != lastByte[6])
        {
            if (testByte[6] == 16)
            {
//                NSLog(@"检测出来骑一圈了");
                testi ++ ;
//                NSLog(@"骑行的总圈数为——>@%D",testi);
                [self.delegate buttonDown:iCadeJoystickUp];
            }
            
        }

        lastdata = data ;
        lasttotaltime = totaltime;
        sum = 0 ;
        lastaverage = average;
    }
    
    get_heart_rate = averageheart_rate ;
}



- (id)initWithFrame:(CGRect)frame {
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self = [super initWithFrame:frame];
    inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return self;
}


#pragma mark 蓝牙断开后自动重连
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    // We're disconnected, so start scanning again
    
    
    //通知控制器蓝牙断开
    
    //创建通知中心
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    
    // 2. 订阅通知 （必须限订阅才可以接收发布的通知）
    [center addObserver:self.delegate selector:@selector(blueToothConnect:)
                   name:@"break" object:self];
    [center postNotificationName:@"break" object:self
                        userInfo:nil];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"蓝牙连接状态" message:@"连接已断开" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"关闭", nil];
//    [alert show];
    [self scan];
}


@end
