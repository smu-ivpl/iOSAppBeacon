//
//  LPManager.m
//  LossPrevention
// 
//  Created by Youngwoon Lee on 6/27/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import "LPManager.h"
#import "ScanViewController.h"

@implementation LPManager

/****************************************************************************************/
/*																						*/
/*									초기화 작업											*/
/*																						*/
/****************************************************************************************/
- (id)init {
	if (self = [super init]) {
		
		[self setHelper:[[CBHelper alloc] init]];
		[self setPre_beacon:NULL];
	}
	return self;
}
/****************************************************************************************/
/*																						*/
/*								주변장치 검색 시작											*/
/*																						*/
/****************************************************************************************/
- (void)scan {
	
	[[[self helper] central] scanForPeripheralsWithServices:nil options:nil];
}
/****************************************************************************************/
/*																						*/
/*								주변장치 검색 중지											*/
/*																						*/
/****************************************************************************************/
- (void)stopScan {
	
	[[[self helper] central] stopScan];
}
/****************************************************************************************/
/*																						*/
/*								해당 비콘 장치와 연결										*/
/*																						*/
/****************************************************************************************/
- (void)connect:(CBPeripheral *)beacon {
	
	[[[self helper] central] connectPeripheral:beacon options:nil];
}
/****************************************************************************************/
/*																						*/
/*								해당 비콘 장치와 연결 해제									*/
/*																						*/
/****************************************************************************************/
- (void)disconnect:(CBPeripheral *)beacon {

	[[[self helper] central] cancelPeripheralConnection: beacon];
}
/****************************************************************************************/
/*																						*/
/*							문자열에 따라 비콘으로 전송될 정보를 설정							*/
/*																						*/
/*							BATTERY														*/
/*																						*/
/*							TEST														*/
/*								TEST_NONE												*/
/*								TEST_ALERT												*/
/*								TEST_WARN												*/
/*																						*/
/*							LINKLOSS													*/
/*								LINKLOSS_NONE											*/
/*								LINKLOSS_ALERT											*/
/*								LINKLOSS_WARN											*/
/*																						*/
/****************************************************************************************/
- (void)sendData:(NSString *)option {
	
	// 매개변수 문자열은 "xxx_xxx_..." 형식으로 전달됨
	// 언더바 "_" 를 기준으로 문자열을 분리하여 내용을 확인
	int i = 0x00;
	NSData *data = NULL;
	NSString *cid = NULL;
	NSString *sid = NULL;
	
	// 배터리 정보
	if ([[option componentsSeparatedByString:@"_"][0] isEqualToString:@"BATTERY"]) {
		
		cid = @"2A19";
		sid = @"180F";
	}
	// 경보음 테스트
	if ([[option componentsSeparatedByString:@"_"][0] isEqualToString:@"TEST"]) {
		
		cid = @"2A06";
		sid = @"1802";
		
		if ([option isEqualToString:@"TEST_NONE"]) {
			
			i = 0x00;
		}
		if ([option isEqualToString:@"TEST_ALERT"]) {
			
			i = 0x01;
		}
		if ([option isEqualToString:@"TEST_WARN"]) {
			
			i = 0x02;
		}
		option = @"TEST";
	}
	// 경보음 설정
	if ([[option componentsSeparatedByString:@"_"][0] isEqualToString:@"LINKLOSS"]) {

		cid = @"2A06";
		sid = @"1803";
		
		if ([option isEqualToString:@"LINKLOSS_WRITE_NONE"]) {
			
			i = 0x00;
			option = @"LINKLOSS_WRITE";
		}
		if ([option isEqualToString:@"LINKLOSS_WRITE_ALERT"]) {
			
			i = 0x01;
			option = @"LINKLOSS_WRITE";
		}
		if ([option isEqualToString:@"LINKLOSS_WRITE_WARN"]) {
			
			i = 0x02;
			option = @"LINKLOSS_WRITE";
		}
	}
	// 최종 데이터 비콘으로 전송
	data = [NSData dataWithBytes: &i length: sizeof(i)];
	[self sendToBeacon:data Characteristic:cid Service:sid Option:option];
}
/****************************************************************************************/
/*																						*/
/*								비콘으로 데이터 전송										*/
/*																						*/
/****************************************************************************************/
- (void)sendToBeacon:(NSData *)data Characteristic:(NSString *)cid Service:(NSString *)sid Option:(NSString *)option {
	
	// 전체 service 에 대하여
	for (CBService *service in [[[self helper] beacon] services]) {
		
		// 해당 service uuid 확인
		if ([[[service UUID] UUIDString] isEqual:sid]) {
			
			// 전체 characteristic 에 대하여
			for (CBCharacteristic *characteristic in [service characteristics]) {
				
				// 해당 characteristic uuid 확인
				if ([[[characteristic UUID] UUIDString] isEqual:cid]) {
					
					// 배터리 정보 요청
					if ([option isEqualToString:@"BATTERY"]) {
						
						[[[self helper] beacon] readValueForCharacteristic:characteristic];
						[[[self helper] beacon] setNotifyValue:YES forCharacteristic:characteristic];
					}
					
					// 경보음 테스트
					if ([option isEqualToString:@"TEST"]) {
						
						[[[self helper] beacon] writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
					}
					
					// 경보음 설정 상태 확인
					if ([option isEqualToString:@"LINKLOSS_READ"]) {
						
						[[[self helper] beacon] readValueForCharacteristic:characteristic];
					}
					
					// 경보음 설정
					if ([option isEqualToString:@"LINKLOSS_WRITE"]) {
						
						[[[self helper] beacon] writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
					}
				}
			}
		}
	}
}
/****************************************************************************************/
/*																						*/
/*								RSSI 값 요청												*/
/*																						*/
/****************************************************************************************/
- (void)readRSSI {
	
	[[[self helper] beacon] readRSSI];
}


@end
