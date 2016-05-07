//
//  EmptyDataView.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/3.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "EmptyDataView.h"
#import <Masonry.h>

static const CGFloat kTop = 170;
static const CGFloat kinner = 10;


@implementation EmptyDataView

# pragma mark init

- (instancetype) initOnView: (UIView *) view
{
    self = [super init];
    if (self) {
        self.frame = view.frame;
        [view addSubview: self];
        [self addSubviews];
    }
    return self;
}

- (void) addSubviews
{
    _imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 112, 76)];
    _mainLabel = [UILabel new];
    _subLabel  = [UILabel new];
    _refreshButton = [UIButton new];
    
    _subLabel.textColor = [UIColor grayColor];
    _subLabel.font = [UIFont systemFontOfSize: 13];
    [_refreshButton setTitleColor: [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1] forState: UIControlStateNormal];
    
    [self addSubview: _imageView];
    [self addSubview: _mainLabel];
    [self addSubview: _subLabel];
    [self addSubview: _refreshButton];
    
    // layout
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kTop);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [_mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_imageView.mas_bottom).offset(kinner);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_mainLabel.mas_bottom).offset(kinner);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [_refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_subLabel.mas_bottom).offset(kinner);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    [_refreshButton setContentHuggingPriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];
}

# 
- (void) configurateWithMainTitle: (NSString *) mainTitle
                         subtitle: (NSString *) subtitle
                            image: (NSString *) imageName
{
    _mainLabel.text = mainTitle;
    _subLabel.text = subtitle;
    _imageView.image = [UIImage imageNamed: imageName];
    [_refreshButton setTitle: @"重新加载" forState: UIControlStateNormal];
}

- (void) configurateEmptyDataView
{
    [self configurateWithMainTitle: @"网络连接失败" subtitle: @"请检查您的网络，或点击重新加载" image: @"wifi"];
}



@end
