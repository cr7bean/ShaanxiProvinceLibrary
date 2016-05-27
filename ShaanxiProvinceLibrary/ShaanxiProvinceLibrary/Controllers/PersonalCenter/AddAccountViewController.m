//
//  AddAccountViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/11.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "AddAccountViewController.h"
#import <PSTAlertController.h>
#import "LoginManager.h"
#import <MBProgressHUD.h>
#import <SSKeychain.h>
#import "DatabaseManager.h"
#import <FMDB.h>
#import "BorrowBookModel.h"
#import "DueNotificationManager.h"
#import "Helper.h"
#import "GVUserDefaults+library.h"

# define NOTIFICATION_ACCOUNT @"accountsUpdated"
# define SERVICE @"figureWang"


@interface AddAccountViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *libraryButton;
@property (nonatomic, copy) NSMutableArray *libraryNames;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, copy) NSString *accountString;
@property (nonatomic, copy) NSString *passwordString;

@property (nonatomic, strong) PSTAlertController *actionController;


@end

@implementation AddAccountViewController

# pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self actionController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: NOTIFICATION_ACCOUNT object: nil];
}

# pragma mark - getter

- (PSTAlertController *) actionController
{
    if (!_actionController) {
        [self libraryNames];
        _actionController = [PSTAlertController actionSheetWithTitle: nil];
        [_actionController addAction: [PSTAlertAction actionWithTitle: @"取消" style: PSTAlertActionStyleCancel handler: nil]];
        for (NSString *name in _libraryNames) {
            [_actionController addAction: [PSTAlertAction actionWithTitle: name handler:^(PSTAlertAction * _Nonnull action) {
                [_libraryButton setTitle: name forState: UIControlStateNormal];
                [_libraryButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
            }]];
        }
    }
    return _actionController;
}

- (NSArray *) libraryNames
{
    if (!_libraryNames) {
        NSArray *schools = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"schools" ofType: @"plist"]];
        _libraryNames = [NSMutableArray new];
        for (NSDictionary *dic in schools) {
            [_libraryNames addObject: dic[@"schoolName"]];
        }
    }
    return _libraryNames;
}

# pragma mark - button click

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

# pragma mark - login

- (IBAction)chooseLibrary:(UIButton *)sender
{
    [self.actionController showWithSender: sender controller: self animated: YES completion: nil];
}

- (IBAction)login:(UIButton *)sender
{
    // 选择图书馆
    NSInteger index = [_libraryNames indexOfObject: _libraryButton.currentTitle];

    // 删除可能输入的各种空白符
    _accountString = [Helper regexDeleteBlankCharacterInString: _account.text];
    _passwordString = [Helper regexDeleteBlankCharacterInString: _password.text];
    
    // 保证登录项填写完整
    BOOL canLogin = (_accountString.length > 0) && (_passwordString.length > 0) && ([_libraryNames containsObject: _libraryButton.currentTitle]);
    if (canLogin) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        hud.labelText = @"登录中";
        
        [LoginManager loginWithAccont: _accountString
                             password: _passwordString
                          libraryType: index
                              success:^(NSString *errorMsg, id msg) {
                                  hud.mode = MBProgressHUDModeText;
                                  if ([msg count] > 5) {
                                      
                                      hud.labelText = @"登录成功";
                                      [self insertIntoDatabaseWithBorrowBooks];
                                  }else if([errorMsg containsString: @"用户名或密码错误"]){
                                      hud.labelText = @"用户名或密码错误";
                                      [hud hide: YES afterDelay: 1];
                                  }else{
                                      hud.labelText = @"系统出了点问题";
                                      [hud hide: YES afterDelay: 1];
                                  }
                                  
                              } failure:^(NSError *error) {
                                  hud.labelText = @"系统出了点问题";
                                  [hud hide: YES afterDelay: 1];
                              }];
    }
    
}

/**
 *  保存登录信息，返回个人中心页面
 */
- (void) saveLoginInfo
{
    // 保存登录信息
    [SSKeychain setPassword: _passwordString forService: SERVICE account: _accountString];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_ACCOUNT object: nil];
    
    // 保存帐号对应的图书馆
    NSInteger index = [_libraryNames indexOfObject: _libraryButton.currentTitle];
    NSMutableDictionary *libraryType = [NSMutableDictionary dictionary];
    [libraryType setObject: @(index) forKey: _accountString];
    [GVUserDefaults standardUserDefaults].libraryType = libraryType;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated: YES completion: nil];
    });

}

/**
 *  保存借阅书籍到数据库
 */
- (void) insertIntoDatabaseWithBorrowBooks

{
    [LoginManager fetchBorrowInfo:^(NSMutableArray *borrowBooks, id result) {
        
        NSString *msg = [NSString stringWithFormat: @"%@", result];
        if ([msg isEqualToString: @"1"]) {
            NSString *tableName = [self addSingleQuoteWithString: _accountString];
            // 创建数据库，保存借阅书籍
            [DatabaseManager createAccountTableWithName: tableName];
            [DatabaseManager insertIntoAccountTable: tableName object: borrowBooks];
            // 保存登录信息
            [self saveLoginInfo];
            // 安排通知
            [DueNotificationManager scheduleBorrowBookNotification: borrowBooks accountName: _accountString];
            NSLog(@"Add: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}


# pragma mark - helper

- (NSString *) addSingleQuoteWithString: (NSString *) string
{
    return [NSString stringWithFormat: @"'%@'", string];
}



@end
