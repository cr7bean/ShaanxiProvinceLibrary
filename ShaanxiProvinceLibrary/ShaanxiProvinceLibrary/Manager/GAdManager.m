//
//  AdManager.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/29.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "GAdManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GVUserDefaults+library.h"
#import <Masonry.h>
#import <SDVersion.h>
#import "NSDate+Tools.h"

#define AD_ID ca-app-pub-1347388959435581/4321619556

@interface GAdManager ()<GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, weak) id viewController;


@end

@implementation GAdManager


+ (void) showAdOnViewController: (id) controller
                      canOffset: (BOOL) canOffset
{
    GAdManager *manager = [GAdManager shareManager];
    
    // 判断是否显示广告
    BOOL purchase = [GVUserDefaults standardUserDefaults].removeAdState == 19881012 ?:NO;
    BOOL click;
    
    NSDate *lastclick = [GVUserDefaults standardUserDefaults].clickADDate;
    if (lastclick) {
         NSInteger dayOffset = [NSDate daysFromDate: lastclick];
        NSLog(@"dayoffset: %lu", (long)dayOffset);
        if (dayOffset <= 2 && dayOffset >=0) {
            click = YES;
        }else{
            click = NO;
        }
    }else{
        click = NO;
    }
    NSLog(@"showAdState: purchaseState %lu\npurchase: %d\nlastclick: %@\nclik: %d", (unsigned long)[GVUserDefaults standardUserDefaults].removeAdState, purchase, lastclick, click);
    
    if (!(purchase || click)) {
        [manager configurateBannerView: controller canOffset: canOffset];
    }
}

+ (instancetype) shareManager
{
    static GAdManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [GAdManager new];
    });
    return manager;
}

- (void) configurateBannerView: (id) controller
                     canOffset: (BOOL) canOffset
{
    _viewController = controller;
    self.bannerView = [GADBannerView new];
    [[controller view] addSubview: _bannerView];
    
    CGFloat height;
    if ([SDVersion deviceVersion] == iPhone6Plus) {
        height = 93;
    }else{
        height = 64;
    }
    [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        if (canOffset) {
            make.bottom.mas_equalTo(-height);
        }else{
            make.bottom.mas_equalTo(0);
        }
    }];
    self.bannerView.delegate = self;
    self.bannerView.rootViewController = controller;
    self.bannerView.adUnitID = @"ca-app-pub-1347388959435581/4321619556";
    self.bannerView.backgroundColor = [UIColor greenColor];
    
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[kGADSimulatorID];
    request.testDevices = @[@"8b8f4cc1bcabe82496ccdbb051c34c37" ];
    [self.bannerView loadRequest: request];
    self.bannerView.hidden = YES;
    NSLog(@"bannerView：%p%@", _bannerView, _viewController);
}


#pragma mark - GADBannerViewDelegate

- (void) adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.bannerView.hidden = NO;
    NSLog(@"adViewDidReceiveAd: %@", _viewController);
}

- (void) adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"bannerViewFail: %@%@", error.localizedDescription, _viewController);
}

- (void) adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    [GVUserDefaults standardUserDefaults].clickADDate = [NSDate date];
    NSLog(@"adViewWillLeaveApplication: %@", _viewController);
}


@end
