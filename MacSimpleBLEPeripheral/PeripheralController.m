//
//  PeripheralController.m
//  MacSimpleBLEPeripheral
//
//  Created by takanori uehara on 2014/11/15.
//  Copyright (c) 2014年 takanori uehara. All rights reserved.
//

#import "PeripheralController.h"

#define LOCAL_NAME @"Mac Simple BLE Peripheral"
#define SERVICE_UUID @"00000000-0000-0000-0000-000000000000"
#define CHARACTERISTIC_UUID @"00000000-0000-0000-0000-000000000000"

@interface PeripheralController() {
    NSDictionary *systemVersionPlist;
}

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *characteristic;

@end

@implementation PeripheralController

// 初期化
- (id)initPeripheral {
    self = [super init];
    NSLog(@"%@: initPeripheral", self);
    
    self.serviceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
    self.characteristicUUID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    
    // システム情報取得
    systemVersionPlist = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    
    // PeripheralManager オプション
    NSDictionary *options = @{
                              CBPeripheralManagerOptionShowPowerAlertKey: @YES, // 開始時に Bluetooth がオフならアラートを表示
                              };
    
    // CBPeripheralManager 初期化
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:options];
    
    return self;
}

// バッテリー残量取得
- (float)getBatteryLevel {
    NSTask *task  = [[NSTask alloc] init];
    NSPipe *pipe  = [[NSPipe alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments: [NSArray arrayWithObjects: @"-c", @"ioreg -n AppleSmartBattery | awk '/MaxCapacity/{MAX=$5}/CurrentCapacity/{CURRENT=$5} END {printf(\"%f\",CURRENT/MAX*100)}'", nil]];
    [task setStandardOutput: pipe];
    [task launch];
    NSFileHandle *handle = [pipe fileHandleForReading];
    NSData *data = [handle  readDataToEndOfFile];
    float batteryLevel = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] floatValue];
    NSLog(@"getBatteryLevel: batteryLevel = %f", batteryLevel);
    
    return batteryLevel;
}

// アドバタイズ停止
- (void)stopAdvertising {
    NSLog(@"stopAdvertising");
    
    [self.peripheralManager stopAdvertising];
}

// アドバタイズ開始
- (void)startAdvertising {
    NSLog(@"startAdvertising");
    
    // サービス設定
    CBMutableService *service = [[CBMutableService alloc] initWithType:self.serviceUUID primary:YES];
    
    
    
    // キャラクタリスティック設定
    self.characteristic = [[CBMutableCharacteristic alloc] initWithType:self.characteristicUUID
                                                             properties:CBCharacteristicPropertyRead
                                                                  value:nil
                                                            permissions:CBAttributePermissionsReadable];
    service.characteristics = @[self.characteristic];
    
    // サービス登録
    [self.peripheralManager addService:service];
    
    [self.peripheralManager startAdvertising:@{
                                               CBAdvertisementDataLocalNameKey: LOCAL_NAME, // セントラル側で表示される機器名
                                               CBAdvertisementDataServiceUUIDsKey: @[
                                                       self.serviceUUID,
                                                        ],
                                               }];
}

// PeripheralManager ステータス変更時
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheralManagerDidUpdateState:: peripheral.state = %ld", (long)peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            // 不明な状態 (初期値)
            NSLog(@"unknown state (default)");
            break;
        case CBPeripheralManagerStateResetting:
            // 一時的に切断され、再設定された
            NSLog(@"resetting");
            break;
        case CBPeripheralManagerStateUnsupported:
            // BLE がサポートされていない
            NSLog(@"BLE is unsupported");
            break;
        case CBPeripheralManagerStateUnauthorized:
            // BLE が許可されていない
            NSLog(@"BLE is unauthorized");
            break;
        case CBPeripheralManagerStatePoweredOff:
            // Bluetooth がオフ
            NSLog(@"bluetooth power off");
            break;
        case CBPeripheralManagerStatePoweredOn:
            // Bluetooth がオン
            NSLog(@"bluetooth power on");
            break;
        default:
            break;
    }
}

// セントラルから読み取り要求があった場合
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"peripheralManager:didReceiveReadRequest:");
    
    NSDictionary *dic = @{
                          @"system": systemVersionPlist[@"ProductName"],
                          @"version": systemVersionPlist[@"ProductVersion"],
                          @"batteryLevel": [NSNumber numberWithFloat:[self getBatteryLevel]],
                          };
    NSLog(@"characteristic value = %@", dic);
//    NSData *value = [NSKeyedArchiver archivedDataWithRootObject:dic];
//    request.value = value;
    NSString *res = [NSString stringWithFormat:@"%@ %@\nBattery: %5.2f%%",
                     dic[@"system"],
                     dic[@"version"],
                     [dic[@"batteryLevel"] floatValue]];
    NSLog(@"res = %@", res);
    request.value = [res dataUsingEncoding:NSUTF8StringEncoding];
    
    // セントラルへ返答
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

// キャラクタリスティック値更新
- (void)updatePeripheralValue:(NSData*)value {
    NSLog(@"updatePeripheralValue: value = %@", value);
    
    if (value == nil) {
        NSLog(@"value is null");
        return;
    }
    
    BOOL ret = [self.peripheralManager updateValue:value forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    NSLog(@"ret = %@", ret?@"true":@"false");
}

@end
