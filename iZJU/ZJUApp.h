//
//  ZJUApp.h
//  iZJU
//
//  Created by ricky on 13-6-28.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJUApp : UIView
@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIButton *button;
@property (nonatomic, assign) UIImage *iconImage;
@property (nonatomic, assign) NSString *iconText;
@property (nonatomic, assign) NSUInteger badgeNumber;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;

+ (id)appWithTarget:(id)target action:(SEL)action;

@end
