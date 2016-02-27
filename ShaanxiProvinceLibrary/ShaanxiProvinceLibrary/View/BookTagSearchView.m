//
//  BookTagSearchView.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/2/27.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "BookTagSearchView.h"

@implementation BookTagSearchView
{
    CGFloat _stausBarHeight;
    
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        
        [self initSearchBar];
    }
    return self;
}

- (void) initSearchBar
{
    UIColor *color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1];

    _stausBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _viewHeight = _stausBarHeight + 44;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, _stausBarHeight, _screenWidth, 44)];
    self.searchBar.showsCancelButton = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    // 更改searchBar外围的颜色
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [color CGColor];
    self.searchBar.placeholder = @"输入您喜欢的书籍类型";
    
    // 更改 searchBar Cancel 字体颜色
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    
    
    _titleView = [[UIView alloc] initWithFrame: CGRectMake(0, -_viewHeight, _screenWidth, _viewHeight)];
    [_titleView addSubview: _searchBar];
    [self addSubview: _titleView];
    
    _titleView.backgroundColor = color;
    self.searchBar.barTintColor = color;
}

@end
