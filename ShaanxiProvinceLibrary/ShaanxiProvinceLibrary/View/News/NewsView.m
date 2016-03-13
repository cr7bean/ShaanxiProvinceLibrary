//
//  NewsView.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/17.
//  Copyright (c) 2015年 Long. All rights reserved.
//

#import "NewsView.h"
#import <UIKit+AFNetworking.h>
#import <Masonry.h>
#import "Helper.h"
#import "ParseHTML.h"

#define IMAGE_SCALE 439.0/658


@implementation NewsView
{
    UIImageView  *_headerView;
    UILabel *_sayingLabel;
    UILabel *_personageLabel;
    CGSize _screenSize;
}

#pragma mark - init

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void) initSubViews
{
   
    _headerView = [UIImageView new];
    
    _sayingLabel = [UILabel new];
    _personageLabel = [UILabel new];
    self.tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
    
    [_headerView addSubview: _sayingLabel];
    [_headerView addSubview: _personageLabel];

    _screenSize = [UIScreen mainScreen].bounds.size;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setContentInset:UIEdgeInsetsMake(_screenSize.width*IMAGE_SCALE, 0, 0, 0)];
    self.tableView.contentOffset = CGPointMake(0, -_screenSize.width*IMAGE_SCALE);
    
}



#pragma mark - layout

- (void) layoutTableView: (UIView*) View
{
    [self layoutHeaderView: View];

    [View addSubview: self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
//    MottoModel *motto = [MottoModel new];
//    motto.saying = @"如果你浪费了自己的年龄，那是挺可悲的。因为你的青春只能持续一点儿时间，很短的一点儿时间。";
//    motto.personage = @"—— 王尔德";
//    [self configurateHeaderView: motto];
    
    
   //从网上抓取图片和文字放在首页
    [ParseHTML parseMottoAndImage:^(MottoModel *motto) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        
        [self configurateHeaderView: motto];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"查找首页图片失败");
        
    }];
    
    
}

- (void) layoutHeaderView: (UIView*) view
{
    [view addSubview: _headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(view.mas_width);
        make.height.mas_equalTo(_headerView.mas_width).multipliedBy(IMAGE_SCALE);
    }];

    [_personageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
    }];

    [_sayingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.equalTo(_personageLabel.mas_top).with.offset(-10);
        
    }];
    
}

#pragma mark - configurate HeaderView content

- (void) configurateHeaderView: (MottoModel*) motto
{
    _sayingLabel.text = motto.saying;
    _personageLabel.text = motto.personage;
    
    [Helper configurateLabel: _sayingLabel
                   textColor: [UIColor whiteColor]
                        font: [UIFont systemFontOfSize: 13]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    
    [Helper configurateLabel: _personageLabel
                   textColor: [UIColor whiteColor]
                        font: [UIFont systemFontOfSize: 13]
                      number: 1
                   alignment: NSTextAlignmentRight];

    [_headerView setImageWithURL: [NSURL URLWithString: motto.imageName] placeholderImage: [UIImage imageNamed: @"1"]];
    
//    [_headerView setImage: [UIImage imageNamed: @"1"]];
//    _headerView.backgroundColor = [UIColor greenColor];
}

@end
