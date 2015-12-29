//
//  BookTagViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/29.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookTagViewController.h"
#import <CSStickyHeaderFlowLayout.h>

@interface BookTagViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BookTagViewController

# pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - getter

- (UICollectionView *) collectionView
{
    if (!_collectionView) {
        _collectionView = [UICollectionView new];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        CSStickyHeaderFlowLayout *layout = [CSStickyHeaderFlowLayout new];
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView.collectionViewLayout = layout;
    }
    return _collectionView;
}

# pragma mark - UICollectionView DataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 10;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

//- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return <#expression#>;
//}


@end
