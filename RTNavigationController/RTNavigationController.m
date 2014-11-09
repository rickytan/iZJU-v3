//
//  RTNavigationController.m
//  RTNavigationController
//
//  Created by ricky on 13-3-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTNavigationController.h"
#import <QuartzCore/QuartzCore.h>

#define PAN_THRESHOLD 64.0f


@interface RTNavigationController () <UINavigationBarDelegate>
@property (nonatomic, readwrite) NavigationState state;
@property (nonatomic, retain) UIViewController *toBeRemovedController;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIView *maskView;
- (void)onPan:(UIPanGestureRecognizer*)pan;
- (void)applyTranslationForView:(UIView*)view
                     withOffset:(CGFloat)offset;
- (UIImage*)takeScreenShot;
@end

@implementation RTNavigationController
@synthesize navigationBarHidden = _navigationBarHidden;

- (void)dealloc
{
    SAFE_RELEASE(_pan);
    self.maskView = nil;
    self.imageView = nil;
    
    SAFE_DEALLOC(super);
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(onPan:)];
        _pan.delegate = self;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    //self.wantsFullScreenLayout;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
    
    _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.userInteractionEnabled = NO;
    _maskView.alpha = 0.0f;
    _maskView.hidden = YES;
    _maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_maskView];
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:_pan];
    
    CATransform3D t = CATransform3DIdentity;
    //t.m34 = -0.002;
    self.view.layer.sublayerTransform = t;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (UIImage*)takeScreenShot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, [UIScreen mainScreen].scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)applyTranslationForView:(UIView *)view
                     withOffset:(CGFloat)offset
{
    _maskView.hidden = YES;
    _maskView.alpha = 0.0;
    
    switch (self.translationStyle) {
        case NavigationTranslationStyleDeeper:
            view.transform = CGAffineTransformMakeScale(0.96 + 0.04*offset, 0.96 + 0.04*offset);
        case NavigationTranslationStyleFade:
            _maskView.hidden = NO;
            _maskView.alpha = 0.8 * (1 - fabs(offset));
            break;
        default:
            break;
    }
}

- (void)showTmp
{
    if (self.state == NavigationStatePoping) {
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.imageView.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
                             self.view.transform = CGAffineTransformIdentity;
                             _maskView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             _maskView.hidden = YES;
                             [self.imageView removeFromSuperview];
                         }];
    }
    else if (self.state == NavigationStatePushing) {
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             _maskView.hidden = YES;
                             self.imageView.transform = CGAffineTransformIdentity;
                             [self.imageView removeFromSuperview];
                         }];
    }
}

- (void)showCurrent
{
    if (self.state == NavigationStatePoping) {
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.imageView.transform = CGAffineTransformIdentity;
                             self.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             _maskView.hidden = YES;
                             [self pushViewController:self.toBeRemovedController
                                             animated:NO];
                             [self.imageView removeFromSuperview];
                         }];
    }
    else if (self.state == NavigationStatePushing) {
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.imageView.transform = CGAffineTransformIdentity;
                             self.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
                         }
                         completion:^(BOOL finished) {
                             _maskView.hidden = YES;
                             [self popViewControllerAnimated:NO];
                             self.view.transform = CGAffineTransformIdentity;
                             [self.imageView removeFromSuperview];
                         }];
    }
}

- (void)setState:(NavigationState)state
{
    if (_state == state)
        return;
    
    switch (state) {
        case NavigationStateNormal:
            
            break;
        case NavigationStatePoping:
        {
            //UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(-4, -8, 8, self.view.bounds.size.height + 16)];
            
        }
            break;
        case NavigationStatePushing:
        {
            
        }
            break;
        default:
            break;
    }
    
    _state = state;
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    switch (_pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.imageView.image = [self takeScreenShot];
            
            CGPoint p = [_pan translationInView:self.view];
            
            if (p.x > 0) {
                [self.view.superview addSubview:self.imageView];
                self.toBeRemovedController = [self popViewControllerAnimated:NO];
                [self.view.superview bringSubviewToFront:self.imageView];
            }
            else {
                _currentTrans = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
                [self pushViewController:[self.topViewController nextViewControllerForRTNavigationController:self]
                                animated:NO];
                self.view.transform = _currentTrans;
            }
            
            if (self.state == NavigationStatePoping) {
            }
            else if (self.state == NavigationStatePushing) {

            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint p = [_pan translationInView:self.view];
            CGFloat tx = MAX(0.0,p.x  + _currentTrans.tx);
            
            if (self.state == NavigationStatePoping) {
                self.imageView.transform = CGAffineTransformMakeTranslation(tx, 0);
                [self applyTranslationForView:self.view
                                   withOffset:self.imageView.transform.tx / self.view.bounds.size.width];
            }
            else if (self.state == NavigationStatePushing) {
                self.view.transform = CGAffineTransformMakeTranslation(MIN(tx,_currentTrans.tx), 0);
                [self applyTranslationForView:self.imageView
                                   withOffset:self.view.transform.tx / self.view.bounds.size.width];
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint v = [_pan velocityInView:self.view];
            if (fabs(v.x) < 32.0) {
                CGPoint p = [_pan translationInView:self.view];
                if (fabs(p.x) > PAN_THRESHOLD) {
                    [self showTmp];
                }
                else
                    [self showCurrent];
            }
            else {
                if ((self.state == NavigationStatePoping && v.x > 0) ||
                    (self.state == NavigationStatePushing && v.x < 0))
                    [self showTmp];
                else
                    [self showCurrent];
            }
            _scrollView.panGestureRecognizer.enabled = YES;
            _scrollView = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Public Methods

#pragma mark - UIGesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if (_pan == gestureRecognizer) {
        _scrollView = nil;
        UIView *v = touch.view;
        UIScrollView *lastScrollView = nil;
        while (v) {
            if ([v isKindOfClass:[UIScrollView class]] &&
                ((UIScrollView*)v).contentSize.width - ((UIScrollView*)v).contentInset.left - ((UIScrollView*)v).contentInset.right > v.bounds.size.width) {
                lastScrollView = (UIScrollView*)v;
            }
            v = v.superview;
        }
        _scrollView = lastScrollView;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (_pan == gestureRecognizer) {
        CGPoint p = [_pan translationInView:self.view];
        BOOL begin = fabsf(p.x) > fabsf(p.y);
        if (begin) {
            if (p.x < 0) {
                begin = [self.topViewController respondsToSelector:@selector(nextViewControllerForRTNavigationController:)];
                if (begin)
                    self.state = NavigationStatePushing;
                
                CGFloat offset = _scrollView.contentOffset.x + _scrollView.bounds.size.width - _scrollView.contentInset.right;
                if (offset >= _scrollView.contentSize.width && begin)
                    _scrollView.panGestureRecognizer.enabled = NO;
            }
            else {
                if (self.childViewControllers.count > 1) {
                    self.state = NavigationStatePoping;
                    
                    CGFloat offset = _scrollView.contentOffset.x + _scrollView.contentInset.left;
                    if (offset <= 0.0 && begin)
                        _scrollView.panGestureRecognizer.enabled = NO;
                }
                else
                    begin = NO;
            }
        }
        return begin;
    }
    
    return YES;
}

#pragma mark - UINavigationBar Delegate

@end

