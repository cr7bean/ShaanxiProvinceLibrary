//
//  CollectionBookViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/19.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "BorrowBookViewController.h"
#import "BorrowBookModel.h"
#import "BorrowBookCell.h"
#import "DatabaseManager.h"
#import "LoginManager.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import <PSTAlertController.h>
#import <SSKeychain.h>
#import "DueNotificationManager.h"
#import "GVUserDefaults+library.h"
#import <MBProgressHUD.h>
#import "AddAccountViewController.h"

# define NOTIFICATION_ACCOUNT @"accountsUpdated"
# define SERVICE @"figureWang"

@interface BorrowBookViewController ()

@property (nonatomic, strong) NSMutableArray *borrowBooks;


@end

@implementation BorrowBookViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addExitBarButtonItem];
    [self loadDataFromDatabaseWithTableName: [self addSingleQuoteWithString: _tableName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: NOTIFICATION_ACCOUNT object: nil];
}


#pragma mark - Load data

- (void) loadDataFromDatabaseWithTableName: (NSString *) tableName
{
    [DatabaseManager selectFromAccountTable: tableName success:^(NSMutableArray *books) {
        // 加载本地数据库内容
        self.borrowBooks = [NSMutableArray new];
        self.borrowBooks = books;
        
        // 获取最新的借阅书籍
        [self updateBorrowBooks];
    }];
}

- (void) updateBorrowBooks
{
    
    [LoginManager fetchBorrowInfo:^(NSMutableArray *borrowBooks, id result) {
        
        // 判断借阅书籍内容是否发生变化.如果没有发生变化，则什么都不做。如果变了，重新给数据库写入数据，重新安排通知，刷新 UI
        NSString *msg = [NSString stringWithFormat: @"%@", result];
        
        NSLog(@"updateBorrowBooks: %@", msg);
        NSLog(@"%lu", borrowBooks.count);
        
        if ([msg isEqualToString: @"1"]) {
            [self fetchBorrowBookInfoSuccess: borrowBooks];
            
        }else{
            [self fetchBorrowBookInfoFailure];
        }
        
    }
                          failure:^(NSError *error) {
                              [self fetchBorrowBookInfoFailure];
                              NSLog(@"BorrowBookViewController:%@", error);
    }];
}


- (void) upDateDatabaseAndTableView: (NSMutableArray *) borrowBooks
{
    self.borrowBooks = borrowBooks;
    [self.tableView reloadData];
    [DueNotificationManager scheduleBorrowBookNotification: borrowBooks accountName: _tableName];
    [DatabaseManager insertIntoAccountTable: [self addSingleQuoteWithString: _tableName] object: borrowBooks];
}

//
- (void) fetchBorrowBookInfoSuccess: (NSMutableArray *) borrowBooks
{
    __block NSInteger sum = 0;
    if (self.borrowBooks.count == borrowBooks.count) {
        [self.borrowBooks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToBorrowBookModel: borrowBooks[idx]]) {
                sum += 0;
            }else{
                sum += 1;
            }
            if (*stop == YES) {
            }
        }];
    }
    
    NSLog(@"sum: %lu", sum);
    if (sum) {
        [self upDateDatabaseAndTableView: borrowBooks];
    }
}


//
- (void) fetchBorrowBookInfoFailure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.yOffset = -32;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"正在重新登录";
    
    // 从网络获取借阅书籍信息失败。尝试重新登录
    [LoginManager loginWithAccont: _tableName
                         password: [SSKeychain passwordForService: SERVICE account: _tableName]
                      libraryType: [[[GVUserDefaults standardUserDefaults].libraryType objectForKey: _tableName] integerValue]
                          success:^(NSString *errorMsg, id msg) {
                              
                              if ([msg count] > 5) {
                                  // 登录成功，重新获取借阅书籍信息
                                  hud.labelText = @"登录成功";
                                  [hud hide: YES afterDelay: 1];
                                  NSLog(@"重新登录成功");
                                  // 重新登录后，再获取借阅书籍
                                  [LoginManager fetchBorrowInfo:^(NSMutableArray *borrowBooks, id result) {
                                      
                                      NSString *msgResult = [NSString stringWithFormat: @"%@", result];
                                      if ([msgResult isEqualToString: @"1"]) {
                                          [self fetchBorrowBookInfoSuccess: borrowBooks];
                                          
                                      } else{
                                          hud.labelText = @"系统出了点问题";
                                          [hud hide: YES afterDelay: 1];
                                      }
                                      
                                  } failure:^(NSError *error) {
                                      hud.labelText = @"系统出了点问题";
                                      [hud hide: YES afterDelay: 1];
                                  }];
                                  
                              }else if([errorMsg containsString: @"用户名或密码错误"]){
                                  // 可能更换了密码,退出当前帐号。
                                  hud.labelText = @"密码错误，请重新登录";
                                  dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC);
                                  dispatch_after(time, dispatch_get_main_queue(), ^{
                                      [self delteAccountInfo];
                                  });
                              }else{
                                  // 服务器可能关闭了
                                  hud.labelText = @"系统出了点问题";
                                  [hud hide: YES afterDelay: 1];
                                  
                              }
                              
                          }
                          failure:^(NSError *error) {
                              hud.labelText = @"系统出了点问题";
                              [hud hide: YES afterDelay: 1];
                          }];
}

#pragma mark - exit barbuttonItem

- (void) addExitBarButtonItem
{
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIBarButtonItem *exitItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"cancel-circle"] style: UIBarButtonItemStyleDone target: self action: @selector(exit)];
    self.navigationItem.rightBarButtonItem = exitItem;
}

- (void) exit
{
    PSTAlertController *controller = [PSTAlertController actionSheetWithTitle: @"退出帐号将不能查看借阅书籍，也不会自动提醒"];
    [controller addAction: [PSTAlertAction actionWithTitle: @"确认退出" handler:^(PSTAlertAction * _Nonnull action) {
        [self delteAccountInfo];
    }]];
    [controller addAction: [PSTAlertAction actionWithTitle: @"取消" style: PSTAlertActionStyleCancel handler: nil]];
    [controller showWithSender: nil controller: self animated: YES completion: nil];
}

- (void) delteAccountInfo
{
    // 删除帐号
    [SSKeychain deletePasswordForService: SERVICE account: _tableName];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_ACCOUNT object: nil];
    // 删除数据库中数据
    [DatabaseManager dropAccountTable: [self addSingleQuoteWithString: _tableName]];
    // 取消通知
    [DueNotificationManager cancelNotificationWithName: _tableName];
    // pop
    [self.navigationController popViewControllerAnimated: YES];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _borrowBooks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BorrowBookCell *cell = [tableView dequeueReusableCellWithIdentifier: @"BorrowBookCell"];
    [self configureCell: cell AtIndexPath: indexPath];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier: @"BorrowBookCell" cacheByIndexPath: indexPath configuration:^(id cell) {
        [self configureCell: cell AtIndexPath: indexPath];
    }];
}

- (void) configureCell: (BorrowBookCell *) cell
           AtIndexPath: (NSIndexPath *) indexPath
{
    BorrowBookModel *bookModel = _borrowBooks[indexPath.row];
    cell.borrowBooks = bookModel;
}


#pragma mark - helper

- (NSString *) addSingleQuoteWithString: (NSString *) string
{
    return [NSString stringWithFormat: @"'%@'", string];
}


@end
