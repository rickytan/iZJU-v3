//
//  ZJUWebView.m
//  iZJU
//
//  Created by ricky on 13-6-11.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUWebView.h"

@interface ZJUWebView ()
@property (nonatomic, retain) NSArray *originMenuItems;
@end

@implementation ZJUWebView

- (void)dealloc
{
    [[UIMenuController sharedMenuController] setMenuItems:self.originMenuItems];
    self.originMenuItems = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"分享"
                                                      action:@selector(onShare:)];
        self.originMenuItems = [[UIMenuController sharedMenuController] menuItems];
        [[UIMenuController sharedMenuController] setMenuItems:@[item]];
        [[UIMenuController sharedMenuController] update];
        [item release];
        
        self.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview)
        return;
    if (self.subviews.count) {
        UIView *view = [self.subviews lastObject];
        for (UIView *v in view.subviews) {
            if ([v isKindOfClass:[UIImageView class]])
                [v removeFromSuperview];
        }
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onShare:))
        return YES;
    return [super canPerformAction:action withSender:sender];
}

- (void)onShare:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(webViewDidPressShare:)])
        [self.delegate webViewDidPressShare:self];
}

@end
