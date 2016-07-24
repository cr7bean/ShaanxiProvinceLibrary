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
#import "SchoolLibraryViewController.h"
#import "Helper.h"




@interface SearchBooksViewController ()<UITabBarControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *searchType;
@property (nonatomic, strong) NSDictionary *schoolLibraryInfo;

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
    // 更改光标颜色
    [[UITextField appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor: [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]];
    
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
    self.searchbar.placeholder = [GVUserDefaults standardUserDefaults].isSchoolLibrary ? [GVUserDefaults standardUserDefaults].schoolLibraryInfo[@"schoolName"] : [GVUserDefaults standardUserDefaults].libraryName;
    self.schoolLibraryInfo = [GVUserDefaults standardUserDefaults].schoolLibraryInfo;
    [self.navigationController setNavigationBarHidden: YES animated: YES];
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
    NSString *searchBookName = _searchbar.text;
    //删除特殊符号
    searchBookName = [Helper deleteSpesicalSymbolInString: searchBookName];
    
    BOOL isSchoolLibrary = [GVUserDefaults standardUserDefaults].isSchoolLibrary;
    if (isSchoolLibrary) {
        [self schoolLibraryWithSearchWords: searchBookName];
    }else{
        [self provinceLibraryWithSearchWords: searchBookName];
    }
    [searchBar resignFirstResponder];
}


#pragma mark - choose library

- (void) provinceLibraryWithSearchWords: (NSString *) searchWords
{
  NSArray *typeArray = @[@"TI^TITLE^SERIES^Title Processing^题名",
                  @"AU^AUTHOR^AUTHORS^Author Processing^著者",
                  @"SU^SUBJECT^SUBJECTS^^主题",
                  @"PER^PERTITLE^SERIES^Title Processing^期刊名"];
    self.searchType = typeArray[self.searchbar.selectedScopeButtonIndex];
    NSDictionary *parameters = @{
                                 @"srchfield1": self.searchType,
                                 @"searchdata1": searchWords,
                                 @"library": [GVUserDefaults standardUserDefaults].libraryShortName,
                                 @"sort_by": @"ANY"
                                 };
    ShowBooksMainViewController *controller = [[ShowBooksMainViewController alloc] initWithDictionary: parameters];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
}

- (void) schoolLibraryWithSearchWords: (NSString *) searchWords
{
    NSArray *type = _schoolLibraryInfo[@"searchtype"];
    NSString *xc = _schoolLibraryInfo[@"xc"];
    NSString *schoolName = _schoolLibraryInfo[@"schoolName"];
    self.searchType = type[self.searchbar.selectedScopeButtonIndex];
    NSDictionary *parameters;
    if ([schoolName isEqualToString: @"西安电子科技大学"] || [schoolName isEqualToString: @"陕西师范大学"]) {
//        parameters = @{@"func": @"find-b",
//                      @"find_code": self.searchType,
//                      @"request": searchWords
//                      };
        parameters = @{@"func": @"find-b",
                       @"find_code": self.searchType,
                       @"request": searchWords};
        
    }else{
        parameters = @{@"kw": searchWords,
                       @"xc": xc,
                       @"searchtype": self.searchType};
    }
    
    
    // test
    SchoolLibraryViewController *controller = [SchoolLibraryViewController searchBookWithParameters: parameters];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
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
