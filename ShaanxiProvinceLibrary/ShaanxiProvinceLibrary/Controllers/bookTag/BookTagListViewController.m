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
#import <MBProgressHUD.h>
#import <PSTAlertController.h>
#import "GVUserDefaults+library.h"
#import "BookTagContentViewController.h"
#import <SVPullToRefresh.h>

#import "UIViewController+AddView.h"

@interface BookTagListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) contentType contentType;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *bookListArray;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, copy) NSString *OrderType;
@property (nonatomic, assign)  NSUInteger doubanPageCount, nonDoubanPageCount;

@end

@implementation BookTagListViewController


# pragma mark - lifeCycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self firstLoadData];
    [self loadMoreContent];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    self.hud.hidden = YES;
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

# pragma mark add RightBarItem
- (void) addRightBarItem
{
    if (_contentType == contentTypeDoubanTag) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list2"] style: UIBarButtonItemStylePlain target: self action: @selector(barItemAction:)];
        self.navigationItem.rightBarButtonItem = item;
    }
}

- (void) barItemAction: (UIBarButtonItem *) buttonItem
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray: [GVUserDefaults standardUserDefaults].collectionTag];
    NSString *title;
    if ([temp containsObject: self.tagName]) {
        title = @"取消收藏";
    }else{
        title = @"收藏";
    }
    PSTAlertController *tagController = [PSTAlertController actionSheetWithTitle: nil];
    [tagController addAction: [PSTAlertAction actionWithTitle: title handler:^(PSTAlertAction * _Nonnull action) {
        [self collectionBookTags: title inArray: temp];
        
    }]];
    [tagController addAction: [PSTAlertAction actionWithTitle: @"取消" style: PSTAlertActionStyleCancel handler: nil]];
    
    if (_contentType == contentTypeDoubanTag) {
        [tagController addAction: [PSTAlertAction actionWithTitle: @"综合排序(默认)" handler:^(PSTAlertAction * _Nonnull action) {
            [self changeContentOrderType: @"T"];
        }]];
        [tagController addAction: [PSTAlertAction actionWithTitle: @"出版日期排序" handler:^(PSTAlertAction * _Nonnull action) {
            [self changeContentOrderType: @"R"];
        }]];
        [tagController addAction: [PSTAlertAction actionWithTitle: @"评价排序" handler:^(PSTAlertAction * _Nonnull action) {
            [self changeContentOrderType: @"S"];
        }]];
    }
    
    [tagController showWithSender: buttonItem controller: self animated: YES completion: nil];
}

// 收藏标签
- (void) collectionBookTags: (NSString *) title
                    inArray: (NSMutableArray *) temp
{
    MBProgressHUD *tagHud = [MBProgressHUD showHUDAddedTo: self.navigationController.view animated: YES];
    tagHud.mode = MBProgressHUDModeText;
    if ([title isEqualToString:@"收藏"]) {
        [temp addObject: self.tagName];
        tagHud.labelText = @"收藏成功";
    }else{
        [temp removeObject: self.tagName];
        tagHud.labelText = @"取消收藏";
    }
    [GVUserDefaults standardUserDefaults].collectionTag = [temp copy];
    [tagHud hide: YES afterDelay: 1];
}

