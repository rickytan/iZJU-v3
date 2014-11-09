//
//  UIView+iZJU.h
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (iZJU)
@property (nonatomic, assign) CGFloat top, bottom, left, right;
@property (nonatomic, assign) CGFloat x, y, width, height;

- (void)moveEaseOutBounceTo:(CGPoint)point;
- (void)moveEaseOutBounceTo:(CGPoint)point duration:(NSTimeInterval)duration;
@end
