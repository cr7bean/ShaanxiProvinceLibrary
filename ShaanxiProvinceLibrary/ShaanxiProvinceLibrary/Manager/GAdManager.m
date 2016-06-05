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

#define AD_ID ca-app-pub-1347388959435581/4321619556

@interface GAdManager ()<GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;


@end

@implementation GAdManager



+ (void) showAdOnViewController: (id) controller
{
    GAdManager *manager = [GAdManager new];
    [manager configurateBannerView: [controller view]];
}

- (void) configurateBannerView: (UIView *) view
{
    self.bannerView = [GADBannerView new];
    [view addSubview: _bannerView];
    
    CGFloat height;
    if ([SDVersion deviceVersion] == iPhone6Plus) {
        height = 93;
    }else{
        height = 64;
    }
    [_bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
        make.bottom.mas_equalTo(-height);
    }];
    self.bannerView.delegate = self;
    self.bannerView.rootViewController = _viewController;
    self.bannerView.adUnitID = @"ca-app-pub-1347388959435581/4321619556";
    self.bannerView.backgroundColor = [UIColor greenColor];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID];
    [self.bannerView loadRequest: request];
}




#pragma mark - GADBannerViewDelegate

- (void) adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidReceiveAd: %@", _viewController);
}

- (void) adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"bannerViewFail: %@", error.localizedDescription);
}

- (void) adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    NSLog(@"adViewWillLeaveApplication");
}


@end
