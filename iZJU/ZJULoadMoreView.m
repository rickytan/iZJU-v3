//
//  ZJULoadMoreView.m
//  ZJU
//
//  Created by ricky on 13-2-28.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "ZJULoadMoreView.h"

@interface ZJULoadMoreView ()
@property (nonatomic, assign) UIActivityIndicatorView *spinnerView;
@property (nonatomic, assign) UILabel *textLabel;
@end

@implementation ZJULoadMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIActivityIndicatorView*)spinnerView
{
    if (!_spinnerView) {
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinnerView.center = CGPointMake(72, self.bounds.size.height/2);
        _spinnerView.hidesWhenStopped = YES;
        _spinnerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_spinnerView];
        [_spinnerView release];
    }
    return _spinnerView;
}

- (UILabel*)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 24)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _textLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:_textLabel];
        [_textLabel release];
    }
    return _textLabel;
}

- (void)setLoadingState:(ZJULoadMoreViewState)loadingState
{
    if (_loadingState == loadingState)
        return;
    
    switch (loadingState) {
        case ZJULoadMoreViewStateNoMore:
            self.userInteractionEnabled = NO;
            self.textLabel.text = @"没有更多了";
            [self.spinnerView stopAnimating];
            break;
        case ZJULoadMoreViewStateMayHaveMore:
            self.userInteractionEnabled = YES;
            self.textLabel.text = @"点击加载更多";
            [self.spinnerView stopAnimating];
            break;
        case ZJULoadMoreViewStateLoading:
            self.userInteractionEnabled = NO;
            self.textLabel.text = @"加载中...";
            [self.spinnerView startAnimating];
            break;
        case ZJULoadMoreViewStateError:
            self.userInteractionEnabled = YES;
            self.textLabel.text = @"加载失败，点击重试！";
            [self.spinnerView stopAnimating];
            break;
        default:
            break;
    }
    _loadingState = loadingState;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self]) && event) {
        [self sendActionsForControlEvents:UIControlEventTouchDown];
        return YES;
    }
    return NO;
}

@end
