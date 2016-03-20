//
//  BookContentChildViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/13.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookContentChildViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import <Masonry.h>
#import "Helper.h"
#import "ShowBooksMainViewController.h"
#import "BookContentTableViewCell.h"
#import "ParseHTML.h"
#import <MBProgressHUD.h>
#import "DoubanBookModel.h"
#import "DoubanContentTableViewCell.h"

@interface BookContentChildViewController ()<UITableViewDelegate, UITableViewDataSource, ShowBooksMainViewControllerDelegate>

@property (nonatomic, strong) UITableView *libraryTableView;
@property (nonatomic, strong) UITableView *DoubanTableView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, assign) transtionType transtionType;
@property (nonatomic, strong) NSDictionary *bookContentDic;
@property (nonatomic, strong) NSMutableDictionary *parameter;
@property (nonatomic, strong) DoubanBookModel *bookModel;

@end

@implementation BookContentChildViewController
{
    NSMutableArray *_titleArray;
    NSMutableArray *_catalogCount;
    
    NSString *isbnString;
    NSMutableArray *_DoubanTitleArray;
    NSMutableArray *_DoubanContentArray;
    
    NSMutableArray *_shortContent;
    NSMutableArray *_longContent;
    NSMutableArray *_lengthState;

    BOOL isCheckInDouban;
    
    
}

#pragma mark - lifeCycle

