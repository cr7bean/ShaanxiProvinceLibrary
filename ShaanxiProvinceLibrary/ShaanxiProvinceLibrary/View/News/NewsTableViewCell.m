//
//  NewsTableViewCell.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/22.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "NewsTableViewCell.h"
#import <Masonry.h>
#import "Helper.h"

@implementation NewsTableViewCell
{
    UIView *_newsView;
    UILabel *_titleLabel;
    

    
}

#pragma mark - init

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        [self initSubView];
        [self setConstraint];
    }
    return self;
}

- (void) initSubView
{
     _newsView = [UIView new];
    _titleLabel = [UILabel new];
    [Helper configurateLabel: _titleLabel
                   textColor: [UIColor blackColor]
                        font: [UIFont systemFontOfSize: 17]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    
    [self.contentView addSubview: _newsView];
    [_newsView addSubview: _titleLabel];
    self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    

}

- (void) setConstraint
{
    [_newsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 30;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(18);
        make.bottom.mas_equalTo(-18).priority(749);
    }];
}

#pragma mark - configurate content and layout

- (void) configurateNewsView: (NewsModel*) news
{
    _titleLabel.text = news.title;
    if (news.isCued) {
        
        _titleLabel.textColor = [UIColor redColor];
    }else{
        _titleLabel.textColor = [UIColor blackColor];
    }
}

@end
