//
//  ZJUInfoDetailViewController.m
//  iZJU
//
//  Created by ricky on 13-6-8.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUInfoDetailViewController.h"
#import "ZJUCommentBubble.h"
#import "ZJUCommentViewController.h"
#import "ZJUWebView.h"
#import "UIView+iZJU.h"
#import "Toast+UIView.h"
#import "ZJUWebImageView.h"
#import "ZJUFavoriteManager.h"
#import "ZJULoginViewController.h"
#import "ZJUUser.h"
#import "NSString+HTMLFilter.h"
#import "SVModalWebViewController.h"
#import <QuickLook/QuickLook.h>
#import <QuartzCore/QuartzCore.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>

@interface ZJURenRenActivity : UIActivity
@end

@implementation ZJURenRenActivity

- (NSString*)activityType
{
    return @"org.izju.ShareKit.renren";
}

- (NSString*)activityTitle
{
    return @"Test";
}

- (UIImage*)activityImage
{
    return [UIImage imageNamed:@"logo.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[NSString class]] || [obj conformsToProtocol:@protocol(UIActivityItemSource)])
            return YES;
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    
}

- (void)performActivity
{
    [self activityDidFinish:YES];
}

@end

@interface ZJUInfoDetailViewController ()
<ZJUWebViewDelegate,
UIGestureRecognizerDelegate,
UIAlertViewDelegate,
UIScrollViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerView;
@property (nonatomic, retain) UILabel *failLabel;
@property (nonatomic, retain) ZJUCommentBubble *comment;
@property (nonatomic, retain) UIBarButtonItem *commentItem;
@property (nonatomic, retain) UIButton *favButton;
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) NSString *shareText;
@property (nonatomic, retain) NSNumber *newsID;
@property (nonatomic, assign, getter = isLoadFailed) BOOL loadFailed;
- (void)reload;
- (void)loadTemplatedPage;
- (void)loadURL;
- (void)loadEmployNews;
- (NSString*)buildWebPageForEmployNewsWithJSON:(id)JSON;
@end

@implementation ZJUInfoDetailViewController
@synthesize imageURL = _imageURL;

