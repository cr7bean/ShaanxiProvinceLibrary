//
//  AppDelegate.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/15.
//  Copyright (c) 2015年 Long. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsViewController.h"
#import <SDVersion.h>
#import "NSDate+Tools.h"
#import "GVUserDefaults+library.h"
#import <SSKeychain.h>

# define SERVICE @"figureWang"


@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    if (iOSVersionGreaterThan(@"8")) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories: nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings: settings];
    }
    UILocalNotification *notification = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        application.applicationIconBadgeNumber = 0;
    }
    
    
    // 判断第一次启动，删除保留的 keychain 信息
    if ([GVUserDefaults standardUserDefaults].firstLogin) {
        NSArray *accounts = [SSKeychain accountsForService: SERVICE];
        if (accounts.count) {
            for (NSDictionary *dic in accounts) {
                NSString *account = dic[@"acct"];
                [SSKeychain deletePasswordForService: SERVICE account: account];
            }
        }
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [GVUserDefaults standardUserDefaults].firstLogin = NO;
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    
    // 因为图书馆的限制，在搜索图书相关的页面不能停留3分钟以上，所以从后台启动的时候，要 pop 出相关页面。
    UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
    UINavigationController *controller= tabController.viewControllers[1];
    if (controller.viewControllers.count > 1) {
        [controller popToRootViewControllerAnimated: NO];
    }

    UINavigationController *bookTagConller = tabController.viewControllers[2];
    if (bookTagConller.viewControllers.count > 3) {
        [bookTagConller popToViewController: bookTagConller.viewControllers[2] animated: NO];
    }
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
    NSLog(@"%@", notification);
}

- (void) addLocalNotification
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"还有8本书要到期了";
    notification.alertAction = @"打开应用";
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.repeatInterval = NSCalendarUnitDay;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString: @"2016-05-20 10:00:00"];
//    NSString *dateString = [formatter stringFromDate: [NSDate date]];
//    NSDate *date1 = [NSDate dateWithString: @"2016-05-20"];
    notification.fireDate = date1;
    
    NSLog(@"%@", notification.description);

    [[UIApplication sharedApplication] scheduleLocalNotification: notification];
}

@end
