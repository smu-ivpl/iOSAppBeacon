//
//  MainViewController.h
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPManager.h"

@interface MainViewController : UIViewController < CBHelperDelegate >

@property (strong, nonatomic) LPManager *manager;

@property (strong, nonatomic) IBOutlet UILabel *label_rssi;
@property (strong, nonatomic) IBOutlet UILabel *label_name;
@property (strong, nonatomic) IBOutlet UILabel *label_battery;
@property (strong, nonatomic) IBOutlet UIButton *button_bell;
@property (strong, nonatomic) IBOutlet UIButton *button_battery;
@property (strong, nonatomic) IBOutlet UIButton *button_remove;

@end
