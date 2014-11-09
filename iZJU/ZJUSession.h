//
//  ZJUSession.h
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJUSession : NSObject <NSCoding>
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *refreshToken;
@property (nonatomic, retain) NSDate *expire;
@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;
+ (ZJUSession*)sessionWithToken:(NSString*)token;
+ (ZJUSession*)sessionWithToken:(NSString *)token
                   refreshToken:(NSString*)refreshToken
                     expireDate:(NSDate*)expire;
@end
