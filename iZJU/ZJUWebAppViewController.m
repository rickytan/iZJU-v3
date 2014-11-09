//
//  ZJUWebAppViewController.m
//  iZJU
//
//  Created by ricky on 13-11-13.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUWebAppViewController.h"
#import "ZJUWebView.h"
#import "SVProgressHUD.h"

@interface ZJUWebAppViewController () <UIWebViewDelegate>
{
    UIActivityIndicatorView             * _spinnerView;
}
@end

@implementation ZJUWebAppViewController
@synthesize webView = _webView;

- (void)dealloc
{
    [_spinnerView release];
    [_webView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    _webView = [[ZJUWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.delegate = self;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_webView];
    
    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *waitItem = [[[UIBarButtonItem alloc] initWithCustomView:_spinnerView] autorelease];
    self.navigationItem.rightBarButtonItem = waitItem;

    NSURLRequest *request = [NSURLRequest requestWithURL:self.appURL];
    [self.webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_spinnerView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_spinnerView stopAnimating];
    [webView stringByEvaluatingJavaScriptFromString:
     @"document.body.style.webkitTouchCallout='none';"
     @"document.body.style.webkitUserSelect='none';"];
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
    [_spinnerView stopAnimating];
    [SVProgressHUD showErrorWithStatus:@"载入失败！"];
}

@end
