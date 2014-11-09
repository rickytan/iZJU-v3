//
//  ZJURadioViewController.m
//  iZJU
//
//  Created by ricky on 13-11-10.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJURadioViewController.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const RADIO_URL = @"http://api.izju.org/v2/app/radiostation";

@implementation ZJURadioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"西溪广播台";
        self.appURL = [NSURL URLWithString:RADIO_URL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
                   error:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (![request.URL.absoluteString isEqualToString:RADIO_URL])
        return [request.URL.absoluteString hasPrefix:@"http://m.ximalaya.com/2608024"];
    return YES;
}

@end
