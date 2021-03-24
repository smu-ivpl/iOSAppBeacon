//
//  ConnectionViewController.m
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import "ConnectionViewController.h"
#import "MainViewController.h"

@implementation ConnectionViewController

/****************************************************************************************/
/*																						*/
/*									미사용 콜백											*/
/*																						*/
/****************************************************************************************/
- (void)transmitted:(CBCharacteristic *)characteristic {}
- (void)receivedState:(CBCharacteristic *)characteristic {}
- (void)receivedRSSI:(NSNumber *)RSSI {}
- (void)receivedBattery:(CBCharacteristic *)characteristic	{}
- (void)discoveredPeripherals:(CBPeripheral *)peripheral {}
/****************************************************************************************/
/*																						*/
/*									초기화 작업											*/
/*																						*/
/****************************************************************************************/
- (void)viewDidLoad {
	[super viewDidLoad];
	[self.button_conn setTitle:@"Disconnect" forState:UIControlStateNormal];
	[self.table_info registerClass:UITableViewCell.class forCellReuseIdentifier:CID_CONN_TABLE];
	[self setData_source: [[NSMutableArray alloc] init]];
	[self display];
}
/****************************************************************************************/
/*																						*/
/*									테이블 원본 설정										*/
/*																						*/
/****************************************************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [self.data_source count];
}
/****************************************************************************************/
/*																						*/
/*									테이블 셀 설정											*/
/*																						*/
/****************************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// 셀 생성
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CID_CONN_TABLE];
	
	if (!cell) {
		
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CID_CONN_TABLE];
	}
	
	// 셀에 장치 정보 추가
	[cell.textLabel setText:[NSString stringWithFormat:@"%@", [self.data_source objectAtIndex:indexPath.row]]];
	
	return cell;
}
/****************************************************************************************/
/*																						*/
/*									연결 버튼												*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonConn:(UIButton *)sender {
	
	// 이전 연결 정보가 있을 경우
	if (self.manager.pre_beacon) {
		
		// 이전 장치와 연결
		[[self manager] connect:self.manager.pre_beacon];
		[self.button_conn setEnabled:NO];
	}
	// 그렇지 않으면
	else {
		
		// 현재 장치와 연결 해제
		[self.manager disconnect:[self.manager.helper beacon]];
		[self.button_conn setEnabled:NO];
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
	
	// 앱 조작에 의해 연결해제된 경우
	if ([self.manager.helper disconnectReason] == DISCONNECTED_APP) {
		
		// 테이블 초기화
		[self.data_source removeAllObjects];
		[self.table_info reloadData];
		// 버튼 상태 변경
		[self.button_conn setEnabled:YES];
		[self.button_conn setTitle:@"Connect" forState:UIControlStateNormal];
	}
	// 그렇지 않으면
	else {
		
		// 메인 뷰로 이동
		[self performSegueWithIdentifier:@"conn_to_main" sender:self];
	}
}
/****************************************************************************************/
/*																						*/
/*								장치와 연결되었을 떄										*/
/*																						*/
/****************************************************************************************/
- (void)connected {
	
	// 이전 연결 정보 삭제
	[self.manager setPre_beacon:NULL];
	// 버튼 설정
	[self.button_conn setEnabled:YES];
	[self.button_conn setTitle:@"Disconnect" forState:UIControlStateNormal];
	// 화면 갱신
	[self display];
}
/****************************************************************************************/
/*																						*/
/*										화면 갱신											*/
/*																						*/
/****************************************************************************************/
- (void)display {
	
	// 모든 서비스 요청
	for (CBService *service in [self.manager.helper.beacon services]) {
		
		// 서비스 정보 전시
		[self.data_source addObject:[NSString stringWithFormat:@"%@", service.UUID.UUIDString]];
		
		// 모든 특성 요청
		for (CBCharacteristic *characteristic in [service characteristics]) {
			
			// 특성 정보 전시
			[self.data_source addObject:[NSString stringWithFormat:@"\t%@:%@", characteristic.UUID.UUIDString, characteristic.value]];
			[self.table_info reloadData];
		}
	}
}
/****************************************************************************************/
/*																						*/
/*								세그웨이 실행 전 작업										*/
/*																						*/
/****************************************************************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([[segue identifier] isEqualToString:@"conn_to_main"]) {
		MainViewController *mvc = segue.destinationViewController;
		[mvc setManager: self.manager];
		[mvc.manager.helper setDelegate:mvc];
	}
}

@end
