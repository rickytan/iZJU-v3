//
//  ZJUResponse.h
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZJUUser;

typedef enum {
    GenderUnknown = 0,
    GenderBoy,
    GenderGirl,
} Gender;

@interface ZJUResponse : NSObject
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, copy) id data;

+ (id)responseWithJSON:(NSDictionary*)jsonDic;
- (id)initWithJSON:(NSDictionary*)jsonDic;

@end

@interface ZJULoginResponse : ZJUResponse
@property (nonatomic, readonly) ZJUUser *user;
@end

@interface ZJUUserNameCheckResponse : ZJUResponse
- (BOOL)isAvailable;
@end

@interface ZJUUserInfoResponse : ZJUResponse
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *avatar;
@property (nonatomic, readonly) NSString *sign;
@property (nonatomic, readonly) NSString *phone;
@property (nonatomic, readonly) NSString *birth;
@property (nonatomic, readonly) NSString *realname;
@property (nonatomic, readonly) Gender gender;
@end

@interface ZJUNewsListResponse : ZJUResponse
@property (nonatomic, readonly) NSArray *newsArray;
@end

@interface ZJUCommentListResponse : ZJUResponse
@property (nonatomic, readonly) NSArray *commentArray;
@end