//
//  PersonalCenterViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/8.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import <SSKeychain.h>
#import "AddAccountViewController.h"
#import "BorrowBookViewController.h"
#import <PSTAlertController.h>
#import "GVUserDefaults+library.h"
#import "DatabaseManager.h"
#import "DueNotificationManager.h"
#import <MessageUI/MessageUI.h>
#import <SDVersion.h>
#import "RemoveAdViewController.h"


# define NOTIFICATION_ACCOUNT @"accountsUpdated"
# define SERVICE @"figureWang"

#import <StoreKit/StoreKit.h>

@interface PersonalCenterViewController () <SKProductsRequestDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) NSMutableArray *titles;
@property (nonatomic, copy) NSMutableArray *allAccounts;

@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, copy) NSString *folderSizeString;

@end

@implementation PersonalCenterViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateTable:)
                                                 name: NOTIFICATION_ACCOUNT                                              object: nil];
    [self titles];
    [self validateProductIndentifiers: @[@"LibraryRemoveAd0001"]];
    self.folderSizeString = [self calculateCacheFolderSize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: NOTIFICATION_ACCOUNT object: nil];
}



# pragma mark - AccountNames
- (NSArray *) titles
{
    if (!_titles) {
        _allAccounts = [NSMutableArray new];
        [self updateAccounts];
        NSArray *sectionOne = @[@"收藏书籍", @"清理缓存"];
        NSArray *sectionTwo = @[@"提醒时间", @"到期提醒", @"重复提醒"];
        NSArray *sectionThree = @[@"评分", @"意见反馈", @"去除广告", @"关于"];
        _titles = [@[_allAccounts, sectionOne, sectionTwo, sectionThree] mutableCopy];
    }
    return _titles;
}

- (void) updateTable: (NSNotification *) note
{
    [self updateAccounts];
    [self.tableView reloadData];
}

- (void) updateAccounts
{
    [_allAccounts removeAllObjects];
    NSArray *account = [SSKeychain accountsForService: SERVICE];
    if (account.count) {
        for (NSDictionary *dic in account) {
            [_allAccounts addObject: dic[@"acct"]];
        }
    }
    [_allAccounts addObject: @"添加帐号"];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titles[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"centerCell"];
    UITableViewCell *labelCell = [tableView dequeueReusableCellWithIdentifier: @"labelCell"];
    UITableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier: @"switchCell"];
    NSString *title = [_titles[indexPath.section] objectAtIndex: indexPath.row];
    if ([title isEqualToString: @"清理缓存"] || [title isEqualToString: @"提醒时间"]) {
        UILabel *label = (UILabel *)[labelCell viewWithTag: 10];
        UILabel *addtionLabel = (UILabel *)[labelCell viewWithTag: 11];
        label.text = title;
        if ([title isEqualToString: @"提醒时间"]) {
            addtionLabel.text = [NSString stringWithFormat: @"提前%lu天通知", [GVUserDefaults standardUserDefaults].aheadDay];
            
        }else{
            addtionLabel.text = nil;
        }
        return labelCell;
    }else if ([title isEqualToString: @"到期提醒"] || [title isEqualToString: @"重复提醒"]){
        UILabel *label = (UILabel *)[switchCell viewWithTag: 20];
        label.text = title;
        UISwitch *dateSwitch = (UISwitch *)[switchCell viewWithTag: 21];
        [dateSwitch addTarget: self action: @selector(switchClicked:) forControlEvents: UIControlEventValueChanged];
        if ([title isEqualToString: @"到期提醒"]) {
            dateSwitch.on = [GVUserDefaults standardUserDefaults].remind;
            dateSwitch.tag = 22;

        }else{
            dateSwitch.on = [GVUserDefaults standardUserDefaults].repeat;
            dateSwitch.tag = 23;
        }
        return switchCell;
    }else{
        cell.textLabel.text = title;
    }
    return cell;
}




- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"系统通知已关闭，请在 iPhone 的“设置”-“通知”中修改";
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    NSString *title = [_titles[indexPath.section] objectAtIndex: indexPath.row];
    
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == [_titles[indexPath.section] count] - 1) {
                AddAccountViewController *controller = [storyboard instantiateViewControllerWithIdentifier: @"AddAccount"];
                [self presentViewController: controller animated: YES completion: nil];
            }else{
                BorrowBookViewController *controller = [storyboard instantiateViewControllerWithIdentifier: @"BorrowBook"];
                controller.tableName = title;
                [self.navigationController pushViewController: controller animated: YES];
            }
           break;
        }
        case 1:{
            if (indexPath.row == 0) {
                
            }else{
                [self deleteCacheFile];
                
            }
            break;
        }
        case 2:{
            if (indexPath.row == 0) {
                [self chooseAheadDayAtIndexPath: indexPath];
            }
            break;
        }
        case 3:{
            if (indexPath.row == 0) {
                
            
            }else if (indexPath.row == 1){
                [self sendEmail];
                
            }else if (indexPath.row == 2){
                
                RemoveAdViewController *controller = [storyboard instantiateViewControllerWithIdentifier: @"removeAd"];
                [self.navigationController pushViewController: controller animated: YES];
                
            }else{
                
            }
            break;
        }
    }
//    AddAccountViewController *accountController = [AddAccountViewController new];
//    [self presentViewController: accountController animated: YES completion: nil];
}

#pragma mark - TableView didSelect

