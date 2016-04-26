//
//  HudView.h
//  pushTest
//
//  Created by figure2008 on 16/4/26.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+ (instancetype) showHudOnView:(UIView *)view;
- (void) hideHudView;

@end
