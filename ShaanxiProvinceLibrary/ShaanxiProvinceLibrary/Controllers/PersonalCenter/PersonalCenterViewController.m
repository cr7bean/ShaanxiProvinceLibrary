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

# define NOTIFICATION_ACCOUNT @"accountsUpdated"
# define SERVICE @"figureWang"

@interface PersonalCenterViewController ()

@property (nonatomic, copy) NSMutableArray *titles;
@property (nonatomic, copy) NSMutableArray *allAccounts;

@end

@implementation PersonalCenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateTable:)
                                                 name: NOTIFICATION_ACCOUNT                                              object: nil];
    [self titles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

# pragma mark - AccountNames
- (NSArray *) titles
{
    if (!_titles) {
        _allAccounts = [NSMutableArray new];
        [self updateAccounts];
        NSArray *sectionOne = @[@"收藏书籍", @"缓存大小"];
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
    NSArray *account = [SSKeychain accountsForService: @"figureWang"];
    if (account.count) {
        for (NSDictionary *dic in account) {
            [_allAccounts addObject: dic[@"acct"]];
        }
    }
    [_allAccounts addObject: @"添加帐号"];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: NOTIFICATION_ACCOUNT object: nil];
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
    if ([title isEqualToString: @"缓存大小"] || [title isEqualToString: @"提醒时间"]) {
        UILabel *label = (UILabel *)[labelCell viewWithTag: 10];
        UILabel *addtionLabel = (UILabel *)[labelCell viewWithTag: 11];
        label.text = title;
        if ([title isEqualToString: @"提醒时间"]) {
            addtionLabel.text = @"提前5天通知";
        }else{
            addtionLabel.text = @"7.5M";
        }
        return labelCell;
    }else if ([title isEqualToString: @"到期提醒"] || [title isEqualToString: @"重复提醒"]){
        UILabel *label = (UILabel *)[switchCell viewWithTag: 20];
        label.text = title;
        UISwitch *dateSwitch = (UISwitch *)[switchCell viewWithTag: 21];
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
//    AddAccountViewController *accountController = [AddAccountViewController new];
//    [self presentViewController: accountController animated: YES completion: nil];
}



@end
