//
//  RemoveAdTableViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/28.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "RemoveAdViewController.h"
#import <StoreKit/StoreKit.h>

@interface RemoveAdViewController ()<SKProductsRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *request;

@end

@implementation RemoveAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self validateProductIndentifiers: @[@"LibraryRemoveAd0001"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"您可以点击应用内的广告，2天之内不会出现广告。也可以选择内购，去除广告。";
    }
    return nil;
}


# pragma mark - iAP

- (void) validateProductIndentifiers: (NSArray *) productIndentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray: productIndentifiers]];
    self.request = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
}

// SKProductsRequest Delegate
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    for (SKProduct *product in response.products) {
       
    }
}



- (NSString *)formattingProductPrice: (SKProduct *) product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

@end
