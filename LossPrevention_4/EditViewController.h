//
//  EditViewController.h
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPManager.h"
#import "AppDelegate.h"

@interface EditViewController : UIViewController < CBHelperDelegate >

@property (strong, nonatomic) LPManager *manager;

@property (strong, nonatomic) IBOutlet UILabel *label_state;
@property (strong, nonatomic) IBOutlet UIButton *button_none;
@property (strong, nonatomic) IBOutlet UIButton *button_alert;
@property (strong, nonatomic) IBOutlet UIButton *button_warning;
@property (strong, nonatomic) IBOutlet UISwitch *switch_sound;

@end
