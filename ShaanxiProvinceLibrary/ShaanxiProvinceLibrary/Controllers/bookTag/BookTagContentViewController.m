//
//  BookTagContentViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/2/27.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "BookTagContentViewController.h"
#import <Masonry.h>
#import "DoubanContentTableViewCell.h"
#import "ParseHTML.h"
#import "DoubanBookModel.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import <PSTAlertController.h>
#import "ShowBooksMainViewController.h"
#import "GVUserDefaults+library.h"
#import "LibraryNPUViewController.h"
#import <MBProgressHUD.h>
#import "LibraryXidianViewController.h"
#import "LibraryXAUTViewController.h"

@interface BookTagContentViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *seatchWords;
@property (nonatomic, strong) UITableView *DoubanTableView;
@property (nonatomic, strong) DoubanBookModel *bookModel;
@property (nonatomic, strong) NSMutableArray *DoubanTitleArray;
@property (nonatomic, strong) NSMutableArray *DoubanContentArray;
@property (nonatomic, assign) tagContentType bookContenType;

@end

@implementation BookTagContentViewController

# pragma mark lifeCycle

- (instancetype) initWithSearchWords: (NSString *) searchWords
                         contentType: (tagContentType) bookContenType
{
    if ([super init]) {
        _seatchWords = searchWords;
        _bookContenType = bookContenType;
    }
    return self;
}

- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.DoubanTableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    [self loadBookContentFromDouban];
    [self addRightBarItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

# pragma mark loadContent

- (void) loadBookContentFromDouban
{
    NSString *urlString;
    switch (_bookContenType) {
        case tagContentTypeDouban: {
            urlString = [@"https://api.douban.com/v2/book/" stringByAppendingString: _seatchWords];
            break;
        }
        case tagContentTypeNonDouban: {
            urlString = [NSString stringWithFormat: @"https://api.douban.com/v2/book/search?q=%@&count=1", _seatchWords];
            break;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.alpha = 0.5;
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [ParseHTML bookContentFromDouban: urlString success:^(DoubanBookModel *book) {
        self.bookModel = book;
        if (book.title) {
            hud.hidden = YES;
            [self configureDoubanContent];
            [self.DoubanTableView reloadData];
        }else{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"豆瓣没有收录";
            [hud hide: YES afterDelay: 1];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        if (error.code == -1009) {
            hud.labelText = @"请检查您的网络";
        }else{
            hud.labelText = @"豆瓣没有收录";
        }
        [hud hide: YES afterDelay: 1];
    }];
}

- (void) configureDoubanContent
{
    self.DoubanTitleArray = [NSMutableArray new];
    self.DoubanContentArray = [NSMutableArray new];
    [self.DoubanTitleArray addObject: @"基本信息"];
    
    NSString *authorIntro = self.bookModel.authorIntro;
    NSString *summary = self.bookModel.summary;
    NSString *catalog = self.bookModel.catalog;
    
    if (authorIntro.length) {
        [self.DoubanTitleArray addObject: @"作者简介"];
        [self.DoubanContentArray addObject: authorIntro];
    }
    if (summary.length) {
        [self.DoubanTitleArray addObject: @"简介"];
        [self.DoubanContentArray addObject: summary];
    }if (catalog.length) {
        [self.DoubanTitleArray addObject: @"目录"];
        [self.DoubanContentArray addObject: catalog];
    }
}

# pragma mark - getter

- (UITableView *) DoubanTableView
{
    if (!_DoubanTableView) {
        _DoubanTableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
        [self.view addSubview: _DoubanTableView];
        [_DoubanTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        _DoubanTableView.delegate = self;
        _DoubanTableView.dataSource = self;
        
        _DoubanTableView.sectionFooterHeight = 0;
        [_DoubanTableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"titleCell"];
        [_DoubanTableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"summaryCell"];
        _DoubanTableView.showsVerticalScrollIndicator = NO;
    }
    return _DoubanTableView;
}

# pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return _DoubanTitleArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DoubanContentTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier: @"titleCell"];
        [titleCell titleCell: _bookModel];
        titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return titleCell;
    }else{
        DoubanContentTableViewCell *summaryCell = [tableView dequeueReusableCellWithIdentifier: @"summaryCell"];
        [self configureSummaryCell: summaryCell atIndexPath: indexPath];
        summaryCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return summaryCell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [tableView fd_heightForCellWithIdentifier: @"titleCell" cacheByIndexPath: indexPath configuration:^(id cell) {
            [cell titleCell: self.bookModel];
        }];
        
    }else{
        return [tableView fd_heightForCellWithIdentifier: @"summaryCell" cacheByIndexPath: indexPath configuration:^(id cell) {
            [self configureSummaryCell: cell atIndexPath: indexPath];
        }];
    }
}

- (void) configureSummaryCell: (DoubanContentTableViewCell *) cell
                  atIndexPath: (NSIndexPath *) indexPath
{
    [cell summaryCell: _DoubanContentArray[indexPath.section - 1]];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return _DoubanTitleArray[section];

}

# pragma mark add RightBarItem
- (void) addRightBarItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"list2"] style: UIBarButtonItemStyleDone target: self action: @selector(barItemAction:)];
    
    self.navigationItem.rightBarButtonItem = item;
}

