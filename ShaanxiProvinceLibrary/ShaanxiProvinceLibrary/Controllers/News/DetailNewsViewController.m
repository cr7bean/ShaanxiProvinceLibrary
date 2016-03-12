//
//  DetailNewsViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/26.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "DetailNewsViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>

@interface DetailNewsViewController ()<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation DetailNewsViewController
{
    NSURLRequest *_request;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

#pragma mark - lifeCycle

- (void) loadView
{
    self.view = self.webView;
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initProgressView];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        [_webView loadRequest: _request];
    });
    
//    [_webView loadRequest: _request];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.navigationController.navigationBar addSubview: _progressView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [_progressView removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

- (instancetype) initWithAddress: (NSString*) string
{
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString: string];
        self.request = [NSURLRequest requestWithURL: url];
    }
    return self;
}

- (void) initProgressView
{
    _progressProxy = [NJKWebViewProgress new];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat height = 2.0f;
    CGRect barBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, barBounds.size.height - height, barBounds.size.width, height);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame: barFrame];
}


#pragma mark - getter

- (UIWebView*) webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma webView delegate

- (void) webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress: progress animated: YES];
//    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

@end
