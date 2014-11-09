//
//  ZJUWebImageView.h
//  iZJU
//
//  Created by ricky on 13-6-13.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJUWebImageView : UIControl
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) UIImage *placeholderImage;
@property (nonatomic, assign) CGRect originRect;
- (void)show;
- (void)dismiss;
@end