- (void) barItemAction: (UIBarButtonItem *) buttonItem
{
    
    PSTAlertController *tagController = [PSTAlertController actionSheetWithTitle: [NSString stringWithFormat: @"可以在以下图书馆查找\n%@", _bookModel.title]];
    [tagController addAction: [PSTAlertAction actionWithTitle: @"省图书馆" handler:^(PSTAlertAction * _Nonnull action) {
        [self searchBookInLibrary];
    }]];
    
    [tagController addAction: [PSTAlertAction actionWithTitle: @"西安理工图书馆" handler:^(PSTAlertAction * _Nonnull action) {
        [self searchBookInXAUTLibrary: @"西安理工"];
    }]];
    
    [tagController addAction: [PSTAlertAction actionWithTitle: @"西工大图书馆" handler:^(PSTAlertAction * _Nonnull action) {
        [self searchBookInNPULibraryorCHDLibrary: @"西工大"];
    }]];
    [tagController addAction: [PSTAlertAction actionWithTitle: @"长安大学图书馆" handler:^(PSTAlertAction * _Nonnull action) {
        [self searchBookInNPULibraryorCHDLibrary: @"长安大学"];
    }]];
    
    [tagController addAction: [PSTAlertAction actionWithTitle: @"西电图书馆" handler:^(PSTAlertAction * _Nonnull action) {
        [self searchBookInXidianLibraryOrSXNULibrary: @"西电"];
    }]];
    [tagController addAction: [PSTAlertAction actionWithTitle: @"陕师大图书馆" handler:^(PSTAlertAction * _Nonnull action) {
        [self searchBookInXidianLibraryOrSXNULibrary: @"陕师大"];
    }]];
    
    
    [tagController addAction: [PSTAlertAction actionWithTitle: @"取消" style: PSTAlertActionStyleCancel handler: nil]];
    [tagController showWithSender: buttonItem controller: self animated: YES completion: nil];
}


# pragma mark searchBookInLibrary

- (void)searchBookInLibrary
{
    NSDictionary *parameters = @{
                                 @"srchfield1": @"TI^TITLE^SERIES^Title Processing^题名",
                                 @"searchdata1": self.bookModel.title,
                                 @"library": [GVUserDefaults standardUserDefaults].libraryShortName,
                                 @"sort_by": @"ANY"
                                 };
    
    ShowBooksMainViewController *controller = [[ShowBooksMainViewController alloc] initWithDictionary: parameters];
    controller.hidesBottomBarWhenPushed = YES;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
}


// 在西工大图书馆搜索或长安大学图书馆搜索
- (void) searchBookInNPULibraryorCHDLibrary: (NSString *) schoolName
{
    LibraryNPUViewController *controller = [[LibraryNPUViewController alloc] initWithsearchWords: _bookModel.title schoolName: schoolName];
    [self.navigationController pushViewController: controller animated: YES];
}

// 在西电图书馆搜索或陕师大图书馆搜索

- (void) searchBookInXidianLibraryOrSXNULibrary: (NSString *) schoolName
{
    LibraryXidianViewController *controller = [[LibraryXidianViewController alloc] initWithsearchWords: _bookModel.title schoolName: schoolName];
    [self.navigationController pushViewController: controller animated: YES];
}

// 在西安理工大学图书馆搜索

- (void) searchBookInXAUTLibrary: (NSString *) schoolName
{
    LibraryXAUTViewController *controller = [[LibraryXAUTViewController alloc] initWithsearchWords: _bookModel.title schoolName: schoolName];
    [self.navigationController pushViewController: controller animated: YES];
}


@end
