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
    }
    return self;
}

- (void) initSubView
{
     _newsView = [UIView new];
    
    _titleLabel = [UILabel new];
    [self.contentView addSubview: _newsView];
    [_newsView addSubview: _titleLabel];
    self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    

}

- (void) layoutSubviews
{
    
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _titleLabel.preferredMaxLayoutWidth = screenSize.width - 20 - 15;

    CGSize titleSize = _titleLabel.intrinsicContentSize;
    self.Height = _titleLabel.frame.origin.y + titleSize.height+15;

}

#pragma mark - configurate content and layout

- (void) configurateNewsView: (NewsModel*) news
{
    [_newsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    

    [Helper configurateLabel: _titleLabel text: news.title textColor: [UIColor blackColor] font: [UIFont systemFontOfSize: 17] textAlignment:(NSTextAlignmentLeft)];

    if (news.isCued) {
        
        _titleLabel.textColor = [UIColor redColor];
    }else{
        _titleLabel.textColor = [UIColor blackColor];
    }

    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(15);
        make.bottom.mas_equalTo(-15);
    }];
    [_titleLabel setContentHuggingPriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];
    
}

@end