- (void) loadView
{
    UIView *view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view = view;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self updateBookContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (instancetype) initWith: (NSDictionary *) dictionary
               transition: (transtionType) transition
{
    self = [super init];
    if (self) {
        self.transtionType = transition;
        switch (transition) {
            case transtionTypeMainController: {
                self.bookContentDic = [NSDictionary dictionaryWithDictionary: dictionary];
                break;
            }
            case transtionTypeListController: {
                self.parameter = [NSMutableDictionary dictionaryWithDictionary: dictionary];
                self.navigationItem.titleView = self.segmentControl;
                break;
            }
        }
    }
    return self;
}


#pragma mark - configureBookContent

- (void) updateBookContent
{
//    self.libraryTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
//    self.DoubanTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    
    NSString *urlString = self.parameter[@"urlString"];
    [self.parameter removeObjectForKey: @"urlString"];
    switch (self.transtionType) {
        case transtionTypeMainController: {
            
            
            self.libraryTableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
            self.DoubanTableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
            [self configureBookContent];
            self.DoubanTableView.hidden = YES;
            
            break;
        }
        case transtionTypeListController: {
            
            self.DoubanTableView.hidden = YES;
            self.libraryTableView.hidden = NO;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
            hud.yOffset = -32;
//            hud.labelText = @"加载中...";
            hud.opacity = 0.5;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
            [ParseHTML booksNumberIsOneNextPage: urlString parameter: self.parameter success:^(NSDictionary *bookContent) {
                hud.hidden = YES;
                
                self.bookContentDic = bookContent;
                [self configureBookContent];
                [self.libraryTableView reloadData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"网络请求失败";
                hud.hidden = YES;
            }];
            break;
        }
    }
}

- (void) configureBookContent
{
    NSMutableArray *bookRightInfoArray = self.bookContentDic[@"bookRightInfo"];
    NSMutableArray *bookLocationArray = self.bookContentDic[@"bookLocation"];
    NSMutableArray *bookSummaryArray = self.bookContentDic[@"bookSummary"];
   
    NSUInteger infoCount = bookRightInfoArray.count;
    NSUInteger locationCount = bookLocationArray.count;
    NSUInteger summaryCount = bookSummaryArray.count;
    _titleArray = [NSMutableArray new];
    _catalogCount = [NSMutableArray new];
    if (infoCount == 4) {
        isbnString = [bookRightInfoArray[3] stringByReplacingOccurrencesOfString: @"ISBN: " withString: @""];
    }
    
    if (infoCount) {
        [_titleArray addObject: @"基本信息"];
        [_catalogCount addObject: [NSNumber numberWithInteger: infoCount]];
    }
    if (locationCount) {
        [_titleArray addObject: @"馆藏信息"];
        [_catalogCount addObject: [NSNumber numberWithInteger: locationCount]];
    }
    if (summaryCount) {
        
        [_titleArray addObject: @"概要"];
        [_catalogCount addObject: [NSNumber numberWithInteger: summaryCount]];
    }
}

- (void) configureDoubanContent
{
    _DoubanTitleArray = [NSMutableArray new];
    _DoubanContentArray = [NSMutableArray new];
    _shortContent = [NSMutableArray new];
    _longContent = [NSMutableArray new];
    _lengthState = [NSMutableArray new];
 
    [_DoubanTitleArray addObject: @"基本信息"];
    
    NSString *authorIntro = self.bookModel.authorIntro;
    NSString *summary = self.bookModel.summary;
    NSString *catalog = self.bookModel.catalog;
    
    if (authorIntro.length) {
        [_DoubanTitleArray addObject: @"作者简介"];
        [self subStringFrom: authorIntro];
    }
    if (summary.length) {
        [_DoubanTitleArray addObject: @"简介"];
        [self subStringFrom: summary];
    }if (catalog.length) {
        [_DoubanTitleArray addObject: @"目录"];
        [self subStringFrom: catalog];
    }
    _DoubanContentArray = [_shortContent mutableCopy];
}
- (void) subStringFrom: (NSString *) string
{
    BOOL isLength;
    [_longContent addObject: string];
    if (string.length > 50) {
        [_shortContent addObject: [string substringToIndex: 50]];
        isLength = YES;
    }else{
        [_shortContent addObject: string];
        isLength = NO;
    }
    [_lengthState addObject: [NSNumber numberWithBool: isLength]];
}

#pragma mark - getter

- (UITableView *) libraryTableView
{
    if (!_libraryTableView) {
        _libraryTableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
        [self.view addSubview: _libraryTableView];
        [_libraryTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        [_libraryTableView registerClass: [BookContentTableViewCell class] forCellReuseIdentifier: @"contentCell"];
        _libraryTableView.delegate = self;
        _libraryTableView.dataSource = self;
        _libraryTableView.sectionFooterHeight = 0;
    }
    return _libraryTableView;
}

- (UITableView *) DoubanTableView
{
    if (!_DoubanTableView) {
        _DoubanTableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
        [self.view addSubview: _DoubanTableView];
        [_DoubanTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _DoubanTableView.delegate = self;
        _DoubanTableView.dataSource = self;
        
        _DoubanTableView.sectionFooterHeight = 0;
        [_DoubanTableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"titleCell"];
        [_DoubanTableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"summaryCell"];
    }
    return _DoubanTableView;
}

- (UISegmentedControl *) segmentControl
{
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems: @[@"本馆", @"豆瓣"]];
        [_segmentControl addTarget: self action: @selector(segementControlAction:) forControlEvents: UIControlEventValueChanged];
        [_segmentControl setWidth: 60 forSegmentAtIndex: 0];
        [_segmentControl setWidth: 60 forSegmentAtIndex: 1];
        _segmentControl.selectedSegmentIndex = 0;
    }
    return _segmentControl;
}

- (DoubanBookModel *) bookModel
{
    if (!_bookModel) {
        _bookModel = [DoubanBookModel new];
    }
    return _bookModel;
}

#pragma mark - ShowBooksMainViewControllerDelegate

- (void) mainViewController:(ShowBooksMainViewController *)controller selectedIndex:(NSUInteger)index
{
    [self switchView: index];
}

- (void) segementControlAction: (UISegmentedControl *) control
{
    [self switchView: control.selectedSegmentIndex];
}

- (void) switchView: (NSUInteger) index
{
    if (index == 1) {
        self.DoubanTableView.hidden = NO;
        self.libraryTableView.hidden = YES;

        if (!isCheckInDouban) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.DoubanTableView animated: NO];
            hud.yOffset = -32;
//            hud.labelText = @"加载中...";
            hud.opacity = 0.5;
            
            NSString *urlString = [NSString stringWithFormat: @"https://api.douban.com/v2/book/isbn/%@", isbnString];
            [ParseHTML bookContentFromDouban: urlString success:^(DoubanBookModel *book) {
                hud.hidden = YES;
                isCheckInDouban = YES;
                
                self.bookModel = book;
                [self configureDoubanContent];
                [self.DoubanTableView reloadData];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                hud.mode = MBProgressHUDModeText;
                if (error.code == -1011) {
                    
                    hud.labelText = @"豆瓣没有收藏此书";
                    isCheckInDouban = YES;
                }
            }];
        }
    }else{
        self.libraryTableView.hidden = NO;
        self.DoubanTableView.hidden = YES;
    }
}


