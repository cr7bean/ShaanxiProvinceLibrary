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
@property (nonatomic, assign) NSInteger selecredRow;
@property (nonatomic, copy) NSString *selectedLibrary;



@end

@implementation ChooseLibraryViewController



# pragma mark lifeCycle

- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.libraries = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"libraries" ofType: @"plist"]];
    self.selectedLibrary = [GVUserDefaults standardUserDefaults].libraryName;
    self.selecredRow = [self.libraries indexOfObject: self.selectedLibrary];
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
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.libraries.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"libraryCell"];
    cell.textLabel.text = self.libraries[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.selecredRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selecredRow = indexPath.row;
    self.selectedLibrary = self.libraries[indexPath.row];
    [tableView reloadData];
}

@end
