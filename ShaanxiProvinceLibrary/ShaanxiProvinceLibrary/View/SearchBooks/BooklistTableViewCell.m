//
//  BooklistTableViewCell.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/14.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BooklistTableViewCell.h"
#import "BookListModel.h"
#import "Helper.h"
#import <Masonry.h>

static const CGFloat KTopAndBottom = 15.0f;
static const CGFloat kLeft = 15.0f;
static const CGFloat kRight = 10.0f;
static const CGFloat kInner = 10.0f;
static const CGFloat kOffset = 5.0f;

#define kMaxLength [UIScreen mainScreen].bounds.size.width - 55



@implementation BooklistTableViewCell
{
    UILabel *_number;
    UILabel *_authorAndTitle;
    UILabel *_callNumber;
    UILabel *_publicationDate;
    UILabel *_libraryHoldings;
    UIView *_booklistView;
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
    _booklistView = [UIView new];
    _number = [UILabel new];
    _authorAndTitle = [UILabel new];
    _callNumber = [UILabel new];
    _publicationDate = [UILabel new];
    _libraryHoldings = [UILabel new];
    
    [self.contentView addSubview: _booklistView];
    [_booklistView addSubview: _number];
    [_booklistView addSubview: _authorAndTitle];
    [_booklistView addSubview: _callNumber];
    [_booklistView addSubview: _publicationDate];
    [_booklistView addSubview: _libraryHoldings];
    
    [Helper configurateLabel: _number
                   textColor: [UIColor grayColor]
                        font: [UIFont systemFontOfSize: 13]
                      number: 1
                   alignment: NSTextAlignmentRight];
    
    [Helper configurateLabel: _authorAndTitle
                   textColor: [UIColor blackColor]
                        font: [UIFont boldSystemFontOfSize: 17]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    _authorAndTitle.preferredMaxLayoutWidth = kMaxLength;
    _libraryHoldings.preferredMaxLayoutWidth = kMaxLength - 30;
    
    [Helper configurateLabel: _callNumber
                   textColor: [UIColor grayColor]
                        font: [UIFont systemFontOfSize: 13]
                      number: 1
                   alignment: NSTextAlignmentLeft];
    
    [Helper configurateLabel: _publicationDate
                   textColor: [UIColor grayColor]
                        font: [UIFont systemFontOfSize: 13]
                      number: 1
                   alignment: NSTextAlignmentLeft];
    
    [Helper configurateLabel: _libraryHoldings
                   textColor: [UIColor grayColor]
                        font: [UIFont systemFontOfSize: 13]
                      number: 0
                   alignment: NSTextAlignmentLeft];
}

- (void) setConstraint
{
    [_booklistView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [_number mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KTopAndBottom).with.priority(749);
        make.right.mas_equalTo(-kRight);
    }];
    [_authorAndTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(KTopAndBottom);
        make.left.mas_equalTo(kLeft);
        make.right.mas_equalTo(_number.mas_left).with.offset(-kOffset).priority(749);
    }];
    [_publicationDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeft);
        make.top.mas_equalTo(_authorAndTitle.mas_bottom).offset(kInner);
    }];
    [_callNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeft);
        make.top.mas_equalTo(_publicationDate.mas_bottom).offset(kInner);
    }];
    [_libraryHoldings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeft);
        make.top.mas_equalTo(_callNumber.mas_bottom).offset(kInner);
        make.bottom.mas_equalTo(-KTopAndBottom).with.priority(749);
    }];
}
    
- (void) setBooklistModel:(BookListModel *)booklistModel
{
    //配置 Label
    _number.text = booklistModel.number;
    _authorAndTitle.text = booklistModel.authorAndTitle;
    _callNumber.text = booklistModel.callNumber;
    _publicationDate.text = booklistModel.publicationDate;
    _libraryHoldings.text = booklistModel.libraryHoldings;
    
}


@end
