//
//  ConnectionViewController.h
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPManager.h"

#define CID_CONN_TABLE @"cid_conn_table"

@interface ConnectionViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, CBHelperDelegate >

@property (strong, nonatomic) LPManager *manager;
@property (strong, nonatomic) IBOutlet UIButton *button_conn;
@property (strong, nonatomic) IBOutlet UITableView *table_info;
@property (strong, nonatomic) NSMutableArray *data_source;

@end
