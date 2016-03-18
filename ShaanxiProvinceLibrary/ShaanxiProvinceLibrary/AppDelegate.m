//
//  AppDelegate.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/15.
//  Copyright (c) 2015年 Long. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsViewController.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
