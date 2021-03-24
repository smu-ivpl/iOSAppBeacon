//
//  LPManager.h
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/27/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBHelper.h"

#define DISCONNECTED_APP		0
#define DISCONNECTED_BEACON		7
#define DISCONNECTED_DISTANCE	6

@interface LPManager : NSObject

@property (strong, nonatomic) CBHelper *helper;
@property (strong, nonatomic) CBPeripheral *pre_beacon;

- (void)scan;
- (void)stopScan;
- (void)connect:(CBPeripheral *)beacon;
- (void)disconnect:(CBPeripheral *)beacon;
- (void)sendData:(NSString *)option;
- (void)readRSSI;

@end