- (void)dealloc
{
    self.webView = nil;
    self.comment = nil;
    self.spinnerView = nil;
    self.failLabel = nil;
    self.favButton = nil;
    self.shareText = nil;
    self.newsID = nil;
    self.imageURL = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.autoresizesSubviews = YES;
    
    _webView = [[ZJUWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];// [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    _webView.hidden = YES;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinnerView.center = self.view.center;
    //_spinnerView.top = 220;
    _spinnerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_spinnerView];
    
    _failLabel = [[UILabel alloc] init];
    _failLabel.textColor = [UIColor lightGrayColor];
    _failLabel.font = [UIFont systemFontOfSize:14];
    _failLabel.backgroundColor = [UIColor clearColor];
    _failLabel.textAlignment = UITextAlignmentCenter;
    _failLabel.text = @"加载失败\n请点击重试";
    _failLabel.numberOfLines = 3;
    _failLabel.hidden = YES;
    [_failLabel sizeToFit];
    _failLabel.center = CGPointMake(self.view.width / 2, 200);
    _failLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_failLabel];
    
    _navbarShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-shadow.png"]];
    _navbarShadowView.center = CGPointMake(self.view.width / 2, 2.5);
    _navbarShadowView.alpha = 0.0;
    _navbarShadowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_navbarShadowView];
    [_navbarShadowView release];
    
    _comment = [[ZJUCommentBubble alloc] init];
    _comment.adjustsImageWhenDisabled = NO;
    [_comment addTarget:self
                 action:@selector(onComment:)
       forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    self.comment.text = @"… 评论";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.comment];
    self.commentItem = rightItem;
    self.comment.enabled = NO;
    self.navigationItem.rightBarButtonItem = [rightItem autorelease];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onTap:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    [tap release];
    
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    if (!self.presentedViewController) {
        _originNavbarImage = [[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] retain];
        if (IS_IOS_6)
            _originShadowImage = [self.navigationController.navigationBar.shadowImage retain];
    }
    [UIView setAnimationsEnabled:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar-white.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    [UIView setAnimationsEnabled:YES];
    if (IS_IOS_6)
        self.navigationController.navigationBar.shadowImage = [[[UIImage alloc] init] autorelease];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!self.presentedViewController) {
        [UIView setAnimationsEnabled:NO];
        [self.navigationController.navigationBar setBackgroundImage:[_originNavbarImage autorelease]
                                                      forBarMetrics:UIBarMetricsDefault];
        if (IS_IOS_6)
            self.navigationController.navigationBar.shadowImage = [_originShadowImage autorelease];
        [UIView setAnimationsEnabled:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
}

#pragma mark - Actions

- (void)onComment:(id)sender
{
    if (self.directURL) {
        // Nothing
    }
    else if (self.htmlTemplate.length > 0 && self.url) {
        //[self loadTemplatedPage];
    }
    else if (self.url) {
        if (self.newsID) {
            ZJUCommentViewController *comment = [[ZJUCommentViewController alloc] init];
            comment.newsID = self.newsID.intValue;
            [self.navigationController pushViewController:comment
                                                 animated:YES];
            [comment release];
        }
    }
    else if (self.empolyItem) {
        //[self loadEmployNews];
    }
}

- (void)onFavorite:(UIButton*)button
{
    if (![ZJUUser currentUser].isLogin) {
        [[[[UIAlertView alloc] initWithTitle:@"登录后才能收藏"
                                     message:@"是否现在登录？"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                           otherButtonTitles:@"登录", nil] autorelease] show];
        return;
    }
    
    self.favButton.selected = !self.favButton.isSelected;
    if (self.favButton.isSelected) {
        [ZJUFavoriteManager addFavoriteWithID:self.newsID.stringValue];
        [self.view makeToast:@"已收藏！"];
    }
    else {
        [ZJUFavoriteManager removeFavoriteWithID:self.newsID.stringValue];
        [self.view makeToast:@"取消收藏"];
    }
}

- (void)onTap:(UITapGestureRecognizer*)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:
        {
            if (self.isLoadFailed) {
                [self reload];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Methods

- (void)setLoadFailed:(BOOL)loadFailed
{
    if (_loadFailed != loadFailed) {
        _loadFailed = loadFailed;
        self.failLabel.hidden = !_loadFailed;
    }
}

- (void)reload
{
    self.loadFailed = NO;
    
    if (self.directURL) {
        self.comment.hidden = YES;
        self.webView.opaque = YES;
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.directURL]];
    }
    else if (self.htmlTemplate.length > 0 && self.url) {
        self.comment.text = @"… 点击";
        [self loadTemplatedPage];
    }
    else if (self.url) {
        if (!self.favButton) {
            UIButton *favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [favBtn setBackgroundImage:[UIImage imageNamed:@"star-off.png"] forState:UIControlStateNormal];
            [favBtn setBackgroundImage:[UIImage imageNamed:@"star-on.png"] forState:UIControlStateSelected];
            [favBtn addTarget:self
                       action:@selector(onFavorite:)
             forControlEvents:UIControlEventTouchUpInside];
            [favBtn sizeToFit];
            
            self.favButton = favBtn;
        }
        self.favButton.enabled = NO;
        
        UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithCustomView:self.favButton];
        [self.navigationItem setRightBarButtonItems:@[favItem, self.commentItem]
                                           animated:YES];
        [favItem release];
        [self loadURL];
    }
    else if (self.empolyItem) {
        self.comment.text = @"… 点击";
        [self loadEmployNews];
    }
}

- (void)loadTemplatedPage
{
    [self.spinnerView startAnimating];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.url];
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
    request.timeOutSeconds = 8.0f;
    __block typeof(self) weakSelf = self;
    [request setCompletionBlock:^{
        NSError *e = nil;
        NSData *d = request.responseData;
        NSString *str = [[NSString alloc] initWithData:d
                                              encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        d = [str dataUsingEncoding:NSUTF8StringEncoding];
        [str release];
        id JSON = [NSJSONSerialization JSONObjectWithData:d
                                                  options:NSJSONReadingAllowFragments
                                                    error:&e];
        if ([JSON isKindOfClass:[NSArray class]])
            JSON = [JSON lastObject];
        
        if (!e) {
            NSString *path = [[NSBundle mainBundle] pathForResource:weakSelf.htmlTemplate
                                                             ofType:nil];
            NSString *template = [NSString stringWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding
                                                              error:&e];
            NSString *htmlString = [template stringByReplacingVariableInDictionary:JSON];
            [weakSelf.webView loadHTMLString:htmlString
                                     baseURL:[NSURL URLWithString:@"http://www.career.zju.edu.cn/"]];
            int clicks = 0;
            if ([JSON objectForKey:@"djsl"])
                clicks = [[JSON objectForKey:@"djsl"] intValue];
            else
                clicks = [[JSON objectForKey:@"djl"] intValue];
            weakSelf.comment.text = [NSString stringWithFormat:@"%d 点击",clicks];
        }
        else {
            weakSelf.loadFailed = YES;
            [weakSelf.spinnerView stopAnimating];
        }
    }];
    [request setFailedBlock:^{
        weakSelf.loadFailed = YES;
        [weakSelf.spinnerView stopAnimating];
    }];
    [request startAsynchronous];
}

