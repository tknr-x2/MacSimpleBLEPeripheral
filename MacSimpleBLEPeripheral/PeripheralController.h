//
//  PeripheralController.h
//  MacSimpleBLEPeripheral
//
//  Created by takanori uehara on 2014/11/15.
//  Copyright (c) 2014年 takanori uehara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

@interface PeripheralController : NSObject <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBUUID *serviceUUID;
@property (strong, nonatomic) CBUUID *characteristicUUID;

- (id)initPeripheral;

- (void)stopAdvertising;
- (void)startAdvertising;
- (void)updatePeripheralValue:(NSData*)value;

@end
