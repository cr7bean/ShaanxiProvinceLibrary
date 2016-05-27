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
#import "GVUserDefaults+library.h"
#import <PSTAlertController.h>
#import "LibraryNPUViewController.h"
#import "LibraryXidianViewController.h"
#import "LibraryXAUTViewController.h"
#import "Helper.h"




@interface SearchBooksViewController ()<UITabBarControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *searchType;

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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden: YES animated: NO];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    self.navigationController.navigationBar.hidden = NO;
//    [self.navigationController setNavigationBarHidden: NO animated: NO];
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
    NSArray *typeArray = @[@"TI^TITLE^SERIES^Title Processing^题名",
                           @"AU^AUTHOR^AUTHORS^Author Processing^著者",
                           @"SU^SUBJECT^SUBJECTS^^主题",
                           @"PER^PERTITLE^SERIES^Title Processing^期刊名"];
    self.searchType = typeArray[searchBar.selectedScopeButtonIndex];

    [self chooseLibrarySystem];
    [searchBar resignFirstResponder];
}

- (void) chooseLibrarySystem
{
    NSString *searchBookName = _searchbar.text;
    //删除特殊符号
    searchBookName = [Helper deleteSpesicalSymbolInString: searchBookName];
    
    NSString *libraryName = [GVUserDefaults standardUserDefaults].libraryName;
    if ([libraryName isEqualToString: @"西安理工图书馆"]) {
      LibraryXAUTViewController *controller = [LibraryXAUTViewController searchBookWithWords: searchBookName searchType: @"title"];
        controller.hidesBottomBarWhenPushed = YES;
        
    }else{
        
        NSDictionary *parameters = @{
                                     @"srchfield1": self.searchType,
                                     @"searchdata1": searchBookName,
                                     @"library": [GVUserDefaults standardUserDefaults].libraryShortName,
                                     @"sort_by": @"ANY"
                                     };
        ShowBooksMainViewController *controller = [[ShowBooksMainViewController alloc] initWithDictionary: parameters];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController: controller animated: YES];
    }
    
    
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
