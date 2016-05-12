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

# define NOTIFICATION_ACCOUNT @"accountsUpdated"
# define SERVICE @"figureWang"


@interface AddAccountViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *libraryButton;
@property (nonatomic, copy) NSMutableArray *libraryNames;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

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
    PSTAlertController *alertController = [PSTAlertController alertWithTitle: nil message: @"用户名或密码错误"];
    [alertController addAction: [PSTAlertAction actionWithTitle: @"确定" style: PSTAlertActionStyleCancel handler: nil]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.labelText = @"登录中";
    _account.text = @"2140321246";
    _password.text = @"908729601";
    
//    [SSKeychain deletePasswordForService: SERVICE account: _account.text];
    
    NSInteger index = [_libraryNames indexOfObject: _libraryButton.currentTitle];
    [LoginManager loginWithAccont: _account.text
                         password: _password.text
                      libraryType: index
                          success:^(NSInteger statusCode) {
                              hud.mode = MBProgressHUDModeText;
                              if (statusCode == 0) {
                                  hud.labelText = @"用户名或密码错误";
                                  [hud hide: YES afterDelay: 1];
                              }else{
                                  hud.labelText = @"登录成功";
                                  [SSKeychain setPassword: _password.text forService: SERVICE account: _account.text];
                                  [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_ACCOUNT object: nil];
                                  dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC);
                                  dispatch_after(time, dispatch_get_main_queue(), ^{
                                      hud.hidden = YES;
                                      [self dismissViewControllerAnimated: YES completion: nil];
                                  });
                              }
                              
                              
                          } failure:^(NSError *error) {
                              NSLog(@"%@", error);
                          }];
}




@end
