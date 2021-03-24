//
//  MainViewController.m
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import "MainViewController.h"
#import "ScanViewController.h"
#import "EditViewController.h"
#import "ConnectionViewController.h"

@implementation MainViewController

/****************************************************************************************/
/*																						*/
/*									미사용 콜백											*/
/*																						*/
/****************************************************************************************/
- (void)receivedState:(CBCharacteristic *)characteristic {}
- (void)transmitted:(CBCharacteristic *)characteristic {}
- (void)enteredBackground {}
/****************************************************************************************/
/*																						*/
/*								장치가 검색되었을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)discoveredPeripherals:(CBPeripheral *)peripheral {
	
	// 이전에 연결되었던 장치 정보가 없을 경우 무시
	if (!self.manager.pre_beacon) {
		return;
	}
	
	// 이전에 연결되었던 장치와 이름이 같으면 연결
	if ([self.manager.pre_beacon.name isEqualToString: peripheral.name]) {
		
		[[self manager] connect:peripheral];
	}
}
/****************************************************************************************/
/*																						*/
/*								장치와의 연결이 성공했을 경우									*/
/*																						*/
/****************************************************************************************/
- (void)connected {
	
	// 탐색 중지
	[[self manager] stopScan];
	
	// 이전 연결장치 정보 초기화
	[self.manager setPre_beacon:NULL];
	
	// 거리가 멀어져 연결이 해제된 경우
	if ([[[self manager] helper] disconnectReason] == DISCONNECTED_DISTANCE) {
		
		// 화면 정보 갱신
		[self display];
	}
	// 그렇지 않으면
	else {
		
		// 커넥션 뷰 생성
		[self performSegueWithIdentifier:@"main_to_conn" sender:self];
	}
	
	// remove 버튼 활성화
	[[self button_remove] setEnabled:YES];
}
/****************************************************************************************/
/*																						*/
/*							장치와 연결이 해제되었을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)disconnected:(CBPeripheral *)peripheral {
	
	// 화면 갱신
	[self display];
	
	// 이전 연결 장치 정보 저장
	[self.manager setPre_beacon:peripheral];
	
	// 앱이 백그라운드 상태일 경우
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
		
		// 통지 메시지 설정
		UILocalNotification *alert = [[UILocalNotification alloc] init];
		[alert setAlertBody: @"Beacon is disconnected"];
		[alert setAlertTitle: @"LossPrevention"];
		
		// 앱 알람음 설정이 켜져 있을 경우
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sounding"]) {
			
			// 알람음 설정
			[alert setSoundName: @"wakare_30s.aif"];
		}
		// 그렇지 않으면
		else {
			
			// 알람음 없음
			[alert setSoundName: nil];
		}
		
		// 사용자에게 알림
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
		[[UIApplication sharedApplication] presentLocalNotificationNow:alert];
	}
	
	// 거리가 멀어져 연결이 해제된 경우
	if ([[[self manager] helper] disconnectReason] == DISCONNECTED_DISTANCE) {
		
		// 이미 탐색 중인 경우에는 무시
		if ([[[[self manager] helper] central] isScanning]) {
			
			return ;
		}
		// 탐색 시작
		[[self manager] scan];
	}
	// 그렇지 않으면
	else {
		
		// remove 버튼 변경
		[[self button_remove] setTitle:@"Reconnect" forState:UIControlStateNormal];
	}
	// 버튼 활성화
	[[self button_remove] setEnabled:YES];
}
/****************************************************************************************/
/*																						*/
/*							RSSI 정보를 수신했을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)receivedRSSI:(NSNumber *)RSSI {
	
	// 레이블 설정
	[[self label_rssi] setText:[NSString string]];
	[[self label_rssi] setText:[NSString stringWithFormat:@"RSSI: %@", RSSI.stringValue]];
	
	// 현재 연결된 장치가 없으면 함수 종료
	if (![[[self manager] helper] beacon]) {
		return;
	}
	
	// 장치 탐색 중일 경우 함수 종료
	if ([[[[self manager] helper] central] isScanning]) {
		return ;
	}
	
	// 재귀적인 RSSI 요청
	[[self manager] readRSSI];
}
/****************************************************************************************/
/*																						*/
/*							배터리 정보를 수신했을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)receivedBattery:(CBCharacteristic *)characteristic {
	
	// 10진수로 변환
	int battery_value;
	[[characteristic value] getBytes:&battery_value length:sizeof(battery_value)];
	
	// 문자열로 변환
	NSString *battery_string = [NSString stringWithFormat:@"%d", battery_value];
	
	// 화면에 표시
	[[self label_battery] setText:[NSString string]];
	[[self label_battery] setText:[NSString stringWithFormat:@"%@%%", battery_string]];
}
/****************************************************************************************/
/*																						*/
/*									초기화 작업											*/
/*																						*/
/****************************************************************************************/
- (void)viewDidLoad {
	
	[super viewDidLoad];
	[self display];
}
/****************************************************************************************/
/*																						*/
/*								세그웨이 실행 전 설정										*/
/*																						*/
/****************************************************************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	// 스캔 뷰
	if ([[segue identifier] isEqualToString:@"main_to_scan"]) {
		ScanViewController *svc = segue.destinationViewController;
		[svc setManager: self.manager];
		[[[svc manager] helper] setDelegate:svc];
	}
	
	// 에딧 뷰
	if ([[segue identifier] isEqualToString:@"main_to_edit"]) {
		EditViewController *evc = segue.destinationViewController;
		[evc setManager: self.manager];
		[[[evc manager] helper] setDelegate:evc];
	}
	
	// 커넥션 뷰
	if ([[segue identifier] isEqualToString:@"main_to_conn"]) {
		ConnectionViewController *cvc = segue.destinationViewController;
		[cvc setManager: self.manager];
		[[[cvc manager] helper] setDelegate:cvc];
	}
}
/****************************************************************************************/
/*																						*/
/*									화면 출력 갱신											*/
/*																						*/
/****************************************************************************************/
- (void)display {
	
	// 레이블 초기화
	[[self label_name] setText:[NSString string]];
	[[self label_rssi] setText:[NSString string]];
	[[self label_battery] setText:[NSString string]];
	
	// 이전 연결 장치 정보가 있을 경우
	if (self.manager.pre_beacon) {
		
		// 거리가 멀어져 연결이 끊어진 경우
		if ([[[self manager] helper] disconnectReason] == DISCONNECTED_DISTANCE) {
			
			// 이미 장치 탐색 중이 아니라면
			if (![self.manager.helper.central isScanning]) {
				
				// 장치 탐색 시작
				[self.manager scan];
			}
			return;
		}
		// remove 버튼 상태 변경
		[[self button_remove] setTitle:@"Reconnect" forState:UIControlStateNormal];
		return;
	}
	
	// 현재 연결된 장치 정보가 있을 경우
	if ([[[self manager] helper] beacon]) {
		
		// 장치 이름 출력
		[[self label_name] setText: [[[[self manager] helper] beacon] name]];
		// RSSI 요청
		[[self manager] readRSSI];
		// 배터리 정보 요청
		[[self manager] sendData:@"BATTERY"];
		// remove 버튼 초기화
		[[self button_remove] setTitle:@"Remove" forState:UIControlStateNormal];
	}
}
/****************************************************************************************/
/*																						*/
/*								경보음 테스트 버튼											*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonBell:(UIButton *)sender {
	
	if ([[[self manager] helper] beacon]) {
		
		// 정보 전송 요청
		[[self manager] sendData:@"TEST_ALERT"];
		// 버튼 비활성화
		[[self button_bell] setEnabled:NO];
		// 타이머 설정
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timeoutHandler:) userInfo:nil repeats:NO];
	}
}
/****************************************************************************************/
/*																						*/
/*								타이머 이벤트												*/
/*																						*/
/****************************************************************************************/
- (void)timeoutHandler:(NSTimer *)timer {
	
	// 버튼 활성화
	[[self button_bell] setEnabled:YES];
	// 타이머 해제
	[timer invalidate];
}
/****************************************************************************************/
/*																						*/
/*								배터리 요청 버튼											*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonBattery:(UIButton *)sender {
	
	// 장치 탐색 중일 경우 무시
	if ([[[[self manager] helper] central] isScanning]) {
		return ;
	}
	
	// 현재 연결된 장치 정보가 있을 경우
	if ([[[self manager] helper] beacon]) {
		
		// 배터리 정보 요청
		[[self manager] sendData:@"BATTERY"];
	}
}
/****************************************************************************************/
/*																						*/
/*								연결 해제 버튼												*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonRemove:(UIButton *)sender {
	
	// 이전 연결 장치 정보가 있을 경우
	if (self.manager.pre_beacon) {
		
		// 거리가 멀어져 연결이 해제된 경우에는 무시
		if ([[[self manager] helper] disconnectReason] == DISCONNECTED_DISTANCE) {
		
			return;
		}
		
		// 이전 연결 장치와 재연결 시도
		[[self manager] connect:self.manager.pre_beacon];
		// 버튼 비활성화
		[[self button_remove] setEnabled:NO];
	}
	// 그렇지 않으면
	else {
		
		// 현재 연결된 장치 정보가 있을 경우
		if ([[[self manager] helper] beacon]) {
			
			// 장치 연결 해제
			[[self manager] disconnect: [[[self manager] helper] beacon]];
			// 버튼 비활성화
			[[self button_remove] setEnabled:NO];
		}
	}
}

@end
