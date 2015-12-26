//
//  BookListChildViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/13.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookListChildViewController.h"
#import <Masonry.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import "BookListModel.h"
#import <SVPullToRefresh.h>
#import "ParseHTML.h"
#import "BooklistTableViewCell.h"

#import "ShowBooksMainViewController.h"
#import "BookContentChildViewController.h"


@interface BookListChildViewController ()<UITableViewDelegate, UITableViewDataSource>



@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *booklistDic;
@property (nonatomic, strong) NSMutableArray *booklistArray;
@property (nonatomic, copy) NSString *nextPageAddress;
@property (nonatomic, copy) NSString *totalNumberString;
@property (nonatomic, assign) NSUInteger firstHitNumber;
@property (nonatomic, assign) NSUInteger lastHitNumber;




@end

@implementation BookListChildViewController
{
    
}

- (void) loadView
{
    UIView *view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view = view;
    self.view.backgroundColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"馆藏信息";
    [self assignWithDictionary: self.booklistDic];
    
    [self.tableView reloadData];
    
    [self updateNextPageBooklist];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (instancetype) initWithDictionary: (NSDictionary *) dictionary
{
    self = [super init];
    if (self) {
        self.booklistDic = dictionary;
    }
    return self;
}



#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.booklistArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BooklistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"booklistCell"];
    [self configureCell: cell atIndexPath: indexPath];
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat: @"共搜索到%@条结果", self.totalNumberString];
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
    BookListModel *bookModel = self.booklistArray[indexPath.row];

    cell.booklistModel = bookModel;
   
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString  *urlString = @"http://61.185.242.108";
    if (self.nextPageAddress) {
        urlString = [urlString stringByAppendingString: self.nextPageAddress];
    }
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    BookListModel *bookModel = self.booklistArray[indexPath.row];
    NSString *keyString = [NSString stringWithFormat: @"VIEW^%@", bookModel.number];
    NSDictionary *paraments = @{
                                @"first_hit": [NSNumber numberWithInteger: self.firstHitNumber],
                                @"last_hit": [NSNumber numberWithInteger: self.lastHitNumber],
                                keyString: @"详细资料",
                                @"urlString": urlString
                                };
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    BookContentChildViewController *controller = [[BookContentChildViewController alloc] initWith: paraments transition: transtionTypeListController];
    [self.navigationController pushViewController: controller animated: YES];
}


#pragma mark - getter

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
        [self.view addSubview: _tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 64, 0));
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass: [BooklistTableViewCell class] forCellReuseIdentifier: @"booklistCell"];
        
    }
    return _tableView;
}

- (NSDictionary *) booklistDic
{
    if (!_booklistDic) {
        _booklistDic = [NSDictionary new];
    }
    return _booklistDic;
}

- (NSMutableArray *) booklistArray
{
    if (!_booklistArray) {
        _booklistArray = [NSMutableArray new];
    }
    return _booklistArray;
}

- (void) assignWithDictionary: (NSDictionary *) dictionary
{
    [self.booklistArray addObjectsFromArray: [dictionary objectForKey: @"booklistArray"]];
    self.nextPageAddress = [dictionary objectForKey: @"nextPageAddress"];
    self.totalNumberString =[dictionary objectForKey: @"totalNumberString"];
    self.firstHitNumber = [[dictionary objectForKey: @"firstHitNumber"] integerValue];
    self.lastHitNumber = [[dictionary objectForKey: @"lastHitNumber"] integerValue];
}

#pragma mark - nextPage booklist

- (void) nextPageBooklist
{
    __weak BookListChildViewController *weakSelf = self;
    
    NSString  *urlString = @"http://61.185.242.108";
    urlString = [urlString stringByAppendingString: _nextPageAddress];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSString *nextString = [NSString stringWithFormat: @"JUMP^%lu", _lastHitNumber+1];
    NSDictionary *parameters = @{@"first_hit": [NSNumber numberWithInteger: _firstHitNumber],
                                 @"last_hit": [NSNumber numberWithInteger: _lastHitNumber],
                                 @"form_type": nextString};
    [ParseHTML booksNumberIsMoreNextPage: urlString paraments: parameters success:^(NSDictionary *booklist) {
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
        [self assignWithDictionary: booklist];
        [_tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

- (void) updateNextPageBooklist
{
    __weak BookListChildViewController *weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (!(_lastHitNumber % 20)) {
            [weakSelf nextPageBooklist];
        }else{
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        }
    }];
}

@end
