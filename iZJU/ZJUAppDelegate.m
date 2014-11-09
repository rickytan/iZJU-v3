//
//  ZJUAppDelegate.m
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUAppDelegate.h"
#import "Reachability.h"
#import "ZJUViewController.h"
#import "ZJUCareerViewController.h"
#import "ZJUInfoDetailViewController.h"
#import "ZJULibraryViewController.h"
#import "RTNavigationController.h"
#import "APService.h"
#import "ZJUUser.h"
#import "BaiduMobStat.h"
#import "ZJUURLCache.h"
#import "ZJUURLProtocol.h"
#import "UIApplication+RExtension.h"
//#import "RTNavigationController.h"

@implementation ZJUAppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void)onDismiss:(id)sender
{
    [self.viewController dismissModalViewControllerAnimated:YES];
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context
{
    [(UIWindow*)context removeFromSuperview];
    [(UIWindow*)context release];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
}

- (void)presentNotification:(NSDictionary*)userInfo
{
    if (!userInfo[@"type"])
        return;
    
    ZJUInfoDetailViewController *detail = [[ZJUInfoDetailViewController alloc] init];
    
    if ([userInfo[@"type"] isEqualToString:@"career"]) {
        detail.url = [NSURL URLWithString:[userInfo objectForKey:@"url"]];
        detail.htmlTemplate = [userInfo objectForKey:@"template"];
        detail.title = [userInfo objectForKey:@"title"];
    }
    else if ([userInfo[@"type"] isEqualToString:@"news"]) {
        detail.url = [NSURL URLWithString:[userInfo objectForKey:@"url"]];
    }
    else if ([userInfo[@"type"] isEqualToString:@"web"]) {
        detail.directURL = [NSURL URLWithString:[userInfo objectForKey:@"url"]];
    }
    
    UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(onDismiss:)];
    detail.navigationItem.leftBarButtonItem = [dismissItem autorelease];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detail];
    nav.navigationBar.translucent = NO;
    [self.viewController presentModalViewController:nav
                                           animated:YES];
    [detail release];
    [nav release];
}

- (void)initUIStyle
{
    if (IS_IOS_5) {
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar-with-shadow.png"]
                                           forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               UITextAttributeTextColor: RGB(0, 184, 255),
                                                               UITextAttributeFont: [UIFont boldSystemFontOfSize:20]
                                                               }];
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:2
                                                           forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
        //[[UIBarButtonItem appearance] setTintColor:DEFAULT_COLOR_SCHEME];
        //        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"back_btn.png"]
        //                                                          forState:UIControlStateNormal
        //                                                        barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"navbar-back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 32, 0, 0)]
                                                                                                      forState:UIControlStateNormal
                                                                                                    barMetrics:UIBarMetricsDefault];
        /*
         [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"baritem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
         
         [[UISegmentedControl appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[UIImage imageNamed:@"baritem.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)]
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
         */
        //[[UIToolbar appearance] setTintColor:DEFAULT_COLOR_SCHEME];
        //[[UIBarButtonItem appearanceWhenContainedIn:UINavigationBar.class, nil] setTintColor:DEFAULT_COLOR_SCHEME];
        
    }
    
    if (IS_IOS_7) {
        NSDictionary *textAttr = @{UITextAttributeFont: [UIFont systemFontOfSize:12],
                                   UITextAttributeTextColor: [UIColor whiteColor]};
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:textAttr
                                                                                                forState:UIControlStateNormal];
        [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"navbar-black-shadow.png"]];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"]
                                           forBarMetrics:UIBarMetricsDefault];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 1, 1)];
        [[UIColor clearColor] setFill];
        [path fill];
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[UINavigationBar appearance] setBackIndicatorImage:transparentImage];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:transparentImage];
    }
}

- (void)initBaidu
{
    BaiduMobStat *stat = [BaiduMobStat defaultStat];
    [stat startWithAppId:@"dc146297cf"];
}

