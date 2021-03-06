//
//  ShowBooksMainViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/12.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "ShowBooksMainViewController.h"
#import <MBProgressHUD.h>
#import "ParseHTML.h"
#import <Masonry.h>
#import "Helper.h"
#import <SDVersion.h>


#import "BookListChildViewController.h"
#import "BookContentChildViewController.h"
#import "RecommendBookChildViewController.h"

@interface ShowBooksMainViewController ()
@property (nonatomic, strong) UIView *placeHolderView;
@property (nonatomic, strong) BookListChildViewController *booklistController;
@property (nonatomic, strong) BookContentChildViewController *bookContentController;
@property (nonatomic, strong) RecommendBookChildViewController *recommendedController;
@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation ShowBooksMainViewController

#pragma lifeCycle

- (void) loadView
{
    UIView *view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.view = view;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.placeHolderView.hidden = YES;
    
    // 重点关注这个方法
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self searchBook];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
}


#pragma mark - init

- (instancetype) initWithDictionary: (NSDictionary *) dictionary
{
    self = [super init];
    if (self) {
        self.dictionary = [NSDictionary new];
        self.dictionary = dictionary;
    }
    return self;
}


#pragma mark - getter

- (UIView *) placeHolderView
{
    if (!_placeHolderView) {
        _placeHolderView = [UIView new];
        _placeHolderView.backgroundColor = [Helper setColorWithRed:0 green:175 blue:240];
        
        CGFloat barHeight;
        if ([SDVersion deviceVersion] == iPhone6Plus) {
            barHeight = 93;
        }else{
            barHeight = 64;
        }
        [self.view addSubview: _placeHolderView];
        [_placeHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(barHeight);
            make.top.mas_equalTo(-barHeight);
        }];
    }
    return _placeHolderView;
}


#pragma mark - searchBook

- (void) searchBook
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    hud.yOffset = -32;
    hud.opacity = 0.5;

    NSString *urlString = [NSString stringWithFormat: @"http://61.185.242.108/uhtbin/cgisirsi/0/%@/0/123", @"陕西省馆"];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

    [ParseHTML parseBooksListWithString: urlString dictionary: _dictionary success:^(searchBookState searchState, NSDictionary *searchBook) {
        
        switch (searchState) {
            case searchBookStateServeBusy: {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"图书馆系统繁忙";
                hud.detailsLabelText = @"请您稍后再试";
                break;
            }
            case searchBookStateZero: {
                [hud hide: YES];
                [self searchBookStateZero: searchBook];
                break;
            }
            case searchBookStateOne: {
                [hud hide: YES];
                [self searchBookStateOne: searchBook];
                break;
            }
            case searchBookStateMore: {
                [hud hide: YES];
                [self searchBookStateMore: searchBook];
                break;
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请检查您的网络";
        
    }];
}

- (void) searchBookStateZero: (NSDictionary *) searchBook
{
    self.recommendedController = [[RecommendBookChildViewController alloc] initWithDictionary: searchBook];
    [Helper addViewController: self.recommendedController toViewController: self];
}


- (void) searchBookStateOne: (NSDictionary *) searchBook
{
    self.bookContentController = [[BookContentChildViewController alloc] initWith:searchBook transition: transtionTypeMainController];
    [Helper addViewController: self.bookContentController toViewController: self];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems: @[@"本馆", @"豆瓣"]];
    control.selectedSegmentIndex = 0;
    [control setWidth: 60 forSegmentAtIndex: 0];
    [control setWidth: 60 forSegmentAtIndex: 1];
    self.navigationItem.titleView = control;
    [control addTarget: self action: @selector(transmitValue:) forControlEvents: UIControlEventValueChanged];
    self.delegate = (id)self.bookContentController;
}

- (void) searchBookStateMore: (NSDictionary *) searchBook
{
    self.title = @"馆藏信息";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.booklistController = [[BookListChildViewController alloc] initWithDictionary: searchBook];
    [Helper addViewController: self.booklistController toViewController: self];
}

- (void) transmitValue: (UISegmentedControl *) control
{
    [self.delegate mainViewController: self selectedIndex: control.selectedSegmentIndex];
}



@end
