//
//  ChooseLibraryViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/3/5.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "ChooseLibraryViewController.h"
#import <Masonry.h>
#import "GVUserDefaults+library.h"

@interface ChooseLibraryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *libraries;
@property (nonatomic, copy) NSIndexPath *selecredIndexPath;
@property (nonatomic, copy) NSString *selectedLibrary;



@end

@implementation ChooseLibraryViewController



# pragma mark lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *schoolLibraries = [NSMutableArray new];
    NSArray *schools = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"schools" ofType: @"plist"]];
    [schools enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx) {
            [schoolLibraries addObject: obj[@"schoolName"]];
        }
    }];
    NSArray *proviceLibraries = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"libraries" ofType: @"plist"]];
    self.libraries = @[schoolLibraries, proviceLibraries];
    self.selectedLibrary = [GVUserDefaults standardUserDefaults].libraryName;
    
    BOOL isContained = [proviceLibraries containsObject: self.selectedLibrary];
    if (isContained) {
        self.selecredIndexPath = [NSIndexPath indexPathForRow: [proviceLibraries indexOfObject: self.selectedLibrary] inSection: 1];
    }else{
        self.selecredIndexPath = [NSIndexPath indexPathForRow: [schoolLibraries indexOfObject: self.selectedLibrary] inSection: 0];
    }
    [self addBarItemOnNavigationbar];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma mark congigurateNavationbar

- (void) addBarItemOnNavigationbar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStyleDone target: self action: @selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(done)];
}

- (void) cancel
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) done
{
    [GVUserDefaults standardUserDefaults].libraryName = self.selectedLibrary;
    [self dismissViewControllerAnimated: YES completion: nil];
}


# pragma mark getter

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame: CGRectZero style: UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview: _tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        [_tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"libraryCell"];
    }
    return _tableView;
}


# pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _libraries.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_libraries[section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"libraryCell"];
    cell.textLabel.text = [self.libraries[indexPath.section] objectAtIndex: indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BOOL isEqual = self.selecredIndexPath.row == indexPath.row && self.selecredIndexPath.section == indexPath.section;
    cell.accessoryType = isEqual ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *libraryType =@[@"高校图书馆", @"省图书馆"];
    return libraryType[section];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selecredIndexPath = indexPath;
    self.selectedLibrary = [_libraries[indexPath.section] objectAtIndex: indexPath.row];
    [tableView reloadData];
}

@end
