//
//  PersonalCenterViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/8.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "PersonalCenterViewController.h"

@interface PersonalCenterViewController ()

@property (nonatomic, copy) NSArray *titles;

@end

@implementation PersonalCenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self titles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (NSArray *) titles
{
    if (!_titles) {
        
        NSArray *sectionOne = @[@"收藏书籍", @"缓存大小"];
        NSArray *sectionTwo = @[@"到期提醒", @"提醒时间", @"超期提醒"];
        NSArray *sectionThree = @[@"评分", @"意见反馈", @"去除广告", @"关于"];
        _titles = @[sectionOne, sectionTwo, sectionThree];
    }
    return _titles;
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
    UITableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier: @"buttonCell"];
    UITableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier: @"switchCell"];
    NSString *title = [_titles[indexPath.section] objectAtIndex: indexPath.row];
    if ([title isEqualToString: @"缓存大小"] || [title isEqualToString: @"提醒时间"]) {
        UILabel *label = (UILabel *)[buttonCell viewWithTag: 10];
        UIButton *button = (UIButton *)[buttonCell viewWithTag: 11];
        label.text = title;
        [button setTitle: @"7.5M" forState: UIControlStateNormal];
        return buttonCell;
    }else if ([title isEqualToString: @"到期提醒"] || [title isEqualToString: @"超期提醒"]){
        UILabel *label = (UILabel *)[switchCell viewWithTag: 20];
        label.text = title;
        return switchCell;
    }else{
        cell.textLabel.text = title;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];
}


@end
