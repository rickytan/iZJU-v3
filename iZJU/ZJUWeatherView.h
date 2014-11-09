//
//  ZJUWeatherView.h
//  iZJU
//
//  Created by ricky on 13-8-25.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJUWeatherView : UIView
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) NSTimeInterval duration;  // Default 1.0s
- (void)startAnimation;
- (void)stopAnimation;
@end
