//
//  EditViewController.m
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import "EditViewController.h"
#import "MainViewController.h"

@implementation EditViewController

/****************************************************************************************/
/*																						*/
/*									미사용 콜백											*/
/*																						*/
/****************************************************************************************/
- (void)discoveredPeripherals:(CBPeripheral *)peripheral {}
- (void)receivedBattery:(CBCharacteristic *)characteristic {}
- (void)receivedRSSI:(NSNumber *)RSSI { }
/****************************************************************************************/
/*																						*/
/*								장치와 연결되었을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)connected {
	
	// 이전 연결 정보 삭제
	[self.manager setPre_beacon:NULL];
	// 메인 뷰로 이동
	[self performSegueWithIdentifier:@"edit_to_main" sender:self];
}
/****************************************************************************************/
/*																						*/
/*									초기화 작업											*/
/*																						*/
/****************************************************************************************/
- (void)viewDidLoad {
	[super viewDidLoad];
	[self enableButtons:NO];
	[self.label_state setText:[NSString string]];
	[self.switch_sound setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"sounding"]];
	
	// 연결된 장치가 있을 경우
	if ([self.manager.helper beacon]) {
		
		// 경보음 설정 상태 요청
		[self.manager sendData:@"LINKLOSS_READ"];
	}
}
/****************************************************************************************/
/*																						*/
/*								경보음 설정 상태 수신										*/
/*																						*/
/****************************************************************************************/
- (void)receivedState:(CBCharacteristic *)characteristic {
	
	// 10진수로 변환
	int value;
	[characteristic.value getBytes:&value length:sizeof(value)];
	
	// 문자열로 변환
	NSString *value_string = [NSString stringWithFormat:@"%X", value];
	
	// 레이블 및 버튼 상태 변경
	[self setLabelLinkState:value_string];
	[self enableButtons:YES];
}
/****************************************************************************************/
/*																						*/
/*									레이블 설정											*/
/*																						*/
/****************************************************************************************/
- (void)setLabelLinkState:(NSString *)value	{
	
	// 0x00 은 꺼짐 상태
	if ([value isEqual:@"0"])
	{
		// 화면 표시
		[self.label_state setText:[NSString string]];
		[self.label_state setText:@"None"];
	}
	
	// 0x01 은 짧은 알람
	if ([value isEqual:@"1"])
	{
		// 화면 표시
		[self.label_state setText:[NSString string]];
		[self.label_state setText:@"Alert"];
	}
	
	// 0x02 는 연속적인 알람
	if ([value isEqual:@"2"])
	{
		// 화면 표시
		[self.label_state setText:[NSString string]];
		[self.label_state setText:@"Warning"];
	}
}
/****************************************************************************************/
/*																						*/
/*									정보 전송 완료											*/
/*																						*/
/****************************************************************************************/
- (void)transmitted:(CBCharacteristic *)characteristic {
	
	// 경보음 설정 상태 요청
	[self.manager sendData:@"LINKLOSS_READ"];
}
/****************************************************************************************/
/*																						*/
/*									버튼 설정												*/
/*																						*/
/****************************************************************************************/
- (void)enableButtons:(BOOL)enabled {
	
	[self.button_none setEnabled:enabled];
	[self.button_alert setEnabled:enabled];
	[self.button_warning setEnabled:enabled];
}
/****************************************************************************************/
/*																						*/
/*								경보음 무음 설정											*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonNone:(UIButton *)sender {
	
	[self.manager sendData:@"LINKLOSS_WRITE_NONE"];
	[self enableButtons:NO];
}
/****************************************************************************************/
/*																						*/
/*								경보음 단음 설정											*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonAlert:(UIButton *)sender {
	
	[self.manager sendData:@"LINKLOSS_WRITE_ALERT"];
	[self.manager sendData:@"TEST_ALERT"];
	[self enableButtons:NO];
}
/****************************************************************************************/
/*																						*/
/*								경보음 장음 설정											*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonWarning:(UIButton *)sender {
	
	[self.manager sendData:@"LINKLOSS_WRITE_WARN"];
	[self.manager sendData:@"TEST_WARN"];
	[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timeoutHandler:) userInfo:nil repeats:NO];
	[self enableButtons:NO];
}
/****************************************************************************************/
/*																						*/
/*									타이머 콜백											*/
/*																						*/
/****************************************************************************************/
- (void)timeoutHandler:(NSTimer *)timer {
	
	[self.manager sendData:@"TEST_NONE"];
	[timer invalidate];
}
/****************************************************************************************/
/*																						*/
/*								폰 알람음 설정												*/
/*																						*/
/****************************************************************************************/
- (IBAction)changedSwitchSound:(UISwitch *)sender {
	
	// 앱이 종료되어도 마지막 설정 값을 유지하기 위해 NSUserDefaults 이용
	[[NSUserDefaults standardUserDefaults] setBool:[self.switch_sound isOn] forKey:@"sounding"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
/****************************************************************************************/
/*																						*/
/*								세그웨이 실행 전 작업										*/
/*																						*/
/****************************************************************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([[segue identifier] isEqualToString:@"edit_to_main"]) {
		MainViewController *mvc = segue.destinationViewController;
		[mvc setManager: self.manager];
		[mvc.manager.helper setDelegate:mvc];
	}
}
/****************************************************************************************/
/*																						*/
/*								장치와 연결이 해제되었을 때									*/
/*																						*/
/****************************************************************************************/
- (void)disconnected:(CBPeripheral *)peripheral {
	
	// 이전 연결 정보 생성
	[self.manager setPre_beacon:peripheral];
	// 메인 뷰로 이동
	[self performSegueWithIdentifier:@"edit_to_main" sender:self];
}

@end
