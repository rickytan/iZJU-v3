//
//  ZJUWebView.h
//  iZJU
//
//  Created by ricky on 13-6-11.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJUWebView;

@protocol ZJUWebViewDelegate <UIWebViewDelegate>
@optional
- (void)webViewDidPressShare:(ZJUWebView *)webView;

@end

@interface ZJUWebView : UIWebView
@property (nonatomic, assign) id<ZJUWebViewDelegate> delegate;
@end
