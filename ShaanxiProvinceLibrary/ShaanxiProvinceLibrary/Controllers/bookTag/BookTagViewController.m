//
//  BookTagViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/29.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookTagViewController.h"
#import <CSStickyHeaderFlowLayout.h>
#import "BookTagCollectionViewCell.h"
#import "BookTagCollectionReusableView.h"
#import <Masonry.h>
#import "ParseHTML.h"
#import "BookTagListViewController.h"
#import "BookTagSearchView.h"


@interface BookTagViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) BookTagSearchView *tagSearchView;

@end

@implementation BookTagViewController
{
    NSMutableArray *_booktagsArray;
    NSArray *_titleArray;
}

# pragma mark - lifeCycle

- (IBAction)showViews:(id)sender
{
    self.tagSearchView.hidden = NO;
    [self.tagSearchView.searchBar becomeFirstResponder];
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.tagSearchView.titleView.frame = CGRectMake(0, 0, _tagSearchView.screenWidth, _tagSearchView.viewHeight);
                     } completion:^(BOOL finished) {
//                         [self.tagSearchView.searchBar becomeFirstResponder];
                     }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _booktagsArray = [NSMutableArray new];
    _titleArray = @[@"我的收藏",@"图书销售榜单",@"文学",@"流行", @"文化", @"生活", @"经管", @"科技"];
    _booktagsArray = [NSMutableArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"tags" ofType: @"plist"]];
    [self.collectionView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - getter

- (UICollectionView *) collectionView
{
    if (!_collectionView) {
        CSStickyHeaderFlowLayout *layout = [CSStickyHeaderFlowLayout new];
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout: layout];
        [self.view addSubview: _collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(self.mas_topLayoutGuide);
            make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
            
            
        }];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    
        _collectionView.backgroundColor = [UIColor whiteColor];
        

        [_collectionView registerClass: [BookTagCollectionViewCell class] forCellWithReuseIdentifier: @"cell"];
        [_collectionView registerClass: [BookTagCollectionReusableView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: @"header"];
    }
    return _collectionView;
}

- (BookTagSearchView *) tagSearchView
{
    if (!_tagSearchView) {
        _tagSearchView = [[BookTagSearchView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        _tagSearchView.backgroundColor = [UIColor colorWithRed:63.5/255.0 green: 63.5/255.0 blue:63.5/255.0 alpha: 0.7];
        [self.navigationController.view addSubview: _tagSearchView];
        _tagSearchView.hidden = YES;
        _tagSearchView.searchBar.delegate = self;
    }
    return _tagSearchView;
}

# pragma mark - UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _booktagsArray.count;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_booktagsArray[section] count];

}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"cell" forIndexPath: indexPath];

    cell.bookTagName = [_booktagsArray[indexPath.section] objectAtIndex: indexPath.item];
    return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        BookTagCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: @"header" forIndexPath: indexPath];
        header.backgroundColor = [UIColor colorWithRed:0.980 green:0.980 blue:0.980 alpha:1.0];
        header.title = _titleArray[indexPath.section];
        return header;
    }
    return nil;
}

# pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tag = [_booktagsArray[indexPath.section] objectAtIndex: indexPath.item];
    contentType type;
    if ([tag isEqualToString: @"亚马逊图书"]) {
        type = contentTypeAmazon;
    }else if ([tag isEqualToString: @"京东图书"]){
        type = contentTypeJD;
    }else if ([tag isEqualToString: @"当当图书"]){
        type = contentTypeDD;
    }else{
        type = contentTypeDoubanTag;
    }
    
    BookTagListViewController *controller = [[BookTagListViewController alloc] initWithTagName: tag contentType: type];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
}

- (void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookTagCollectionViewCell *cell = (BookTagCollectionViewCell*)[collectionView cellForItemAtIndexPath: indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1];
    cell.label.textColor = [UIColor whiteColor];
}

- (void) collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookTagCollectionViewCell *cell = (BookTagCollectionViewCell*)[collectionView cellForItemAtIndexPath: indexPath];
    cell.contentView.backgroundColor = nil;
    cell.label.textColor = nil;
}

# pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *tag = [_booktagsArray[indexPath.section] objectAtIndex: indexPath.item];
    return [tag sizeWithAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}];
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(200, 30);
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (![_booktagsArray[section] count]) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return  UIEdgeInsetsMake(15, 15, 15, 25);
    }
}


# pragma mark - UISearchBarDelegate

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.tagSearchView.titleView.frame = CGRectMake(0, -_tagSearchView.viewHeight, _tagSearchView.screenWidth, _tagSearchView.viewHeight);
//                         [self.tagSearchView.searchBar resignFirstResponder];
//                         self.tagSearchView.hidden = YES;
                     } completion:^(BOOL finished) {
                         [self.tagSearchView.searchBar resignFirstResponder];
                         self.tagSearchView.hidden = YES;
                     }];
    
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.tagSearchView.titleView.frame = CGRectMake(0, -_tagSearchView.viewHeight, _tagSearchView.screenWidth, _tagSearchView.viewHeight);
    [self.tagSearchView.searchBar resignFirstResponder];
    self.tagSearchView.hidden = YES;
    
    contentType type = contentTypeDoubanTag;
    BookTagListViewController *controller = [[BookTagListViewController alloc] initWithTagName: searchBar.text contentType: type];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: controller animated: YES];
}



@end
