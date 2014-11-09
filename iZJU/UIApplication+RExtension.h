//
//  UIApplication+RExtension.h
//  RTUsefulExtension
//
//  Created by ricky on 13-4-27.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (RExtension)
- (NSString*)appBundleID;
- (NSString*)appVersion;
- (BOOL)isFirstLaunch;
@end
