//
//  BookContentTableViewCell.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/20.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookContentTableViewCell.h"
#import "Helper.h"
#import <Masonry.h>

@implementation BookContentTableViewCell
{
    UIView *_bookContentView;
    UILabel *_label;
}

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
    _bookContentView = [UIView new];
    _label = [UILabel new];
    
    [self.contentView addSubview: _bookContentView];
    [_bookContentView addSubview: _label];
    
    [Helper configurateLabel: _label
                   textColor: [UIColor blackColor]
                        font: [UIFont systemFontOfSize: 15]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    _label.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 15*2;
    
    [_bookContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.right.mas_equalTo(-15).priority(749);
        make.bottom.mas_equalTo(-15).priority(751);
    }];
}


- (void) configureCell: (NSDictionary *) bookContentDic
           atIndexPath: (NSIndexPath *) indexPath
             
{
    NSMutableArray *bookRightInfoArray = bookContentDic[@"bookRightInfo"];
    NSMutableArray *bookLocationArray = bookContentDic[@"bookLocation"];
    NSMutableArray *bookSummaryArray = bookContentDic[@"bookSummary"];
    
    switch (indexPath.section) {
        case 0:
            _label.text = bookRightInfoArray[indexPath.row];
        break;
        case 1:
            if ([bookLocationArray[indexPath.row] isKindOfClass: [NSString class]]) {
                _label.text = bookLocationArray[indexPath.row];
            }else{
                _label.attributedText = bookLocationArray[indexPath.row];
            }
        break;
        case 2:
            _label.text = bookSummaryArray[indexPath.row];
        break;
    }
}

@end
