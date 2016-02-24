//
//  BookTagCollectionReusableView.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/30.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookTagCollectionReusableView.h"
#import <Masonry.h>

@implementation BookTagCollectionReusableView
{
    UILabel *_label;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        _label = [UILabel new];
        _label.font = [UIFont systemFontOfSize: 15];
        [self addSubview: _label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.bottom.mas_equalTo(0);
        }];
        
        
        UIView *upLine = [UIView new];
        UIView *downLine = [UIView new];
        [self addSubview: upLine];
        [self addSubview: downLine];
        upLine.backgroundColor = [UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.0];
        downLine.backgroundColor = [UIColor colorWithRed:0.784 green:0.780 blue:0.800 alpha:1.0]                      ;
        
        [upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
        [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
        
    }
    return self;
}

- (void) setTitle:(NSString *)title
{
    _label.text = title;
}

@end
