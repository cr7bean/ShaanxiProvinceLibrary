//
//  BookTagListViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/1/18.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "BookTagListViewController.h"
#import <Masonry.h>
#import "ParseHTML.h"
#import "DoubanBookModel.h"
#import "DoubanContentTableViewCell.h"
#import "Helper.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface BookTagListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) contentType contentType;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *bookListArray;

@end

@implementation BookTagListViewController

# pragma mark - lifeCycle

- (void) loadView
{
    UIView *view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view = view;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"tagListCell"];
    self.title = _tagName;
    [self loadBooklistContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (instancetype) initWithTagName: (NSString *) tagName
                     contentType: (contentType) type
{
    self = [super init];
    if (self) {
        _tagName = tagName;
        _contentType = type;
    }
    return self;
}

#pragma mark - getter

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview: _tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _tableView;
}

- (NSMutableArray *) bookListArray
{
    if (!_bookListArray) {
        _bookListArray = [NSMutableArray new];
    }
    return _bookListArray;
}

#pragma mark - loadBooklistContent

- (void) loadBooklistContent
{
    
    switch (_contentType) {
        case contentTypeDoubanTag: {
            [self DoubanContent: 0 type: @"T"];
            
            break;
        }
        case contentTypeAmazon: {
            [self AmazonContent: 1];
            break;
        }
        case contentTypeJD: {
            [self JDContent: 1];
            break;
        }
        case contentTypeDD: {
            [self DDContent: 1];
            break;
        }
    }
}


/**
 *  豆瓣标签对应的书籍
 *
 *  @param startNumber 网络请求时的起始页码
 *  @param typeName 书排序类型（综合排序：T,出版日期排序：R，评价排序：S）
 */
- (void) DoubanContent: (NSUInteger) startNumber
                  type: (NSString *) typeName
{
    NSString *urlString = @"http://book.douban.com/tag/";
    urlString = [urlString stringByAppendingFormat: @"%@", _tagName];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *paraments = @{@"start": [NSNumber numberWithInteger: startNumber],
                                @"type": typeName};
    [ParseHTML searchBookWithTagInUrl: urlString paraments: paraments successs:^(NSMutableArray *bookArray) {
        [self.bookListArray addObjectsFromArray: bookArray];
        [self.tableView reloadData];
        

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

/**
 *  亚马逊图书榜单
 *
 *  @param page 页码
 */
- (void) AmazonContent: (NSUInteger) page
{
    NSString *urlString = @"http://www.amazon.cn/gp/bestsellers/books/ref=zg_bs_books_pg_2";
    NSDictionary *parameter = @{@"ie": @"UTF8",
                                @"pg": [NSNumber numberWithInteger: page],
                                @"ajax": @0};
    [ParseHTML amazonBooksWithUrl: urlString paraments: parameter successs:^(NSMutableArray *amazonBookArray, NSUInteger pageNumber) {
        [self.bookListArray addObjectsFromArray: amazonBookArray];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

/**
 *  京东图书榜单
 *
 *  @param page 页码
 */
- (void) JDContent: (NSUInteger) page
{
    NSString *urlString = [NSString stringWithFormat: @"http://book.jd.com/booktop/0-0-0.html?category=1713-0-0-0-10003-%lu#comfort", (unsigned long)page];
    [ParseHTML JDBooksWithUrl: urlString successs:^(NSMutableArray *JDBookArray, NSUInteger pageNumber) {
        [self.bookListArray addObjectsFromArray: JDBookArray];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

/**
 *  当当图书榜单
 *
 *  @param page 页码
 */
- (void) DDContent: (NSUInteger) page
{
    NSString *urlString = [NSString stringWithFormat: @"http://bang.dangdang.com/books/bestsellers/01.00.00.00.00.00-recent30-0-0-1-%lu", (unsigned long)page];
    [ParseHTML DDBooksWithUrl: urlString successs:^(NSMutableArray *DDBookArray, NSUInteger pageNumber) {
        [self.bookListArray addObjectsFromArray: DDBookArray];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookListArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DoubanContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"tagListCell"];
    [self configurateCell: cell atIndexPath: indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [tableView fd_heightForCellWithIdentifier: @"tagListCell" cacheByIndexPath: indexPath configuration:^(id cell) {
        [self configurateCell: cell atIndexPath: indexPath];
    }];
    return height;

}

- (void) configurateCell: (DoubanContentTableViewCell *) cell
             atIndexPath: (NSIndexPath *) indexPath
{
    DoubanBookModel *bookModel = self.bookListArray[indexPath.row];
    [cell configurateBookTagListCell: bookModel contentType: _contentType];
}


@end
