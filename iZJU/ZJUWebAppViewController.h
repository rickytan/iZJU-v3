//
//  ZJUWebAppViewController.h
//  iZJU
//
//  Created by ricky on 13-11-13.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBaseViewController.h"

@interface ZJUWebAppViewController : ZJUBaseViewController
@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, retain) NSURL *appURL;
@end