- (void)loadURL
{
    [self.spinnerView startAnimating];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.url];
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
    request.timeOutSeconds = 8.0f;
    __block typeof(self) weakSelf = self;
    [request setCompletionBlock:^{
        NSError *e = nil;
        id JSON = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                  options:NSJSONReadingAllowFragments
                                                    error:&e];
        if (!e) {
            weakSelf.newsID = [NSNumber numberWithInt:[[JSON valueForKey:@"id"] unsignedIntValue]];
            weakSelf.favButton.selected = [ZJUFavoriteManager isFavoriteNewsWithID:weakSelf.newsID.stringValue];
            weakSelf.favButton.enabled = YES;
            
            weakSelf.comment.text = [NSString stringWithFormat:@"%d 评论",[[JSON objectForKey:@"replycount"] intValue]];
            weakSelf.comment.enabled = YES;
            
            NSString *htmlString = [JSON valueForKeyPath:@"content.html"];
            [weakSelf.webView loadHTMLString:htmlString
                                     baseURL:nil];
        }
        else {
            weakSelf.loadFailed = YES;
            [weakSelf.spinnerView stopAnimating];
        }
    }];
    [request setFailedBlock:^{
        weakSelf.loadFailed = YES;
        [weakSelf.spinnerView stopAnimating];
    }];
    [request startAsynchronous];
}

- (void)loadEmployNews
{
    static NSString *bashURL = @"http://www.career.zju.edu.cn/ejob/data_detail_index.do?pkValue=";
    
    [self.spinnerView startAnimating];
    
    NSString *urlStr = [bashURL stringByAppendingString:[self.empolyItem valueForKey:@"id"]];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"+"
                                               withString:@"%2B"];
    NSURL *url = [NSURL URLWithString:urlStr];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
    request.timeOutSeconds = 8.0f;
    __block typeof(self) weakSelf = self;
    [request setCompletionBlock:^{
        NSError *e = nil;
        NSData *d = request.responseData;
        NSString *str = [[NSString alloc] initWithData:d
                                              encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        d = [str dataUsingEncoding:NSUTF8StringEncoding];
        [str release];
        id JSON = [NSJSONSerialization JSONObjectWithData:d
                                                  options:NSJSONReadingAllowFragments
                                                    error:&e];
        if ([JSON isKindOfClass:[NSArray class]])
            JSON = [JSON lastObject];
        if (!e) {
            id url = [JSON objectForKey:@"zpnet"];
            if (![url isKindOfClass:[NSNull class]]) {
                weakSelf.webView.opaque = YES;
                [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
            }
            else
                [weakSelf.webView loadHTMLString:[weakSelf buildWebPageForEmployNewsWithJSON:JSON]
                                         baseURL:[NSURL URLWithString:@"http://www.career.zju.edu.cn/ejob/"]];
            weakSelf.comment.text = [NSString stringWithFormat:@"%@ 点击",[weakSelf.empolyItem valueForKey:@"clicks"]];
        }
        else {
            weakSelf.loadFailed = YES;
            [weakSelf.spinnerView stopAnimating];
        }
    }];
    [request setFailedBlock:^{
        weakSelf.loadFailed = YES;
        [weakSelf.view makeToast:request.error.localizedDescription];
        [weakSelf.spinnerView stopAnimating];
    }];
    [request startAsynchronous];
}

- (NSString*)buildWebPageForEmployNewsWithJSON:(id)JSON
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mobile"
                                                     ofType:@"html"];
    NSError *error = nil;
    NSMutableString *mobilePage = [NSMutableString stringWithContentsOfFile:path
                                                                   encoding:NSUTF8StringEncoding
                                                                      error:&error];
    [mobilePage replaceOccurrencesOfString:@"${title}"
                                withString:[self.empolyItem valueForKey:@"title"]
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, mobilePage.length)];
    [mobilePage replaceOccurrencesOfString:@"${date}"
                                withString:[NSString stringWithFormat:@"截止时间：%@",[self.empolyItem valueForKey:@"deadline"]]
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, mobilePage.length)];
    
    NSMutableString *content = [NSMutableString string];
    NSArray *employments = [JSON objectForKey:@"employments"];
    for (NSDictionary *item in employments) {
        NSString *xueli = [NSString stringWithFormat:@"<dd><b>学历要求：</b>%@</dd>",[item valueForKey:@"zdxl"]];
        NSString *gangwei = [NSString stringWithFormat:@"<dd><b>招聘岗位：</b>%@</dd>",[item valueForKey:@"zwmc"]];
        NSString *place = [NSString stringWithFormat:@"<dd><b>工作地点：</b>%@</dd>",[item valueForKey:@"gzdd"]];
        NSString *account = [NSString stringWithFormat:@"<dd><b>招聘人数：</b>%@</dd>",[item valueForKey:@"zprs"]];
        NSString *htmlString = [item valueForKey:@"zwms"];
        if ([htmlString isKindOfClass:[NSNull class]])
            htmlString = @"";
        else
            htmlString = [htmlString stringByFilterAttributes];
        NSString *intro = [NSString stringWithFormat:@"<hr /><br />%@",htmlString];
        [content appendFormat:@"<section>%@%@%@%@%@</section>",xueli,gangwei,place,account,intro];
    }
    [mobilePage replaceOccurrencesOfString:@"${content}"
                                withString:content
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, mobilePage.length)];
    return mobilePage;
}

