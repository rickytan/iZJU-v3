//
//  ZJUSession.m
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUSession.h"

@implementation ZJUSession

+ (ZJUSession*)sessionWithToken:(NSString *)token
{
    return [self sessionWithToken:token
                     refreshToken:nil
                       expireDate:nil];
}

+ (ZJUSession*)sessionWithToken:(NSString *)token
                   refreshToken:(NSString *)refreshToken
                     expireDate:(NSDate *)expire
{
    ZJUSession *session = [[ZJUSession alloc] init];
    session.token = token;
    session.refreshToken = refreshToken;
    session.expire = expire;
    return [session autorelease];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
        self.expire = [aDecoder decodeObjectForKey:@"expire"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (!self.isAuthenticated)
        return;
    
    [aCoder encodeObject:self.token
                  forKey:@"token"];
    if (self.refreshToken)
        [aCoder encodeObject:self.refreshToken
                      forKey:@"refreshToken"];
    if (self.expire)
        [aCoder encodeObject:self.expire
                      forKey:@"expire"];
}

- (BOOL)isAuthenticated
{
    return
    self.token.length > 0 &&
    (self.expire == nil || [self.expire compare:[NSDate date]] == NSOrderedDescending);
}

@end
