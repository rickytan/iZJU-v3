//
//  ZJULoadMoreView.h
//  ZJU
//
//  Created by ricky on 13-2-28.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ZJULoadMoreViewStateNoMore,
    ZJULoadMoreViewStateLoading,
    ZJULoadMoreViewStateMayHaveMore,
    ZJULoadMoreViewStateError
}ZJULoadMoreViewState;

@interface ZJULoadMoreView : UIControl
@property (nonatomic, assign) ZJULoadMoreViewState loadingState;
@end