#pragma mark - TableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.libraryTableView) {
        return _titleArray.count;
    }else{
        return _DoubanTitleArray.count;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.libraryTableView) {
        return [_catalogCount[section] integerValue];
    }else{
        return 1;
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.libraryTableView) {
        BookContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"contentCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureCell: cell atIndexPath: indexPath];
        return cell;
    }else{
        if (indexPath.section == 0) {
            DoubanContentTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier: @"titleCell"];
            [titleCell titleCell: self.bookModel];
            titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return titleCell;
        }else{
            DoubanContentTableViewCell *summaryCell = [tableView dequeueReusableCellWithIdentifier: @"summaryCell"];
//            [summaryCell summaryCell: _DoubanContentArray[indexPath.section - 1]];
            [self configureSummaryCell: summaryCell atIndexPath: indexPath];
            summaryCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return summaryCell;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.libraryTableView) {
        return [tableView fd_heightForCellWithIdentifier: @"contentCell" cacheByIndexPath: indexPath configuration:^(id cell) {
            [self configureCell: cell atIndexPath: indexPath];
        }];
    }else{
        if (indexPath.section == 0) {
            return [tableView fd_heightForCellWithIdentifier: @"titleCell" cacheByIndexPath: indexPath configuration:^(id cell) {
                [cell titleCell: self.bookModel];
            }];
            
        }else{
           return [tableView fd_heightForCellWithIdentifier: @"summaryCell" cacheByIndexPath: indexPath configuration:^(id cell) {
               
//               [cell summaryCell: _DoubanContentArray[indexPath.section - 1]];
               [self configureSummaryCell: cell atIndexPath: indexPath];
           }];
        }
    }
}

- (void) configureCell: (BookContentTableViewCell *) cell
           atIndexPath: (NSIndexPath *) indexPath
{
    [cell configureCell: self.bookContentDic atIndexPath: indexPath];
}

- (void) configureSummaryCell: (DoubanContentTableViewCell *) cell
                  atIndexPath: (NSIndexPath *) indexPath
{
    [cell summaryCell: _DoubanContentArray[indexPath.section - 1]];
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.libraryTableView) {
      return _titleArray[section];
    }else{
      return _DoubanTitleArray[section];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.DoubanTableView) {
        if (indexPath.section) {
            NSUInteger index = indexPath.section - 1;
            BOOL isLength = [_lengthState[index] boolValue];
            if (isLength) {
                [_DoubanContentArray replaceObjectAtIndex: index withObject: _longContent[index]];
            }else{
                [_DoubanContentArray replaceObjectAtIndex: index withObject: _shortContent[index]];
            }
            [_lengthState replaceObjectAtIndex: index withObject: [NSNumber numberWithBool: !isLength]];
            
            [self.DoubanTableView reloadSections: [NSIndexSet indexSetWithIndex: indexPath.section] withRowAnimation: UITableViewRowAnimationAutomatic];
        }
    }
}




@end
