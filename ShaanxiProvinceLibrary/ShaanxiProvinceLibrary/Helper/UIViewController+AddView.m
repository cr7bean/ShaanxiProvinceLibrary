//
//  UIViewController+AddView.m
//  pushTest
//
//  Created by figure2008 on 16/4/10.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "UIViewController+AddView.h"
#import "HudView.h"

#import <objc/runtime.h>

@interface UIViewController ()

@property (nonatomic, strong) HudView *hud;

@end

@implementation UIViewController (AddView)



# pragma mark HudView

- (HudView *) hud
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void) setHud:(MBProgressHUD *)hud
{
    return objc_setAssociatedObject(self, @selector(hud), hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) rl_addHudView
{
    self.hud = [HudView showHudOnView: self.view];
}

- (void) rl_removeHudView
{
    [self.hud hideHudView];
}

@end