#pragma mark - UIWeb Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *scheme = request.URL.scheme;
        if ([scheme isEqualToString:@"http"]) {
            NSArray *imageExt = @[@"jpg", @"jpeg",@"webp", @"png", @"bmp",@"gif"];
            if ([imageExt containsObject:request.URL.pathExtension.lowercaseString]) {
                self.imageURL = request.URL;
                CGFloat x = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector(\"img[src='%@']\").offsetLeft - window.scrollX",self.imageURL.absoluteString]] floatValue];
                CGFloat y = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector(\"img[src='%@']\").offsetTop - window.scrollY",self.imageURL.absoluteString]] floatValue];
                CGFloat w = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector(\"img[src='%@']\").clientWidth",self.imageURL.absoluteString]] floatValue];
                CGFloat h = [[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector(\"img[src='%@']\").clientHeight",self.imageURL.absoluteString]] floatValue];
                _imageRect = CGRectMake(x, y, w, h);
                
                ZJUWebImageView *webImage = [[ZJUWebImageView alloc] init];
                webImage.originRect = [self.webView convertRect:_imageRect
                                                         toView:self.view.window];
                webImage.imageURL = self.imageURL;
                [webImage show];
                [webImage release];
                return NO;
            }
        }
        
        if ([@[@"http", @"https", @"ftp"] containsObject:scheme]) {
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:request.URL];
            [self presentModalViewController:webViewController
                                    animated:YES];
            [webViewController release];
            return NO;
        }
        
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinnerView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.directURL)
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.webView.hidden = NO;
    self.webView.alpha = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.webView.alpha = 1.0;
                     }];
    [self.spinnerView stopAnimating];
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
    self.webView.hidden = NO;
    self.webView.alpha = 1.0;
    //self.loadFailed = YES;
    [self.spinnerView stopAnimating];
}

- (void)webViewDidPressShare:(ZJUWebView *)webView
{
    [[UIApplication sharedApplication] sendAction:@selector(copy:)
                                               to:nil
                                             from:self
                                         forEvent:nil];
    self.shareText = [UIPasteboard generalPasteboard].string;
    if (IS_IOS_6) {
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[self.shareText, [UIImage imageNamed:@"icon.png"]]
                                                                               applicationActivities:nil];
        activity.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter];
        [self presentModalViewController:activity
                                animated:YES];
        [activity release];
    }
    else {
        [[[[UIAlertView alloc] initWithTitle:@"分享"
                                     message:@"iOS 6.0 以下还不支持T_T\n不过快啦^_^"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 0 ) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _navbarShadowView.alpha = 1.0;
                         }
                         completion:NULL];
    }
    else if (scrollView.contentOffset.y <= 0 ) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             _navbarShadowView.alpha = 0.0;
                         }
                         completion:NULL];
    }
}

#pragma mark - UIGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.isLoadFailed;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        ZJULoginViewController *loginController = [[ZJULoginViewController alloc] init];
        [self presentModalViewController:loginController
                                animated:YES];
        [loginController release];
    }
}

@end
