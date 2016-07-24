//
//  RemoveAdTableViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/28.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "RemoveAdViewController.h"
#import <StoreKit/StoreKit.h>
#import <MBProgressHUD.h>
#import <PSTAlertController.h>
#import "GVUserDefaults+library.h"

#define PURCHASE_STATE 19881012

@interface RemoveAdViewController ()<SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation RemoveAdViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
}

#pragma mark - Talbe view Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self buyProductWithIdentifiers: @[@"LibraryRemoveAd0001"]];
    }else{
        [self restoreProduct];
    }
}


#pragma mark - Table view data source

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"您可以点击应用内的广告，2天之内不会出现广告。也可以选择内购，去除广告。";
    }
    return nil;
}


#pragma mark - BuyProduct and restore

- (void) buyProductWithIdentifiers: (NSArray *) identifiers
{
    self.hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    [self validateProductIndentifiers: identifiers];
}

- (void) restoreProduct
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) validateProductIndentifiers: (NSArray *) productIndentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithArray: productIndentifiers]];
    self.request = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
}


#pragma mark - SKProductsRequest Delegate

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"productsRequest: %@", response.products);
    if (response.products.count) {
       SKProduct * product = response.products[0];
        SKPayment *payment = [SKPayment paymentWithProduct: product];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
}

#pragma mark - SKRequestDelegate

- (void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"finish");
    
}

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.hud.hidden = YES;
    NSLog(@"SKRequestdidDail%@", error.localizedDescription);
    [self showAlertWithTitle: @"购买失败" message: @"无法连接到 iTunes Store"];
}

#pragma mark - SKPaymentTransactionObserver

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    self.hud.hidden = YES;
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"SKPaymentTransaction: %@", transaction);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"TransactionStatePurchasing");
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                [self completeTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                [self failedTransaction: transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                [self restoreTransaction: transaction];
                break;
            }
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *) transaction
{
    NSLog(@"complete");
    [self recordPurchaseState];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void) restoreTransaction: (SKPaymentTransaction *) transaction
{
    NSLog(@"restore");
    [self recordPurchaseState];
    [self showAlertWithTitle: @"恢复购买成功" message: nil];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *) transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
         NSLog(@"failedTransaction: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - record purchase state

- (void) recordPurchaseState
{
    NSLog(@"%lu", (unsigned long)[GVUserDefaults standardUserDefaults].removeAdState);
    [GVUserDefaults standardUserDefaults].removeAdState = PURCHASE_STATE;
    NSLog(@"%lu", (unsigned long)[GVUserDefaults standardUserDefaults].removeAdState);
}


#pragma mark - PSTAlertController convenient constructor

- (void) showAlertWithTitle: (NSString *) title
                    message: (NSString *) message
{
    PSTAlertController *controller = [PSTAlertController alertWithTitle: title message: message];
    [controller addAction: [PSTAlertAction actionWithTitle: @"确定" style: PSTAlertActionStyleCancel handler: nil]];
    [controller showWithSender: nil controller: self animated: YES completion: nil];
}


@end
