//
//  CBHelper.h
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/27/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol CBHelperDelegate <NSObject>

- (void)connected;
- (void)disconnected:(CBPeripheral *)peripheral;
- (void)transmitted:(CBCharacteristic *)characteristic;
- (void)discoveredPeripherals:(CBPeripheral *)peripheral;
- (void)receivedRSSI:(NSNumber *)RSSI;
- (void)receivedState:(CBCharacteristic *)characteristic;
- (void)receivedBattery:(CBCharacteristic *)characteristic;

@end

@interface CBHelper : NSObject < CBCentralManagerDelegate, CBPeripheralDelegate >

@property (assign, nonatomic) id <CBHelperDelegate> delegate;
@property (strong, nonatomic) CBCentralManager *central;
@property (strong, nonatomic) CBPeripheral *beacon;
@property (assign, nonatomic) NSInteger disconnectReason;

@end
