//
//  HotSearchingBooksView.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/28.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "HotSearchingBooksView.h"
#import <Masonry.h>
#import "Helper.h"

@implementation HotSearchingBooksView
{
    UIView *_mainView;
}

- (instancetype) initWithView: (UIView *) view
{
    self = [super init];
    if (self) {
        [self initSubView: view];
    }
    return self;
}

- (void) initSubView: (UIView *) view
{
    _mainView = [UIView new];
    _searchBar = [UISearchBar new];
    _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStylePlain];
    
    [view addSubview: _mainView];
    [_mainView addSubview: _searchBar];
    [_mainView addSubview: _tableView];
   
    //configurate searchbar

    _searchBar.showsScopeBar = YES;
    _searchBar.showsCancelButton = YES;
    _searchBar.scopeButtonTitles = @[@"题名", @"著者", @"主题", @"期刊名"];
    _searchBar.tintColor = [Helper setColorWithRed: 249 green:249 blue:249];
    _searchBar.barTintColor = [Helper setColorWithRed: 0 green: 175 blue: 240];
    
       //layout
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(20, 0, 0, 0));
    }];
    
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        
        make.height.mas_equalTo(88);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchBar.mas_bottom).with.offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        
    }];
    
    

}

@end
