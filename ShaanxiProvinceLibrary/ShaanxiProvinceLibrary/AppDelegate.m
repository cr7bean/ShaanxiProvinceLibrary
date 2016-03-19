//
//  AppDelegate.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/15.
//  Copyright (c) 2015年 Long. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsViewController.h"

#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "HubInfo.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //推送消息
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
                                                             notificationHubPath:HUBNAME];
    [hub registerNativeWithDeviceToken:deviceToken tags:[NSSet setWithObject:@"wang"] completion:^(NSError* error) {
        NSLog(@"%@", error);
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
        else {
            [self MessageBox:@"Registration Status" message:@"Registered"];
        }
    }];
}

-(void)MessageBox:(NSString *)title message:(NSString *)messageText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:messageText delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    [self MessageBox:@"Notification" message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
  
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
