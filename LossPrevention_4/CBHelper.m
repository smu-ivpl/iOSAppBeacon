//
//  CBHelper.m
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/27/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import "CBHelper.h"

@implementation CBHelper


@synthesize delegate;

/****************************************************************************************/
/*																						*/
/*									초기화 작업											*/
/*																						*/
/****************************************************************************************/
- (id)init {
	if (self = [super init]) {
		
		[self setCentral:[[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@(YES)}]];
		[self setBeacon:NULL];
		[self setDisconnectReason:0];
	}
	return self;
}
/****************************************************************************************/
/*																						*/
/*							필수 구현 콜백 central 상태 변화에 따라 호출						*/
/*																						*/
/****************************************************************************************/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	
	switch ([central state]) {
			
		case CBCentralManagerStateUnauthorized:
			break;
			
		case CBCentralManagerStateUnsupported:
			break;
			
		case CBCentralManagerStatePoweredOff:
			break;
			
		case CBCentralManagerStateResetting:
			break;
			
		case CBCentralManagerStatePoweredOn:
			break;
			
		case CBCentralManagerStateUnknown:
			break;
			
		default:
			break;
	}
}
/****************************************************************************************/
/*																						*/
/*								주변 장치가 검색되면 호출									*/
/*																						*/
/****************************************************************************************/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
	
	if ([self delegate]) {
	
		// 이벤트 발생
		[[self delegate] discoveredPeripherals:peripheral];
	}
}
/****************************************************************************************/
/*																						*/
/*								장치와 연결에 성공하면 호출									*/
/*																						*/
/*			앱과 비콘 연결 - 서비스 탐색 - 특성 탐색 을 하나의 공정으로 자동화함					*/
/*			뷰에서 비콘 연결이 완료되었다는 이벤트가 발생하는 시점은 특성까지 모두 완료된 시점임		*/
/*																						*/
/****************************************************************************************/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	
	if ([self delegate]) {
	
		// 콜백 수신을 위한 대리자 설정
		[peripheral setDelegate: self];
		
		// 연결이 완료되면 서비스 검색
		[peripheral discoverServices:nil];
		
		// 연결된 장치 정보 저장
		[self setBeacon: peripheral];
	}
}
/****************************************************************************************/
/*																						*/
/*								장치와 연결이 끊어지면 호출									*/
/*																						*/
/****************************************************************************************/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	
	if ([self delegate]) {
	
		// 연결이 해제된 이유를 담고 있는 에러 코드 저장
		[self setDisconnectReason:error.code];
		
		// 연결된 비콘 정보 삭제
		[self setBeacon:NULL];
		
		// 이벤트 발생
		[[self delegate] disconnected:peripheral];
	}
}
/****************************************************************************************/
/*																						*/
/*								RSSI 값이 읽혀지면 호출										*/
/*																						*/
/****************************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
	
	if ([self delegate]) {
		
		[[self delegate] receivedRSSI:RSSI];
	}
}
/****************************************************************************************/
/*																						*/
/*								서비스가 검색되면 호출										*/
/*																						*/
/****************************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	
	// 모든 서비스에 대해서
	for (CBService *service in [peripheral services]) {
		
		// 특성을 검색
		[peripheral discoverCharacteristics:nil forService:service];
	}
}
/****************************************************************************************/
/*																						*/
/*								특성이 검색되면 호출										*/
/*																						*/
/****************************************************************************************/
int count = 0;	// 전체 특성을 모두 검색한 후에 이벤트를 발생시키기 위해 콜백이 호출된 횟수를 카운트
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	
	// 전체 서비스에 대한 특성 검색이 완료되면
	if (++count == [[peripheral services] count]) {
		
		// 카운터 초기화
		count = 0;
		
		// 장치와 연결되었음 알리는 이벤트 발생
		if ([self delegate]) {
			
			[[self delegate] connected];
		}
	}
}
/****************************************************************************************/
/*																						*/
/*								읽기 요청이 성공할 경우 호출									*/
/*																						*/
/****************************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	if ([self delegate]) {
	
		// 배터리 요청에 대하여
		if ([[[[characteristic service] UUID] UUIDString] isEqualToString:@"180F"]) {
		
			[[self delegate] receivedBattery:characteristic];
		}
		// 경보음 설정에 대하여
		if ([[[[characteristic service] UUID] UUIDString] isEqualToString:@"1803"]) {
			
			[[self delegate] receivedState:characteristic];
		}
	}
}
/****************************************************************************************/
/*																						*/
/*							구독 가능한 특성 값이 변경될 때 호출								*/
/*																						*/
/****************************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	if ([self delegate]) {
	
		// 배터리 설정에 대하여
		if ([[[[characteristic service] UUID] UUIDString] isEqualToString:@"180F"]) {
			
			[[self delegate] receivedBattery:characteristic];
		}
	}
}
/****************************************************************************************/
/*																						*/
/*								쓰기 요청이 성공할 경우 호출									*/
/*																						*/
/****************************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	if ([self delegate]) {
		
		// 경보음 설정에 대하여
		if ([[[[characteristic service] UUID] UUIDString] isEqualToString:@"1803"]) {
			
			[[self delegate] transmitted:characteristic];
		}
	}
}


@end
