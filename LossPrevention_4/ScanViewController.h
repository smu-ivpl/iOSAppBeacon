//
//  ScanViewController.h
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LPManager.h"
#import "AppDelegate.h"

#define CID_EDIT_TABLE @"cid_edit_table"

@interface ScanViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, CBHelperDelegate >

@property (strong, nonatomic) LPManager *manager;
@property (strong, nonatomic) IBOutlet UIButton *button_scan;
@property (strong, nonatomic) IBOutlet UITableView *table_peripherals;
@property (strong, nonatomic) NSArray *data_source;
@property (strong, nonatomic) NSMutableDictionary<NSString *, id> *data_peripherals;
@property (strong, nonatomic) CBPeripheral *candidate;

@end