// Send E-mail
- (void) sendEmail
{
    MFMailComposeViewController *controller = [MFMailComposeViewController new];
    controller.view.tintColor = [UIColor whiteColor];
    controller.mailComposeDelegate = self;
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceInfo = [stringFromDeviceVersion([SDVersion deviceVersion]) stringByAppendingFormat: @"+%@", [device systemVersion]];
    deviceInfo = [@"[运行环境]" stringByAppendingString: deviceInfo];

    NSString *emailTitle = @"问题反馈";
    NSString *messageBody = deviceInfo;
    NSArray *toRecipents = @[@"figure_2008@163.com"];
    
    [controller setSubject: emailTitle];
    [controller setMessageBody: messageBody isHTML: NO];
    [controller setToRecipients: toRecipents];
    
    if ([MFMailComposeViewController canSendMail]) {
        [self presentViewController: controller animated: YES completion: nil];
    }
}

// MFmailViewController delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled: {
            NSLog(@"Mail cnacelled");
            break;
        }
        case MFMailComposeResultSaved: {
            NSLog(@"Mail saved");
            break;
        }
        case MFMailComposeResultSent: {
            NSLog(@"Mail sent");
            break;
        }
        case MFMailComposeResultFailed: {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        }
    }
    
    [self dismissViewControllerAnimated: YES completion: nil];
}



#pragma mark - LocalNotification configuration

// switch 点击事件，用 Tag 值来区分两个控件.提醒为 22 。重复提醒为23
- (void) switchClicked: (UISwitch *) dateSwitch
{
    if (dateSwitch.tag == 22) {
        [GVUserDefaults standardUserDefaults].remind = dateSwitch.on;
    }else{
        [GVUserDefaults standardUserDefaults].repeat = dateSwitch.on;
    }
    // 重新设置提醒
    [self reScheduleBorrowBookNotification];
}

// 选择提醒时间

- (void) chooseAheadDayAtIndexPath: (NSIndexPath *) indexPath
{
    PSTAlertController *controller = [PSTAlertController actionSheetWithTitle: @"选择提前提醒的天数"];
    NSArray *days = @[@3, @5, @7, @9];
    UITableViewCell *labelCell = [self.tableView cellForRowAtIndexPath: indexPath];
    UILabel *addtionLabel = (UILabel *)[labelCell viewWithTag: 11];
    
    for (int i=0; i<4; i++) {
        NSString *dayTitle = [NSString stringWithFormat: @"%@", days[i]];
        [controller addAction: [PSTAlertAction actionWithTitle: dayTitle handler:^(PSTAlertAction * _Nonnull action) {
            addtionLabel.text = [NSString stringWithFormat: @"提前%lu天通知", [days[i] integerValue]];
            [GVUserDefaults standardUserDefaults].aheadDay = [days[i] integerValue];
            [self reScheduleBorrowBookNotification];
            [self.tableView reloadData];
        }]];
    }
    
    [controller addAction: [PSTAlertAction actionWithTitle: @"取消" style: PSTAlertActionStyleCancel handler: nil]];
    [controller showWithSender: nil controller: self animated: YES completion: nil];
}

// 重新安排通知

- (void) reScheduleBorrowBookNotification
{
    NSArray *accounts = [SSKeychain accountsForService: SERVICE];
    if (accounts.count) {
        for (NSDictionary  *dic in [SSKeychain accountsForService: SERVICE]) {
            NSString *account = dic[@"acct"];
            NSString *tableName = [NSString stringWithFormat: @"'%@'", account];
            [DatabaseManager selectFromAccountTable: tableName success:^(NSMutableArray *books) {
                [DueNotificationManager scheduleBorrowBookNotification: books accountName: account];
                NSLog(@"Person: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
            }];
        }
    }
    
}


# pragma mark - iAP

- (void) validateProductIndentifiers: (NSArray *) productIndentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray: productIndentifiers]];
    self.request = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
   
}

#pragma mark - calculate cache file size

- (CGFloat) fileSizeAtPath: (NSString *) path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath: path]) {
        long long size = [manager attributesOfItemAtPath: path error: nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

- (CGFloat) folderSizeAtPath: (NSString *) path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    float folderSize;
    if ([manager fileExistsAtPath: path]) {
        NSArray *childerFiles = [manager subpathsAtPath: path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent: fileName];
            folderSize += [self fileSizeAtPath: absolutePath];
        }
        return folderSize;
    }
    return 0;
}

- (NSString *) cacheFoderPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask, YES) firstObject];
    NSString *identify = [[NSBundle mainBundle] bundleIdentifier];
    NSString *fullPath = [path stringByAppendingPathComponent: identify];
    return fullPath;
}

- (NSString *) calculateCacheFolderSize
{
    NSString *fullPath = [self cacheFoderPath];
    CGFloat folderSize = [self folderSizeAtPath: fullPath];
    NSString *folderSizeString = [NSString stringWithFormat: @"%.2fM", folderSize];
    return folderSizeString;
}

- (void) removeCacheFolder
{
    NSString *fullPath = [self cacheFoderPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath: fullPath]) {
        [manager removeItemAtPath: fullPath error: nil];
        _folderSizeString = [self calculateCacheFolderSize];
    }
}

- (void) deleteCacheFile
{
    NSString *actionTitle = [NSString stringWithFormat: @"清理缓存%@", _folderSizeString];
    PSTAlertController *controller = [PSTAlertController actionSheetWithTitle: actionTitle];
    [controller addAction: [PSTAlertAction actionWithTitle: @"确认清除" handler:^(PSTAlertAction * _Nonnull action) {
        
        dispatch_queue_t queur = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queur, ^{
            [self removeCacheFolder];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
        
    }]];
    [controller addAction: [PSTAlertAction actionWithTitle: @"取消" style: PSTAlertActionStyleCancel handler: nil]];
    [controller showWithSender: nil controller: self animated: YES completion: nil];
}





@end
