//
//  DoubanContentTableViewCell.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/24.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "DoubanContentTableViewCell.h"
#import "Helper.h"
#import "DoubanBookModel.h"
#import <Masonry.h>
#import <UIImageView+AFNetworking.h>
#import <UIView+FDCollapsibleConstraints.h>


static const CGFloat KTopAndBottom = 15.0f;
static const CGFloat kLeft = 15.0f;
static const CGFloat kRight = 10.0f;
static const CGFloat kInner = 10.0f;


@implementation DoubanContentTableViewCell
{
    
    UIView *_titleView;
    
    UILabel *_titleLabel;
    UILabel *_authorLabel;
    UILabel *_publisherLabel;
    UILabel *_pubdateLabel;
    UILabel *_pagesLabel;
    UILabel *_priceLabel;
    UILabel *_bindingLabel;
    UILabel *_ratingLabel;
    UIImageView *_coverImage;
    
//    UILabel *_summaryLabel;
    

}

#pragma mark - init

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        [self initSubView];
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (UIEdgeInsets) layoutMargins
{
    return UIEdgeInsetsZero;
}


- (void) initSubView
{
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - kLeft - kRight;
    
    _titleView = [UIView new];
    
    _titleLabel = [UILabel new];
    _authorLabel = [UILabel new];
    _publisherLabel = [UILabel new];
    _pubdateLabel = [UILabel new];
    _pagesLabel = [UILabel new];
    _priceLabel = [UILabel new];
    _bindingLabel = [UILabel new];
    _ratingLabel = [UILabel new];
    _coverImage = [UIImageView new];
    
    _summaryLabel = [UILabel new];
    
    
    _authorLabel.font = [UIFont systemFontOfSize: 13];
    _publisherLabel.font = [UIFont systemFontOfSize: 13];
    _pubdateLabel.font = [UIFont systemFontOfSize: 13];
    _pagesLabel.font = [UIFont systemFontOfSize: 13];
    _priceLabel.font = [UIFont systemFontOfSize: 13];
    _bindingLabel.font = [UIFont systemFontOfSize: 13];
    _ratingLabel.font = [UIFont systemFontOfSize: 13];
    _coverImage.contentMode = UIViewContentModeScaleAspectFit;
    
    _titleLabel.preferredMaxLayoutWidth = maxWidth;
    _summaryLabel.preferredMaxLayoutWidth = maxWidth;
   
    [Helper configurateLabel: _titleLabel
                   textColor: [UIColor blackColor]
                        font: [UIFont boldSystemFontOfSize: 17]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    
    [Helper configurateLabel: _summaryLabel
                   textColor: [UIColor blackColor]
                        font: [UIFont systemFontOfSize: 15]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    
    [self.contentView addSubview: _summaryLabel];
    [self.contentView addSubview: _titleView];
    
    
    [_titleView addSubview: _titleLabel];
    [_titleView addSubview: _authorLabel];
    [_titleView addSubview: _publisherLabel];
    [_titleView addSubview: _pubdateLabel];
    [_titleView addSubview: _pagesLabel];
    [_titleView addSubview: _priceLabel];
    [_titleView addSubview: _bindingLabel];
    [_titleView addSubview: _ratingLabel];
    [_titleView addSubview: _coverImage];
}


#pragma mark - titleCell

- (void) titleCell: (DoubanBookModel *) bookmodel
{
    
    
    NSString *author = @"作者:  ";
    NSString *publisher = @"出版社:  ";
    NSString *pubdate = @"出版日期:  ";
    NSString *pages = @"页数:  ";
    NSString *price = @"价格:  ";
    NSString *binding = @"包装:  ";
    NSString *rating = @"评分:  ";
    
    if (bookmodel.author) {
        author = [author stringByAppendingString: bookmodel.author];
    }
    if (bookmodel.publisher) {
        publisher = [publisher stringByAppendingString: bookmodel.publisher];
        NSRange range = [publisher rangeOfString: @","];
        if (range.length) {
           publisher = [publisher substringToIndex: range.location];
        }
    }
    if (bookmodel.pubdate) {
        pubdate = [pubdate stringByAppendingString: bookmodel.pubdate];
    }
    if (bookmodel.pages) {
        pages = [pages stringByAppendingString: bookmodel.pages];
    }
    if (bookmodel.price) {
        price = [price stringByAppendingString: bookmodel.price];
    }
    if (bookmodel.binding) {
        binding = [binding stringByAppendingString: bookmodel.binding];
    }
    if ([bookmodel.rating isEqualToString: @"0.0"]) {
        rating = [rating stringByAppendingString: @"暂无评分"];
    }else{
        rating = [rating stringByAppendingString: bookmodel.rating];
    }

    _titleLabel.text = bookmodel.title;
    _authorLabel.text = author;
    _publisherLabel.text = publisher;
    _pubdateLabel.text = pubdate;
    _pagesLabel.text = pages;
    _priceLabel.text = price;
    _bindingLabel.text = binding;
    _ratingLabel.text = rating;
    [_coverImage setImageWithURL: [NSURL URLWithString: bookmodel.imageString]];
    
    [self layoutTitleCell];
}

- (void) layoutTitleCell
{
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KTopAndBottom);
        make.left.mas_equalTo(kLeft);
        make.right.mas_equalTo(-kRight).priority(751);
    }];
    [_authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
    }];
    [_publisherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_authorLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
    }];
    [_pubdateLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.mas_equalTo(_publisherLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
    }];
    [_pagesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_pubdateLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
    }];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_pagesLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
    }];
    [_bindingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_priceLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
    }];
    [_ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_bindingLabel.mas_bottom).offset(kInner);
        make.left.mas_equalTo(kLeft);
        make.bottom.mas_equalTo(-KTopAndBottom).priority(751);
    }];
    
    [_coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_publisherLabel.text.length < _authorLabel.text.length) {
            make.top.mas_equalTo(_authorLabel.mas_bottom).offset(kInner);
        } else {
            make.top.mas_equalTo(_titleLabel.mas_bottom).offset(kInner);
        }
    
        if (_publisherLabel.text.length == 6) {
            make.width.mas_equalTo(130);
        }else{
            make.left.mas_equalTo(_publisherLabel.mas_right).offset(kInner*2);
        }
        make.right.mas_equalTo(-kRight).priority(752);
        make.bottom.mas_equalTo(-KTopAndBottom).priority(751);
    }];
    
    [self setVerticalContentHugging: _titleLabel];
    [self setVerticalContentHugging: _authorLabel];
    [self setVerticalContentHugging: _publisherLabel];
    [self setVerticalContentHugging: _pubdateLabel];
    [self setVerticalContentHugging: _pagesLabel];
    [self setVerticalContentHugging: _priceLabel];
    [self setVerticalContentHugging: _bindingLabel];
    [self setVerticalContentHugging: _ratingLabel];
    
