//
//  HotSearchingBooksView.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/28.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotSearchingBooksView : UIView

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
- (instancetype) initWithView: (UIView *) view;

@end
