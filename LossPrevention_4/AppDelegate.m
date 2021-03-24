//
//  AppDelegate.m
//  LossPrevention
//
//  Created by Youngwoon Lee on 6/26/16.
//  Copyright © 2016 VICL. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ScanViewController.h"
#import "EditViewController.h"
#import "ConnectionViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/****************************************************************************************/
/*																						*/
/*						어플리케이션이 처음 메모리상에 올라가게 될 때							*/
/*																						*/
/****************************************************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	MainViewController *mvc = (MainViewController *)self.window.rootViewController;
	[self setManager:[[LPManager alloc] init]];
	[mvc setManager: [self manager]];
	[[[self manager] helper] setDelegate: mvc];
	
	return YES;
}
/****************************************************************************************/
/*																						*/
/*				어플리케이션이 백그라운드로 들어가기 직전(홈버튼을 누른 경우)에 호출					*/
/*																						*/
/****************************************************************************************/
- (void)applicationWillResignActive:(UIApplication *)application {
	
}
/****************************************************************************************/
/*																						*/
/*						어플리케이션이 백그라운드로 완전히 들어갔을 때 호출						*/
/*																						*/
/****************************************************************************************/
- (void)applicationDidEnterBackground:(UIApplication *)application {

}
/****************************************************************************************/
/*																						*/
/*						어플리케이션이 다시 활성화되기 직전에 호출								*/
/*																						*/
/****************************************************************************************/
- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}
/****************************************************************************************/
/*																						*/
/*						어플리케이션이 다시 활성화된 후 호출									*/
/*																						*/
/****************************************************************************************/
- (void)applicationDidBecomeActive:(UIApplication *)application {
	
}
/****************************************************************************************/
/*																						*/
/*						어플리케이션이 완전히 종료되기 직전에 호출								*/
/*																						*/
/****************************************************************************************/
- (void)applicationWillTerminate:(UIApplication *)application {
	
}
/****************************************************************************************/
/*																						*/
/*						LocalNotificaiton 확인 버튼을 눌렀을 경우 호출						*/
/*																						*/
/****************************************************************************************/
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

	// 통지 메시지 초기화
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
