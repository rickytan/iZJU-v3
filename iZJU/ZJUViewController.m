//
//  ZJUViewController.m
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUViewController.h"
#import "ZJUCommentBubble.h"
#import "ZJUBadgeButton.h"
#import "UIView+iZJU.h"
#import "ZJUInfoViewController.h"
#import "ZJUInfoListViewController.h"
#import "ZJULoginViewController.h"
#import "ZJUAccountViewController.h"
#import "ZJUFeedbackViewController.h"
#import "ZJUCareerViewController.h"
#import "ZJUCareerInfoListViewController.h"
#import "ZJUCareerNewsListViewController.h"
#import "ZJUCareerTalkListViewController.h"
#import "ZJUUser.h"
#import "ZJUApp.h"
#import "ZJUWeatherView.h"
#import "Toast+UIView.h"
#import "BaiduMobStat.h"
#import "UIView+iZJU.h"
#import "UIApplication+RExtension.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <ASIHTTPRequest/Reachability.h>
#import "JPushAPI.h"


#define ICON_WIDTH  72.0f
#define ICON_HEIGHT 96.0f

#define NUM_COLS    3

#define ICON_MARGIN 12.0f

#define ICON_TAG_OFFSET 100

#define HANG_ZHONE_WEATHER @"http://www.weather.com.cn/data/sk/101210101.html"

@interface ZJUViewController () <NSURLConnectionDelegate, UIScrollViewDelegate>
{
    BOOL                _isPageChanging;
    
    ZJUWeatherView    * _weatherView;
    UITextView        * _weatherTextView;
    UILabel           * _versionLabel;
}
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) UIPageControl *pageControl;
@end

@implementation ZJUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    /*
     UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-bg.png"]];
     bg.frame = self.view.bounds;
     bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
     bg.contentMode = UIViewContentModeScaleToFill;
     [self.view addSubview:bg];
     [bg release];
     */
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture-bg.png"]];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.height -= 120;
    _scrollView.bottom = self.view.height;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    
    NSArray *applications = [self loadApplications];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat offsetX = (width - ICON_WIDTH * NUM_COLS - ICON_MARGIN * (NUM_COLS - 1)) / 2;
    CGFloat offsetY = 12.0f + (IS_IPHONE_5 ? (568 - 480) : 0);
    CGFloat deltaX = ICON_WIDTH + ICON_MARGIN;
    CGFloat deltaY = ICON_HEIGHT + 10.0;
    NSInteger numOfIconInPage = 9; //(IS_IPHONE_5)?12:8;
    
    int numOfPages = (int)ceilf(1.0 * applications.count / numOfIconInPage);
    
    //iconLayers = [NSMutableArray arrayWithCapacity:applications.count];
    for (int i=0; i < applications.count; ++i) {
        int page = i / numOfIconInPage;
        int pos = i % numOfIconInPage;
        int x = pos % NUM_COLS;
        int y = pos / NUM_COLS;
        
        NSDictionary *appInfo = [applications objectAtIndex:i];
        
        ZJUApp *icon = [ZJUApp appWithTarget:self
                                      action:@selector(onApp:)];
        UIImage *img = [UIImage imageNamed:[appInfo valueForKey:@"AppIcon"]];
        icon.iconImage = img;
        icon.iconText = [appInfo valueForKey:@"AppName"];
        icon.frame = CGRectMake(page * width + offsetX + deltaX * x,
                                offsetY + deltaY * y,
                                ICON_WIDTH, ICON_HEIGHT);
        //icon.hidden = YES;
        icon.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        icon.identifier = [appInfo valueForKey:@"AppAction"];
        
        [self.scrollView addSubview:icon];
        //[iconLayers addObject:icon.layer];
    }
    
    CGRect frame = self.scrollView.frame;
    [self.scrollView setContentSize:CGSizeMake(frame.size.width*numOfPages, 0)];
    self.pageControl.numberOfPages = numOfPages;
    self.scrollView.bounces = !(numOfPages <= 1);
    
    _versionLabel = [[UILabel alloc] init];
    _versionLabel.textColor = [UIColor whiteColor];
    _versionLabel.backgroundColor = [UIColor clearColor];
    _versionLabel.font = [UIFont systemFontOfSize:10];
    _versionLabel.text = [NSString stringWithFormat:@"v%@", [UIApplication sharedApplication].appVersion];
    [_versionLabel sizeToFit];
    _versionLabel.right = self.view.width - 4;
    _versionLabel.bottom = self.view.height - 4;
    [self.view addSubview:_versionLabel];
    [_versionLabel release];
    
    _weatherView = [[ZJUWeatherView alloc] init];
    _weatherView.image = [UIImage imageNamed:@"Weather.bundle/00.png"];
    [_weatherView sizeToFit];
    _weatherView.frame = CGRectMake(20, 20, 80, 80);
    _weatherView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_weatherView];
    [_weatherView release];
    
    _weatherTextView = [[UITextView alloc] init];
    _weatherTextView.backgroundColor = [UIColor clearColor];
    _weatherTextView.font = [UIFont systemFontOfSize:14];
    _weatherTextView.frame = CGRectMake(106, 10, 200, 100);
    _weatherTextView.userInteractionEnabled = NO;
    _weatherTextView.editable = NO;
    _weatherTextView.textColor = [UIColor whiteColor];
    _weatherTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_weatherTextView];
    [_weatherTextView release];
    
    [self loadWeather];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.presentedViewController) {
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:YES];
        [self.navigationController setToolbarHidden:YES
                                           animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.presentedViewController) {
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(IBAction)onPageChanged:(id)sender
{
    _isPageChanging = YES;
    CGRect frame = self.scrollView.frame;
    [self.scrollView setContentOffset:CGPointMake(frame.size.width*self.pageControl.currentPage, 0)
                             animated:YES];
}

- (void)onButton:(UIButton*)button
{
    ZJUInfoViewController *info = [[ZJUInfoViewController alloc] init];
    UIViewController *c0 = [[ZJUInfoListViewController alloc] init];
    c0.title = @"校园";
    UIViewController *c1 = [[ZJUCareerViewController alloc] init];
    c1.title = @"工作";
    UIViewController *c2 = [[ZJUInfoListViewController alloc] init];
    
    c2.title = @"交流";
    info.controllers = @[c0, c1, c2];
    [c0 release], [c1 release], [c2 release];
    [self.navigationController pushViewController:info
                                         animated:YES];
    [info release];
}

- (void)onApp:(ZJUApp*)app
{
    [self launchApplication:app.identifier];
}

- (void)onLogin:(UIButton*)button
{
    ZJUFeedbackViewController *feedback = [[ZJUFeedbackViewController alloc] init];
    [self.navigationController pushViewController:feedback
                                         animated:YES];
    [feedback release];
    return;
    ZJULoginViewController *login = [[ZJULoginViewController alloc] init];
    [self presentModalViewController:login
                            animated:YES];
    [login release];
}

- (void)onAccount:(UIButton*)button
{
    
    ZJUAccountViewController *account = [[ZJUAccountViewController alloc] init];
    account.user = [ZJUUser currentUser];
    [self.navigationController pushViewController:account
                                         animated:YES];
    [account release];
    
}

- (void)onHide:(id)sender
{
    if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
    }
    else
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:YES];
}


