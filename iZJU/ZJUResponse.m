//
//  ZJUResponse.m
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUResponse.h"
#import "ZJUUser.h"
#import "ZJUSession.h"
#import "NSDate+RExtension.h"

@implementation ZJUResponse

+ (id)responseWithJSON:(NSDictionary *)jsonDic
{
    //@autoreleasepool {
        return [[[self alloc] initWithJSON:jsonDic] autorelease];
    //}
}

- (void)dealloc
{
    self.message = nil;
    self.data = nil;
    
    [super dealloc];
}

- (id)initWithJSON:(NSDictionary *)jsonDic
{
    self = [super init];
    if (self) {
        if ([jsonDic objectForKey:@"errorcode"]) {
            self.errorCode = [[jsonDic objectForKey:@"errorcode"] intValue];
            self.message = [jsonDic valueForKey:@"msg"];
            self.data = jsonDic;
        }
        else if (jsonDic) {
            self.errorCode = NSNotFound;
            self.message = @"服务器数据格式错误！";
        }
        else {
            self.errorCode = NSNotFound;
            self.message = @"连接超时或服务器错误！";
        }
    }
    return self;
}

@end

@implementation ZJULoginResponse

- (ZJUUser*)user
{
    ZJUUser *user = [ZJUUser currentUser];
    user.name = [self.data valueForKeyPath:@"data.username"];
    
    NSString *token = [self.data valueForKeyPath:@"data.token"];
    NSString *refresh = [self.data valueForKeyPath:@"data.refresh"];
    NSString *dateString = [self.data valueForKeyPath:@"data.expire"];
    NSDate *expire = [NSDate dateFromString:dateString];
    ZJUSession *session = [ZJUSession sessionWithToken:token
                                          refreshToken:refresh
                                            expireDate:expire];
    user.session = session;
    return user;
}

@end

@implementation ZJUUserNameCheckResponse

- (BOOL)isAvailable
{
    if (self.data)
        return ![[self.data valueForKeyPath:@"data.is_legal"] boolValue];
    return NO;
}

@end

@implementation ZJUUserInfoResponse

- (NSString*)realname
{
    return [self.data valueForKeyPath:@"data.realname"];
}

- (NSString*)username
{
    return [self.data valueForKeyPath:@"data.username"];
}

- (NSString*)birth
{
    return [self.data valueForKeyPath:@"data.birth"];
}

- (NSString*)phone
{
    return [self.data valueForKeyPath:@"data.phone"];
}

- (NSString*)sign
{
    return [self.data valueForKeyPath:@"data.sign"];
}

- (NSString*)email
{
    return [self.data valueForKeyPath:@"data.email"];
}

- (Gender)gender
{
    return [[self.data valueForKeyPath:@"data.sex"] intValue];
}

- (NSString*)avatar
{
    return [self.data valueForKeyPath:@"data.avatar"];
}

@end

@implementation ZJUNewsListResponse

- (NSArray*)newsArray
{
    if ([self.data objectForKey:@"data"])
        return [self.data valueForKeyPath:@"data.list"];
    return [self.data objectForKey:@"list"];
}

@end

@implementation ZJUCommentListResponse

- (NSArray*)commentArray
{
    if ([self.data objectForKey:@"data"])
        return [self.data valueForKeyPath:@"data.list"];
    return [self.data objectForKey:@"list"];
}

@end