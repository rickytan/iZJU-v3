//
//  RTNavigationController.h
//  RTNavigationController
//
//  Created by ricky on 13-3-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef SAFE_RELEASE
#if __has_feature(objc_arc)
#define SAFE_RELEASE(o) ((o) = nil)
#define SAFE_DEALLOC(o) {}
#else
#define SAFE_RELEASE(o) ([(o) release], (o) = nil)
#define SAFE_AUTORELEASE(o) ([(o) autorelease])
#define SAFE_DEALLOC(o) [o dealloc]
#endif
#endif

@class RTNavigationController;

@protocol RTNavigationControllerDatasource <NSObject>
@optional
- (UIViewController*)nextViewControllerForRTNavigationController:(RTNavigationController*)controller;

@end

@interface UIViewController (RTNavigationController) <RTNavigationControllerDatasource>
@end

typedef enum {
    NavigationTranslationStyleNormal,
    NavigationTranslationStyleFade,
    NavigationTranslationStyleDeeper = NavigationTranslationStyleNormal,
}NavigationTranslationStyle;

typedef enum {
    NavigationStateNormal,
    NavigationStatePoping,
    NavigationStatePushing
}NavigationState;

@interface RTNavigationController : UINavigationController <UIGestureRecognizerDelegate>
{
@private
    UIPanGestureRecognizer                  * _pan;
    CGAffineTransform                         _currentTrans;
    
    UIScrollView                            * _scrollView;
}
@property (nonatomic, assign) NavigationTranslationStyle translationStyle;
@property (nonatomic, readonly) NavigationState state;
@end
