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

#import "DetailNewsViewController.h"
#import <SVWebViewController.h>


# define OFFSET_Y -100

@interface NewsViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation NewsViewController
{
    NewsView *_newsTableView;
    NSMutableDictionary *_cellHeightDic;
    NSMutableArray *_newsContentArray;
}

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNewsTableView];
    [self.navigationController.navigationBar lt_setBackgroundColor: [UIColor clearColor]];
    
    _cellHeightDic = [NSMutableDictionary new];
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
    
//    _newsTableView.tableView.delegate = self;
    _newsTableView.tableView.dataSource = self;
   
    _newsTableView.tableView.estimatedRowHeight = 100;
    _newsTableView.tableView.sectionFooterHeight = 0;
}

#pragma mark - tableView DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
//    return 4;
    return _newsContentArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 7;
    return [_newsContentArray[section] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = (NewsTableViewCell*)[tableView dequeueReusableHeaderFooterViewWithIdentifier: @"newsCell"];
    if (!cell) {
        cell = [[NewsTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier: @"newsCell"];
    }
    NewsModel *news = [NewsModel new];
    NSMutableArray *partNews = _newsContentArray[indexPath.section];
    news = partNews[indexPath.row];
    [cell configurateNewsView: news];
    
 
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
////    CGFloat newHeight = [cell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize].height + 1;
//    [_cellHeightDic setObject: @(cell.Height) forKey: [NSString stringWithFormat: @"%ld", (long)indexPath.row]];
    
    //判断行高缓存
    CGFloat oldHeight = [[_cellHeightDic objectForKey: [NSString stringWithFormat: @"%ld%ld", (long)indexPath.section, (long)indexPath.row]] floatValue];
    if (!oldHeight) {
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat newHeight = [cell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize].height + 1;
        [_cellHeightDic setObject: @(newHeight) forKey: [NSString stringWithFormat: @"%ld%ld", (long)indexPath.section, (long)indexPath.row]];
        }
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = [[_cellHeightDic objectForKey: [NSString stringWithFormat: @"%ld%ld", (long)indexPath.section, (long)indexPath.row]] floatValue];
    if (cellHeight) {
          return cellHeight;
    }else
    return 100;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//     UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier: @"headerView"];
    UITableViewHeaderFooterView *headerView = [UITableViewHeaderFooterView new];
     UILabel *headerLabel = [UILabel new];
     NSArray *headerTitle = @[@"公告通知", @"陕图动态", @"陕图讲坛", @"少儿活动"];
    
    [headerView.contentView addSubview: headerLabel];
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(5);
    }];

//    if (!headerLabel) {
//        headerLabel = [UILabel new];
//        [headerView.contentView addSubview: headerLabel];
//        [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(25);
//            make.top.mas_equalTo(5);
//        }];
//    }
     headerLabel.text = nil;
     [Helper configurateLabel: headerLabel text: headerTitle[section] textColor: [UIColor whiteColor] font: [UIFont systemFontOfSize: 18] textAlignment: NSTextAlignmentLeft];
    
    
//            make.right.mas_equalTo(-15);
//            make.bottom.mas_equalTo(-5);
    
//        [HeaderLabel setContentHuggingPriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];
//        CGFloat headerHeight = [headerView.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize].height;
//        NSLog(@"%f", headerHeight);
//    }
    
    headerView.contentView.backgroundColor = [Helper setColorWithRed: 0 green: 175 blue: 240];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 31.5;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];

    NewsModel *news = [NewsModel new];
    NSMutableArray *partNews = _newsContentArray[indexPath.section];
    news = partNews[indexPath.row];

    DetailNewsViewController *webController = [[DetailNewsViewController alloc] initWithAddress: news.detailUrl];
    webController.hidesBottomBarWhenPushed = YES;

//    SVWebViewController *webController = [[SVWebViewController alloc] initWithAddress: news.detailUrl];
    
    
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