- (void)checkForUpdate
{
    NSURL *update = [NSURL URLWithString:@"http://www.izju.org/ios_update.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:update];
    
    void(^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *r, NSData *d, NSError *e) {
        if (e) {
            [self performSelector:@selector(checkForUpdate)
                       withObject:nil
                       afterDelay:5.0];
            return;
        }
        NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *currVersion = [appInfo valueForKey:@"CFBundleVersion"];
        id json = [NSJSONSerialization JSONObjectWithData:d
                                                  options:NSJSONReadingAllowFragments
                                                    error:&e];
        if (json) {
            NSString *newVersion = [json valueForKey:@"version"];
            NSString *notifiedUpdateVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"NotifiedUpdateVersion"];
            if ([newVersion isEqualToString:notifiedUpdateVersion])
                return;
            
            if ([newVersion compare:currVersion
                            options:NSNumericSearch] == NSOrderedDescending) {
                
                updateURL = [[json valueForKey:@"update_url"] retain];
                NSNumber *num = [json objectForKey:@"update_type"];
                switch (num.intValue) {
                    case 0:
                        [[NSUserDefaults standardUserDefaults] setValue:newVersion
                                                                 forKey:@"NotifiedUpdateVersion"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    case 1:
                        [[[[UIAlertView alloc] initWithTitle:@"有新版本了！"
                                                     message:[json valueForKey:@"update_info"]
                                                    delegate:self
                                           cancelButtonTitle:@"知道了"
                                           otherButtonTitles:@"去看看", nil] autorelease] show];
                        break;
                    case 2:
                        [[[[UIAlertView alloc] initWithTitle:@"有新版本了！"
                                                     message:[json valueForKey:@"update_info"]
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"更新", nil] autorelease] show];
                        break;
                    default:
                        break;
                }
            }
        }
        else {
            [self performSelector:@selector(checkForUpdate)
                       withObject:nil
                       afterDelay:5.0];
        }
    };
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == ReachableViaWWAN) {
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:handler];
    }
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = application.statusBarFrame;
    
    application.applicationIconBadgeNumber = 0;
    
    [self initUIStyle];
    [self initBaidu];
    
    [self performSelector:@selector(checkForUpdate)
               withObject:nil
               afterDelay:3.0];
    
    [NSURLCache setSharedURLCache:[[[ZJUURLCache alloc] init] autorelease]];
    [NSURLProtocol registerClass:[ZJUURLProtocol class]];
    
    __block UIWindow *splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    splashWindow.userInteractionEnabled = NO;
    splashWindow.windowLevel = UIWindowLevelStatusBar + 1;
    
    __block UIImageView *splashImage = nil;
    if (IS_IPHONE_5)
        splashImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h.png"]];
    else
        splashImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    [splashWindow addSubview:splashImage];
    [splashImage release];
    
    splashWindow.hidden = NO;
    
    int64_t delaySeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        
        [UIView transitionWithView:splashWindow
                          duration:1.2
                           options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            [splashImage removeFromSuperview];
                        }
                        completion:^(BOOL finished) {
                            [splashWindow removeFromSuperview];
                            [splashWindow release];
                        }];
    });
    
    [APService setupWithOption:launchOptions];
    [APService registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    [APService setTags:[NSSet setWithObjects:@"iphone", nil]
                 alias:[ZJUUser currentUser].name
      callbackSelector:NULL
                object:nil];
    
    [application setStatusBarHidden:NO
                      withAnimation:UIStatusBarAnimationFade];
    
    self.window = [[[UIWindow alloc] initWithFrame:frame] autorelease];
    if (IS_IOS_7)
        self.window.tintColor = [UIColor whiteColor];
    // Override point for customization after application launch.
    self.viewController = [[[ZJUViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    nav.navigationBar.translucent = NO;
    //nav.navigationBarHidden = YES;
    frame.origin.y = CGRectGetMaxY(statusBarFrame);
    frame.size.height -= CGRectGetMaxY(statusBarFrame);
    nav.view.frame = frame;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [self presentNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    [self presentNotification:[launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] userInfo]];
    
    return YES;
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [APService handleRemoteNotification:userInfo];
    NSLog(@"%d", application.applicationState);
    
    application.applicationIconBadgeNumber = 0 ;//-= [[userInfo valueForKeyPath:@"aps.badge"] intValue];
    
    [self presentNotification:userInfo];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%d", application.applicationState);
    
    NSDictionary *userInfo = notification.userInfo;
    
    application.applicationIconBadgeNumber -= 1;
    
    [self presentNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    [[ZJUUser currentUser] saveToDisk];
}

#pragma mark - UIAlertView Delegate

// 去看看新版本
- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateURL]];
}

@end
