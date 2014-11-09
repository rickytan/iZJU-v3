//
//  UIApplication+RExtension.m
//  RTUsefulExtension
//
//  Created by ricky on 13-4-27.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "UIApplication+RExtension.h"

@implementation UIApplication (RExtension)

- (NSString*)appBundleID
{
    static NSString *bundleID = nil;
    if (!bundleID) {
        NSDictionary *info = [NSBundle mainBundle].infoDictionary;
        bundleID = [[info valueForKey:@"CFBundleIdentifier"] retain];
    }
    return bundleID;
}

- (NSString*)appVersion
{
    static NSString *versionStr = nil;
    if (!versionStr) {
        NSDictionary *info = [NSBundle mainBundle].infoDictionary;
        versionStr = [[info valueForKey:@"CFBundleShortVersionString"] retain];
    }
    return versionStr;
}

- (BOOL)isFirstLaunch
{
    static int rtnval = -1;
    if (rtnval != -1)
        return rtnval;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *version = [userDefault stringForKey:@"LastLaunchVersion"];
    
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *currVersion = [appInfo valueForKey:@"CFBundleShortVersionString"];
    
    if (!version || [currVersion compare:version
                                 options:NSNumericSearch] == NSOrderedDescending) {
        rtnval = YES;
        [userDefault setValue:currVersion
                       forKey:@"LastLaunchVersion"];
        [userDefault synchronize];
    }
    else
        rtnval = NO;
    return rtnval;
}

@end
