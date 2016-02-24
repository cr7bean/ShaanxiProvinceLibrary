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
    
//    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview: _tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [_tableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"tagListCell"];
    

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

//- (UITableView *) tableView
//{
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStylePlain];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        [self.view addSubview: _tableView];
//        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
////            make.left.right.bottom.mas_equalTo(0);
////            make.top.mas_equalTo(self.mas_topLayoutGuide);
//            make.edges.mas_equalTo(0);
//        }];
//        [_tableView registerClass: [DoubanContentTableViewCell class] forCellReuseIdentifier: @"tagListCell"];
//    }
//    return _tableView;
//}

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
            
            break;
        }
        case contentTypeJD: {
            
            break;
        }
        case contentTypeDD: {
            
            break;
        }
    }
}

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



#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookListArray.count;
//    return 5;
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
    NSLog(@"%f", height);
    return height;

//    return [tableView fd_heightForCellWithIdentifier: @"tagListCell" cacheByIndexPath: indexPath configuration:^(id cell) {
//        [self configurateCell: cell atIndexPath: indexPath];
//    }];
}

- (void) configurateCell: (DoubanContentTableViewCell *) cell
             atIndexPath: (NSIndexPath *) indexPath
{
    DoubanBookModel *bookModel = self.bookListArray[indexPath.row];
    [cell configurateBookTagListCell: bookModel];
}


@end