//    _coverImage.backgroundColor = [UIColor grayColor];
//    _publisherLabel.backgroundColor = [UIColor redColor];
 
}

- (void) setVerticalContentHugging: (UILabel *) label
{
    [label setContentHuggingPriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];
}


#pragma mark - authorIntro cell

- (void) summaryCell: (NSString *) content
{

    [_summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KTopAndBottom);
        make.left.mas_equalTo(kLeft);
        make.right.mas_equalTo(-kRight).priority(751);
        make.bottom.mas_equalTo(-KTopAndBottom).priority(749);
    }];
    _summaryLabel.text = content;
}


# pragma mark - bookTagListCell

- (void) configurateBookTagListCell: (DoubanBookModel *) bookModel
{
    static CGFloat kHorizontalInner = 10.0f;
    static CGFloat kVerticalInner = 5.0f;
    
    //setTextColor
    _authorLabel.textColor = [UIColor grayColor];
    _publisherLabel.textColor = [UIColor grayColor];
    _pubdateLabel.textColor = [UIColor grayColor];
    _summaryLabel.textColor = [UIColor grayColor];
    _summaryLabel.font = [UIFont systemFontOfSize: 11];
    
    //setMaxWidth
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 112.5 - kLeft - kInner - kRight;
    _titleLabel.preferredMaxLayoutWidth = maxWidth;
    _authorLabel.preferredMaxLayoutWidth = maxWidth;
    _publisherLabel.preferredMaxLayoutWidth = maxWidth;
    _summaryLabel.preferredMaxLayoutWidth = maxWidth;
    
    _authorLabel.numberOfLines = 0;
    _publisherLabel.numberOfLines = 0;
    
    //setContent
    [_coverImage setImageWithURL: [NSURL URLWithString: bookModel.imageString]];
    
    _titleLabel.text = bookModel.title;
    _authorLabel.text = bookModel.author;
    _publisherLabel.text = bookModel.publisher;
    _pubdateLabel.text = bookModel.pubdate;
    _summaryLabel.text = bookModel.summary;
    

    //setConstraints
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [_coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KTopAndBottom);
        make.left.mas_equalTo(kLeft);
        make.width.mas_equalTo(112.5);
        make.height.mas_equalTo(160);
        make.bottom.mas_equalTo(-KTopAndBottom);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KTopAndBottom);
        make.left.equalTo(_coverImage.mas_right).offset(kHorizontalInner);
        make.right.mas_equalTo(-kRight);
    }];
    [_authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(kVerticalInner);
        make.left.equalTo(_coverImage.mas_right).offset(kHorizontalInner);
        make.right.mas_equalTo(-kRight).priority(749);
    }];
    [_publisherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_authorLabel.mas_bottom).offset(kVerticalInner);
        make.left.equalTo(_coverImage.mas_right).offset(kHorizontalInner);
        make.right.mas_equalTo(-kRight);
        make.bottom.mas_equalTo(-KTopAndBottom).priorityLow();
    }];
    [_pubdateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_publisherLabel.mas_bottom).offset(kVerticalInner);
        make.left.equalTo(_coverImage.mas_right).offset(kHorizontalInner);
    }];
    [_summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pubdateLabel.mas_bottom).offset(kVerticalInner);
        make.left.equalTo(_coverImage.mas_right).offset(kHorizontalInner);
        make.right.mas_equalTo(-kRight);
        make.bottom.mas_equalTo(-KTopAndBottom).priority(751);
    }];
    
//    _titleView.backgroundColor = [UIColor redColor];
//    self.contentView.backgroundColor = [UIColor greenColor];
    
//    _coverImage.backgroundColor = [UIColor grayColor];
//    _titleLabel.backgroundColor = [UIColor grayColor];
//    _authorLabel.backgroundColor = [UIColor greenColor];
//    _publisherLabel.backgroundColor = [UIColor redColor];
//    _pubdateLabel.backgroundColor = [UIColor blueColor];
//    _summaryLabel.backgroundColor = [UIColor lightGrayColor];
    
    [self setVerticalContentHugging: _titleLabel];
    [self setVerticalContentHugging: _authorLabel];
    [self setVerticalContentHugging: _publisherLabel];
    [self setVerticalContentHugging: _pubdateLabel];
    
    [self setVerticalContentHugging: _summaryLabel];
    [_summaryLabel setContentCompressionResistancePriority: UILayoutPriorityDefaultLow forAxis: UILayoutConstraintAxisVertical];
}

@end
