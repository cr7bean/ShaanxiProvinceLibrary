//
//  LibraryXAUTViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/3/21.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "SchoolLibraryViewController.h"
#import <Masonry.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import "BookListModel.h"
#import <SVPullToRefresh.h>
#import "ParseHTML.h"
#import "Helper.h"
#import "BooklistTableViewCell.h"
#import <MBProgressHUD.h>
#import "GVUserDefaults+library.h"
#import "GAdManager.h"

@interface SchoolLibraryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *bookListArray;
@property (nonatomic, copy) NSString *searchWords;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, copy) NSString *totalNumString;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, copy) NSString *searchType;

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *schoolLibraryInfo;

@end

@implementation SchoolLibraryViewController
{
    __weak SchoolLibraryViewController *weakSelf;
}


# pragma mark lifeCycle

- (instancetype) initWithParameters: (NSDictionary *) parameters
{
    if ([super init]) {
        _parameters = parameters;
    }
    return self;
}

+ (instancetype) searchBookWithParameters: (NSDictionary *) parameters
{
    return [[self alloc] initWithParameters: parameters];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self firstLoadBookList];
    [self updateBookList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
}

# pragma mark loadBookList

// 搜索书籍列表
- (void) loadBookListWithpageCount: (NSUInteger) pageCount
{
    NSString *urlString = _schoolLibraryInfo[@"urlString"];
    NSMutableDictionary *urlParams = [NSMutableDictionary dictionaryWithDictionary: _parameters];
    [urlParams setValue: [NSNumber numberWithInteger: pageCount]
                  forKey: @"page"];
   
    [ParseHTML bookListInSchoolLibraryWithUrl: urlString
                                    parameter: urlParams
                                      success:^(NSMutableArray *bookArray, NSString *totalNumberString) {
                                          
                                          [weakSelf.tableView.infiniteScrollingView stopAnimating];
                                          
                                          if (bookArray.count) {
                                              self.hud.hidden = YES;
                                              
                                              self.totalNumString = totalNumberString;
                                              [self.bookListArray addObjectsFromArray: bookArray];
                                              [self.tableView fd_reloadDataWithoutInvalidateIndexPathHeightCache];
                                          }
                                          if (!_bookListArray.count) {
                                              self.hud.mode = MBProgressHUDModeText;
                                              self.hud.labelText = @"图书馆没有收录";
                                              [self.hud hide: YES afterDelay: 1];
                                          }
                                          
                                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          [weakSelf.tableView.infiniteScrollingView stopAnimating];
                                          self.hud.mode = MBProgressHUDModeText;
                                          self.hud.labelText = @"请检查您的网络";
                                          [self.hud hide: YES afterDelay: 1];
                                          NSLog(@"schoolLibraryError: %@", error.localizedDescription);
                                          // bad gateway 502
                                      }];
}

// 初次加载书籍列表

- (void) firstLoadBookList
{
    self.hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    self.hud.alpha = 0.5;
    self.schoolLibraryInfo = [GVUserDefaults standardUserDefaults].schoolLibraryInfo;
    self.title = _schoolLibraryInfo[@"schoolName"];
    [GAdManager showAdOnViewController: self canOffset: NO];
    self.bookListArray = [NSMutableArray new];
    weakSelf = self;
    _pageCount = 1;
    [self loadBookListWithpageCount: _pageCount];
}

// 下拉刷新加载书籍列表

- (void) updateBookList
{
    [weakSelf.tableView addInfiniteScrollingWithActionHandler:^{
        _pageCount += 1;
        NSInteger totalNumber = [Helper regexFindNumberInString: _totalNumString];
        float index = totalNumber / 20.0;
        index = ceilf(index);
        if (weakSelf.pageCount <= index) {
            [weakSelf loadBookListWithpageCount: _pageCount];
        }else{
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        }
    }];
}



# pragma getter

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
        [self.view addSubview: _tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass: [BooklistTableViewCell class] forCellReuseIdentifier: @"booklistCell"];
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
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
    BooklistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"booklistCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell: cell atIndexPath: indexPath];
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_bookListArray.count) {
        return _totalNumString;
    }else{
        return nil;
    }
}


#pragma mark - UITableViewDelegate


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: @"booklistCell" cacheByIndexPath: indexPath configuration:^(id cell) {
        [self configureCell: cell atIndexPath: indexPath];
    }];
}

- (void) configureCell: (BooklistTableViewCell *) cell atIndexPath: (NSIndexPath *) indexPath
{
    BookListModel *bookModel = _bookListArray[indexPath.row];
    cell.booklistModel = bookModel;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
