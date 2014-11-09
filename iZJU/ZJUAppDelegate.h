//
//  ZJUAppDelegate.h
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJUAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>
{
    NSString                    * updateURL;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@end