// 更改内容排序方式(仅限豆瓣标签内容)
- (void) changeContentOrderType: (NSString *) orderType
{
    [_bookListArray removeAllObjects];
    _doubanPageCount = 0;
    [self DoubanContent: _doubanPageCount type: orderType];
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
        [self.tableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"tagListCell"];
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

- (void) loadBooklistContent: (NSUInteger) doubanPageCount
       doubanContenOrderType: (NSString *) orderType
        nonDoubanContentPage: (NSUInteger) nonDoubanPageCount
{

    switch (_contentType) {
        case contentTypeDoubanTag: {
            [self DoubanContent: doubanPageCount type: orderType];
            break;
        }
        case contentTypeAmazon: {
            [self AmazonContent: nonDoubanPageCount];
            break;
        }
        case contentTypeJD: {
            [self JDContent: nonDoubanPageCount];
            break;
        }
        case contentTypeDD: {
            [self DDContent: nonDoubanPageCount];
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
    NSString *urlString = @"https://book.douban.com/tag/";
    urlString = [urlString stringByAppendingFormat: @"%@", _tagName];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *parameter = @{@"start": [NSNumber numberWithInteger: startNumber],
                                @"type": typeName};
    
    [ParseHTML searchBookWithTagInUrl: urlString parameter: parameter successs:^(NSMutableArray *bookArray, NSArray *tagsRecommended) {
        
        
//        self.hud.hidden = YES;
        [self rl_removeHudView];
        
        [self.bookListArray addObjectsFromArray: bookArray];
        [self.tableView.infiniteScrollingView stopAnimating];
        if (bookArray.count) {
            [self.tableView fd_reloadDataWithoutInvalidateIndexPathHeightCache];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.tableView.infiniteScrollingView stopAnimating];
        self.hud.mode = MBProgressHUDModeText;
        if (error.code == -1009) {
            self.hud.labelText = @"请检查您的网络";
        }else{
            self.hud.labelText = @"豆瓣服务异常";
        }
        [self.hud hide: YES afterDelay: 1];
        
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
    [ParseHTML amazonBooksWithUrl: urlString parameter: parameter successs:^(NSMutableArray *amazonBookArray, NSUInteger pageNumber) {
        self.hud.hidden = YES;
        [self.bookListArray addObjectsFromArray: amazonBookArray];
        if (amazonBookArray.count) {
           [self.tableView fd_reloadDataWithoutInvalidateIndexPathHeightCache];
        }
        [self.tableView.infiniteScrollingView stopAnimating];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.tableView.infiniteScrollingView stopAnimating];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = @"请检查您的网络";
        [self.hud hide: YES afterDelay: 1];
        
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
        self.hud.hidden = YES;
        [self.bookListArray addObjectsFromArray: JDBookArray];
        if (JDBookArray.count) {
            [self.tableView fd_reloadDataWithoutInvalidateIndexPathHeightCache];
        }
        [self.tableView.infiniteScrollingView stopAnimating];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.tableView.infiniteScrollingView stopAnimating];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = @"请检查您的网络";
        [self.hud hide: YES afterDelay: 1];
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
        self.hud.hidden = YES;
        
        [self.bookListArray addObjectsFromArray: DDBookArray];
        if (DDBookArray.count) {
            [self.tableView fd_reloadDataWithoutInvalidateIndexPathHeightCache];
        }
        [self.tableView.infiniteScrollingView stopAnimating];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.tableView.infiniteScrollingView stopAnimating];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = @"请检查您的网络";
        [self.hud hide: YES afterDelay: 1];
    }];
}

// 初始化，第一次请求数据
- (void) firstLoadData
{
    [self.tableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"tagListCell"];
    self.title = _tagName;
    [self addRightBarItem];
    
    
//    self.hud = [MBProgressHUD showHUDAddedTo: self.navigationController.view animated: YES];
//    self.hud.opacity = 0.5;
    [self rl_addHudView];
    
    _OrderType = @"T";
    _doubanPageCount = 0;
    _nonDoubanPageCount = 1;
    [self loadBooklistContent: _doubanPageCount doubanContenOrderType: _OrderType nonDoubanContentPage: _nonDoubanPageCount];
}



//下拉刷新，请求更多数据
- (void) loadMoreContent
{
    __weak BookTagListViewController *weak = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
            _doubanPageCount += 20;
            _nonDoubanPageCount += 1;
            [weak loadBooklistContent: weak.doubanPageCount
                    doubanContenOrderType: weak.OrderType
                     nonDoubanContentPage: weak.nonDoubanPageCount];
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

# pragma UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    if (_bookListArray.count) {
        DoubanBookModel *bookModel = _bookListArray[indexPath.row];
        NSString *searchWords;
        tagContentType bookContenType;
        if (_contentType == contentTypeDoubanTag) {
            searchWords = bookModel.idString;
            bookContenType = tagContentTypeDouban;
        }else{
            searchWords = bookModel.shortTitle;
            bookContenType = tagContentTypeNonDouban;
        }
        BookTagContentViewController *controller = [[BookTagContentViewController alloc] initWithSearchWords: searchWords contentType: bookContenType];
        [self.navigationController pushViewController: controller animated: YES];
    }else{
        [self.hud show: YES];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = @"请重新选择排序方式";
        [self.hud hide: YES afterDelay: 1];
    }
    
}


@end
