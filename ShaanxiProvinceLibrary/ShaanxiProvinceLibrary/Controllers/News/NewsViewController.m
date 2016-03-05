//
//  NewsViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/15.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsView.h"
#import "NewsModel.h"
#import "MottoModel.h"
#import "ParseHTML.h"
#import "NewsTableViewCell.h"
#import <UINavigationBar+Awesome.h>
#import "Helper.h"
#import <Masonry.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <MBProgressHUD.h>

#import "DetailNewsViewController.h"



# define OFFSET_Y -100

@interface NewsViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation NewsViewController
{
    NewsView *_newsTableView;
    NSMutableArray *_newsContentArray;
}

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNewsTableView];
    [self.navigationController.navigationBar lt_setBackgroundColor: [UIColor clearColor]];

    _newsContentArray = [NSMutableArray new];
   
    [ParseHTML parseNewsContentSuccess:^(NSMutableArray *newsContent) {
        _newsContentArray = newsContent;
        [_newsTableView.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"查找新闻失败");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    _newsTableView.tableView.delegate = self;
    [self scrollViewDidScroll: _newsTableView.tableView];
    [self.navigationController.navigationBar setShadowImage: [UIImage new]];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    _newsTableView.tableView.delegate = nil;
    [self.navigationController.navigationBar lt_reset];
}

#pragma mark - addSubView

- (void) addNewsTableView
{
    _newsTableView = [[NewsView alloc] init];
    [_newsTableView.tableView registerClass: [NewsTableViewCell class] forCellReuseIdentifier: @"newsCell"];
    [_newsTableView.tableView registerClass: [UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier: @"headerView"];
    [_newsTableView layoutTableView: self.view];

    _newsTableView.tableView.dataSource = self;
    _newsTableView.tableView.sectionFooterHeight = 0;
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _newsContentArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_newsContentArray[section] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = (NewsTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"newsCell"];
    [self configuteCell: cell atIndexPath: indexPath];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: @"newsCell" cacheByIndexPath: indexPath configuration:^(id cell) {
        [self configuteCell: cell atIndexPath: indexPath];
    }];
}

- (void) configuteCell: (NewsTableViewCell *) cell atIndexPath: (NSIndexPath *) indexPath
{
    NewsModel *news = [NewsModel new];
    NSMutableArray *partNews = _newsContentArray[indexPath.section];
    news = partNews[indexPath.row];
    [cell configurateNewsView: news];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [UITableViewHeaderFooterView new];
     UILabel *headerLabel = [UILabel new];
     NSArray *headerTitle = @[@"公告通知", @"陕图动态", @"陕图讲坛", @"少儿活动"];
    
    [headerView.contentView addSubview: headerLabel];
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(5);
    }];

    headerLabel.text = headerTitle[section];
    [Helper configurateLabel: headerLabel
                   textColor: [UIColor whiteColor]
                        font: [UIFont systemFontOfSize: 18]
                      number: 0
                   alignment: NSTextAlignmentLeft];
    
    headerView.contentView.backgroundColor = [Helper setColorWithRed: 0 green: 175 blue: 240];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 31.5;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];

    NewsModel *news = [NewsModel new];
    NSMutableArray *partNews = _newsContentArray[indexPath.section];
    news = partNews[indexPath.row];

    DetailNewsViewController *webController = [[DetailNewsViewController alloc] initWithAddress: news.detailUrl];
    webController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: webController animated: YES];
  
}


#pragma mark - configurate navigationBar

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor *color = [Helper setColorWithRed: 0 green: 175 blue: 240];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > OFFSET_Y) {
        CGFloat alpha = MIN(1, 1-(OFFSET_Y + 64- offsetY) / 64);
        [self.navigationController.navigationBar lt_setBackgroundColor: [color colorWithAlphaComponent: alpha]];
    }else{
        [self.navigationController.navigationBar lt_setBackgroundColor: [color colorWithAlphaComponent: 0]];
    }
    
}

@end