//
//  NewsView.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/17.
//  Copyright (c) 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MottoModel.h"

@interface NewsView : UIView

@property (nonatomic, strong) UITableView *tableView;

- (void) configurateHeaderView: (MottoModel*) motto;
- (void) layoutTableView: (UIView*) View;
@end
