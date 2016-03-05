//
//  SearchBooksViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/27.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "SearchBooksViewController.h"
#import "ParseHTML.h"
#import "ShowBooksMainViewController.h"




@interface SearchBooksViewController ()<UITabBarControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchBooksViewController
{
    NSMutableArray *_hotSearchingBooks;
}

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _searchbar.delegate = self;
    _hotSearchingBooks = [NSMutableArray new];
    
    [ParseHTML parseHotSearchingBookSuccess:^(NSMutableArray *hotSearchingBooks) {
        
        _hotSearchingBooks = hotSearchingBooks;
        [_tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if(error.code == -1001){
            NSLog(@"请求超时");
        }else{
            NSLog(@"请检查您的网络");
        }
    }];
    
//    _searchbar.tintColor = [UIColor colorWithRed:0.029 green:0.029 blue:0.031 alpha:0.8];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.hidden = YES;
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - tabBar Delegate

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 1) {
        
    }
}

#pragma mark - scrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchbar resignFirstResponder];
}

#pragma mark - searchBar delegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchBookName = searchBar.text;
    NSDictionary *parameters = @{
                                 @"srchfield1": @"TI^TITLE^SERIES^Title Processing^题名",
                                 @"searchdata1": searchBookName,
                                 @"library": @"陕西省馆",
                                 @"sort_by": @"ANY"
                                 };
    
    ShowBooksMainViewController *controller = [[ShowBooksMainViewController alloc] initWithDictionary: parameters];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
    [searchBar resignFirstResponder];
}

#pragma mark - tableView delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _hotSearchingBooks.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cellIdentify"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cellIdentify"];
    }
    cell.textLabel.text = _hotSearchingBooks[indexPath.row];
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = @[@"热门搜索"];
    return array[section];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];
    _searchbar.text = _hotSearchingBooks[indexPath.row];
    [_searchbar becomeFirstResponder];
    
}



@end