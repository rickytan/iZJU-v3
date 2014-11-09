//
//  ZJUUser.h
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJUSession.h"

@interface ZJUUser : NSObject <NSCoding>
//@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) ZJUSession *session;
@property (nonatomic, readonly, getter = isLogin) BOOL login;
@property (nonatomic, readonly) NSMutableDictionary *details;
+ (ZJUUser*)currentUser;    // Will Always return a use ! Please check isLogin
- (BOOL)saveToDisk;
- (void)logout;
@end
