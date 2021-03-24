//
//  ScanViewController.m
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "ScanViewController.h"
#import "MainViewController.h"
#import "ConnectionViewController.h"

@implementation ScanViewController

/****************************************************************************************/
/*																						*/
/*									미사용 콜백											*/
/*																						*/
/****************************************************************************************/
- (void)transmitted:(CBCharacteristic *)characteristic {}
- (void)receivedState:(CBCharacteristic *)characteristic {}
- (void)receivedBattery:(CBCharacteristic *)characteristic {}
- (void)receivedRSSI:(NSNumber *)RSSI {}
/****************************************************************************************/
/*																						*/
/*									초기화 작업											*/
/*																						*/
/****************************************************************************************/
- (void)viewDidLoad {
	[super viewDidLoad];
	[self setCandidate: NULL];
	[self setData_source: [[NSArray alloc] init]];
	[self setData_peripherals: [[NSMutableDictionary alloc] init]];
	[[self table_peripherals] registerClass:UITableViewCell.class forCellReuseIdentifier:CID_EDIT_TABLE];
}
/****************************************************************************************/
/*																						*/
/*									뷰가 사라질 때											*/
/*																						*/
/****************************************************************************************/
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	// 장치 탐색 중일 경우
	if ([[[[self manager] helper] central] isScanning]) {
		
		// 버튼 상태가 'Stop'일 경우
		if ([self.button_scan.titleLabel.text isEqualToString:@"Stop"]) {
			
			// 거리가 멀어져 연결이 끊어진 경우에는 무시
			if ([self.manager.helper disconnectReason] == DISCONNECTED_DISTANCE) {
				
				return;
			}
			
			// 장치 탐색 종료
			[[self manager] stopScan];
		}
	}
}
/****************************************************************************************/
/*																						*/
/*								테이블 뷰 원본 설정											*/
/*																						*/
/****************************************************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [[self data_source] count];
}
/****************************************************************************************/
/*																						*/
/*								테이블 뷰 셀 설정											*/
/*																						*/
/****************************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CID_EDIT_TABLE forIndexPath:indexPath];
	
	if (!cell) {
		
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CID_EDIT_TABLE];
	}
	
	CBPeripheral *peripheral = [self.data_source objectAtIndex:indexPath.row];
	[cell.textLabel setText:[NSString stringWithFormat:@"%@", peripheral.name]];
	
	return cell;
}
/****************************************************************************************/
/*																						*/
/*									테이블 뷰 갱신											*/
/*																						*/
/****************************************************************************************/
-(void)refreshTableViewPeripheral {
	
	NSArray* sorted_keys = nil;
	
	@synchronized(self)
	{
		sorted_keys = [self.data_peripherals keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
					   {
						   CBPeripheral* p1 = obj1;
						   CBPeripheral* p2 = obj2;
						   return [p1.identifier.UUIDString compare:p2.identifier.UUIDString];
					   }];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^
				   {
					   [self setData_source: [self.data_peripherals objectsForKeys:sorted_keys notFoundMarker:[NSNull null]]];
					   
					   [self.table_peripherals reloadData];
				   });
}
/****************************************************************************************/
/*																						*/
/*								테이블 뷰 셀을 터치했을 경우									*/
/*																						*/
/****************************************************************************************/
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// 버튼 비활성화
	[self.button_scan setEnabled:NO];
	// 탐색 중지
	[self.manager stopScan];
	// 선택된 셀에 해당하는 장치 정보 가져오기
	CBPeripheral *peripheral = [self.data_source objectAtIndex:indexPath.row];
	// 장치 연결 상태 검사
	if (peripheral.state == CBPeripheralStateDisconnected) {
		
		// 이미 연결된 장치 있을 경우
		if ([self.manager.helper beacon]) {
			
			// 장치 연결 해제
			[self.manager disconnect: [self.manager.helper beacon]];
			// 현재 선택된 장치를 후보로 저장
			[self setCandidate:peripheral];
			return;
		}
		//그렇지 않으면 장치와 연결
		[self.manager connect:peripheral];
	}
}
/****************************************************************************************/
/*																						*/
/*									장치 스캔 버튼											*/
/*																						*/
/****************************************************************************************/
- (IBAction)touchedButtonScan:(UIButton *)sender {
	
	// 이전에 연결된 장치가 있을 경우
	if (self.manager.pre_beacon) {
		
		// 버튼 비활성화
		[self.button_scan setEnabled:NO];
		return;
	}
	
	// 버튼 상태가 'Start'일 경우
	if ([self.button_scan.titleLabel.text isEqualToString:@"Start"]) {
		
		// 장치 탐색 중이 아니라면
		if (![self.manager.helper.central isScanning]) {
			
			// 버튼 상태 변경
			[self.button_scan setTitle:@"Stop" forState:UIControlStateNormal];
			// 탐색 시작
			[self.manager scan];
		}
	}
	
	// 버튼 상태가 'Stop'일 경우
	if ([self.button_scan.titleLabel.text isEqualToString:@"Stop"]) {
		
		// 장치 탐색 중이라면
		if ([self.manager.helper.central isScanning]) {
			
			// 버튼 상태 변경
			[self.button_scan setTitle:@"Start" forState:UIControlStateNormal];
			// 탐색 중지
			[self.manager stopScan];
		}
	}
}
/****************************************************************************************/
/*																						*/
/*							장치 검색이 성공했을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)discoveredPeripherals:(CBPeripheral *)peripheral {
	
	// 이전에 연결된 장치가 있을 경우
	if (self.manager.pre_beacon) {
		
		// 이름이 같다면
		if ([[self.manager.pre_beacon name] isEqualToString:peripheral.name]) {
			
			// 장치와 연결
			[[self manager] connect:peripheral];
			return;
		}
	}
	
	// 현재 연결된 장치가 있을 경우
	if ([self.manager.helper beacon]) {
		
		// 이름이 같으면 종료
		if ([[self.manager.helper.beacon name] isEqualToString: [peripheral name]]) {
			
			return;
		}
	}
	
	// 장치가 연결되지 않은 상태일 경우
	if ([peripheral state] == CBPeripheralStateDisconnected) {
	
		// 테이블에 추가
		[self.data_peripherals setObject:peripheral forKey:peripheral.identifier.UUIDString];
		[self refreshTableViewPeripheral];
	}
}
/****************************************************************************************/
/*																						*/
/*								장치와 연결되었을 경우										*/
/*																						*/
/****************************************************************************************/
- (void)connected {
	
	// 후보 정보 초기화
	[self setCandidate: NULL];
	// 이전 연결 정보 초기화
	[self.manager setPre_beacon:NULL];
	// 커넥션 뷰 로드
	[self performSegueWithIdentifier:@"scan_to_conn" sender:self];
}
/****************************************************************************************/
/*																						*/
/*								장치와 연결이 해제되었을 경우									*/
/*																						*/
/****************************************************************************************/
- (void)disconnected:(CBPeripheral *)peripheral {
	
	// 이전 연결 정보 저장
	[self.manager setPre_beacon:peripheral];
	
	// 후보가 존재할 경우
	if ([self candidate]) {
	
		// 후보와 연결 시도
		[self.manager connect:[self candidate]];
	}
	// 그렇지 않으면
	else {
		
		// 메인 뷰 로드
		[self performSegueWithIdentifier:@"scan_to_main" sender:self];
	}
}
/****************************************************************************************/
/*																						*/
/*								세그웨이 실행 전 작업										*/
/*																						*/
/****************************************************************************************/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([[segue identifier] isEqualToString:@"scan_to_main"]) {
		MainViewController *mvc = segue.destinationViewController;
		[mvc setManager: self.manager];
		[mvc.manager.helper setDelegate:mvc];
	}
	if ([[segue identifier] isEqualToString:@"scan_to_conn"]) {
		ConnectionViewController *cvc = segue.destinationViewController;
		[cvc setManager: self.manager];
		[cvc.manager.helper setDelegate:cvc];
	}
}

@end
