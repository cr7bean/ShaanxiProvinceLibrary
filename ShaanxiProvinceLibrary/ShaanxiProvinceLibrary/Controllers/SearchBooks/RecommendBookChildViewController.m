//
//  RecommendBookChildViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/13.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "RecommendBookChildViewController.h"
#import <Masonry.h>
#import "RecommendedBookModel.h"
#import "ShowBooksMainViewController.h"
#import "GVUserDefaults+library.h"

@interface RecommendBookChildViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *booklistDic;
@property (nonatomic, strong) NSArray *recommendedBook;

@end

@implementation RecommendBookChildViewController

#pragma mark - lifeCycle

- (void) loadView
{
    UIView *view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view = view;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    self.navigationItem.title = @"推荐";
    self.recommendedBook = [self.booklistDic objectForKey: @"suggestedBooks"];
    [self.tableView reloadData];
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

#pragma mark - getter

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStyleGrouped];
        [self.view addSubview: _tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
        [_tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"recommendedCell"];
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

- (NSArray *) recommendedBook
{
    if (!_recommendedBook) {
        _recommendedBook = [NSArray new];
    }
    return _recommendedBook;
}

#pragma mark - TableView dataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendedBook.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"recommendedCell"];
    if (cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"recommendedCell"];
    }
    RecommendedBookModel *bookModel = self.recommendedBook[indexPath.row];
    cell.textLabel.text = bookModel.name;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    RecommendedBookModel *bookModel = self.recommendedBook[indexPath.row];
    NSDictionary *parameters = @{
                                 @"srchfield1": @"GENERAL^SUBJECT^GENERAL^^所有字段",
                                 @"searchdata1": bookModel.name,
                                 @"library": [GVUserDefaults standardUserDefaults].libraryShortName,
                                 @"sort_by": @"ANY"
                                 };
    ShowBooksMainViewController *controller = [[ShowBooksMainViewController alloc] initWithDictionary: parameters];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
    
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"没找到您想要的书，或许下面的书会对您有帮助";
}

@end