#pragma mark - Private Methods

- (void)loadWeather
{
    _weatherTextView.text = @"更新中...";
    
    NSURL *url = [NSURL URLWithString:HANG_ZHONE_WEATHER];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.cachePolicy = ASIDontLoadCachePolicy;
    request.timeOutSeconds = 4.0f;
    __block typeof(self) weakSelf = self;
    [request setCompletionBlock:^{
        id JSON = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                  options:NSJSONReadingAllowFragments
                                                    error:NULL];
        if (JSON) {
            NSDictionary *info = [JSON objectForKey:@"weatherinfo"];
            NSString *city = [info objectForKey:@"city"];
            NSString *temp = [info objectForKey:@"temp"];
            NSString *wind = [info objectForKey:@"WD"];
            NSString *ws = [info objectForKey:@"WS"];
            NSString *wet = [info objectForKey:@"SD"];
            NSString *time = [info objectForKey:@"time"];
            NSString *imgID = [info objectForKey:@"WSE"];
            
            NSString *text = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"></head><body style=\"color:white;\"><span style='font-size:32px;'>%@</span>&nbsp&nbsp温度：%@˚<br/>%@ %@ 相对湿度：%@<br/>更新时间：%@</body></html>", city, temp, wind, ws, wet,time];
            NSString *image = [NSString stringWithFormat:@"Weather.bundle/%02d.png", [imgID intValue]];
            [weakSelf->_weatherTextView setValue:text
                                forKey:@"contentToHTMLString"];
            //[weakSelf->_weatherTextView sizeToFit];
            weakSelf->_weatherView.image = [UIImage imageNamed:image];
            [weakSelf->_weatherView startAnimation];
            [NSTimer scheduledTimerWithTimeInterval:60 * 30.0
                                             target:weakSelf
                                           selector:@selector(loadWeather)
                                           userInfo:nil
                                            repeats:NO];
        }
        else {
            _weatherTextView.text = @"更新失败!等待重试...";
            [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:weakSelf
                                           selector:@selector(loadWeather)
                                           userInfo:nil
                                            repeats:NO];
        }
    }];
    [request setFailedBlock:^{
        weakSelf->_weatherTextView.text = @"更新失败!等待重试...";
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:weakSelf
                                       selector:@selector(loadWeather)
                                       userInfo:nil
                                        repeats:NO];
    }];
    [request startAsynchronous];
}

- (NSArray*)loadApplications
{
#ifdef DEBUG
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Applications"
                                                     ofType:@"plist"];
#else
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Applications"
                                                     ofType:@"plist"];
#endif
    NSArray *apps = [NSArray arrayWithContentsOfFile:path];
    return apps;
}

- (void)launchApplication:(NSString *)action
{
    Class controllerClass = NSClassFromString(action);
    
    if ([controllerClass isSubclassOfClass:UIViewController.class]) {
        UIViewController *controller = [[controllerClass alloc] init];
        //controller.navigationItem.leftBarButtonItem = self.backButton;
        //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.navigationController pushViewController:controller
                                             animated:YES];
        [controller release];
        //[nav release];
    }
    /*
     else {
     if ([controllerClass conformsToProtocol:@protocol(AppAction)]) {
     id<AppAction> app = [[controllerClass alloc] init];
     [app launchWithController:self];
     }
     }
     */
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isPageChanging)
        return;
    
    CGPoint offset = self.scrollView.contentOffset;
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat offsetX = offset.x;
    
    int currentPage = (int)floorf(((offsetX + width / 2.0) / width));
    self.pageControl.currentPage = currentPage;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isPageChanging = NO;
}

@end
