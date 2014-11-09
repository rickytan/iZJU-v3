//
//  ZJURequest.h
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJUResponse.h"

@class ZJURequest;
@class ZJUSession;
@class ASIFormDataRequest;


typedef void(^ZJURequestCompleteHandler)(ZJURequest *request);
typedef void(^ZJURequestFailureHandler)(NSError *error);


@protocol ZJURequestDelegate <NSObject>
@optional
- (void)requestDidFinished:(ZJURequest*)request;

@end

@interface ZJURequest : NSObject
@property (nonatomic, readonly) ASIFormDataRequest *asiRequest;
@property (nonatomic, retain) id<ZJURequestDelegate> delegate;
@property (nonatomic, assign, getter = isSecure) BOOL secure;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign) BOOL useCache;
@property (nonatomic, readonly) ZJUResponse *response;
+ (NSString*)hostAddress;
+ (NSString*)staticContentAddress;
+ (Class)responseClass;
+ (id)request;

- (NSString*)buildRequestPath;          // Override me !
- (NSString*)buildStaticPath;           // Override to support Static data, default return nil !
- (void)beforeRequest;                  // Override me ! Must call super
- (void)startRequestWithCompleteHandler:(ZJURequestCompleteHandler)complete;
- (void)startRequestWithCompleteDelegate:(id<ZJURequestDelegate>)delegate;
- (void)cancel;     // complete handler or delegate method won't be called !
@end

@interface ZJUAuthedRequest : ZJURequest
@property (nonatomic, retain) ZJUSession *session;
@end

@interface ZJUVisitRequest : NSObject
@property (nonatomic, retain) NSURL *url;
+ (id)requestWithURL:(NSURL*)url;
- (void)visit;
@end

/* ========================================================================== */

#pragma mark - Instance Requests

@interface ZJULoginRequest : ZJURequest
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) ZJULoginResponse *response;
@end

@interface ZJURegisterRequest : ZJURequest
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) ZJULoginResponse *response;
@end

@interface ZJUUserNameCheckRequest : ZJURequest
@property (nonatomic, retain) NSString *username;
@property (nonatomic, readonly) ZJUUserNameCheckResponse *response;
@end

@interface ZJUUserInfoRequest : ZJUAuthedRequest
@property (nonatomic, readonly) ZJUUserInfoResponse *response;
@end

@interface ZJUUserInfoSaveRequest : ZJUAuthedRequest
@property (nonatomic, retain) NSDictionary *detailedInfo;
@property (nonatomic, retain) UIImage *avatarImage;
@end

@interface ZJUUserFavoriteAddRequest : ZJUAuthedRequest
@property (nonatomic, retain) NSString *newsID;     // One of the two should be used!
@property (nonatomic, retain) NSArray *newsIDs;
@end

@interface ZJUUserFavoriteRemoveRequest : ZJUAuthedRequest
@property (nonatomic, retain) NSString *newsID;     // One of the two should be used!
@property (nonatomic, retain) NSArray *newsIDs;
@end

@interface ZJUUserFavoriteRequest : ZJUAuthedRequest
@property (nonatomic, readonly) ZJUNewsListResponse *response;
@end

@interface ZJUNewsListRequest : ZJURequest
@property (nonatomic, assign) NSUInteger page;      // Default 0;
@property (nonatomic, assign) NSUInteger size;      // Default 20;
@property (nonatomic, retain) NSString *category;   // Default "campus"
@property (nonatomic, readonly) ZJUNewsListResponse *response;
@end

@interface ZJUNewsDetailRequest : ZJURequest
@end

@interface ZJUCommentListRequest : ZJURequest
@property (nonatomic, assign) NSUInteger newsID;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, readonly) ZJUCommentListResponse *response;
@end

@interface ZJUCommentReplyRequest : ZJUAuthedRequest
@property (nonatomic, assign) NSUInteger newsID;
@property (nonatomic, assign) NSUInteger replyCommentID;
@property (nonatomic, retain) NSString *content;
@end

@interface ZJUFeedbackRequest : ZJUAuthedRequest
@property (nonatomic, retain) NSString *message;
@end


@interface ZJUCareerRequest : ZJURequest
@property (nonatomic, assign) NSUInteger page;      // Default 0
@property (nonatomic, assign) NSUInteger size;      // Default 20
@property (nonatomic, retain) NSDate *timestamp;    // Default now
@property (nonatomic, readonly) ZJUNewsListResponse *response;
@end

typedef enum {
    CareerInfoTypeAll = -1,
    CareerInfoTypeYiBanZhaoPin = 0,
    CareerInfoTypeShiXiShiXun = 1,
    CareerInfoTypeZhongYaoYangQi = 2,
    CareerInfoTypeShiYeDangWei = 3,
    CareerInfoTypeJunGongJiTuan = 4,
    CareerInfoTypeGaoXiaoZhaoPin = 5,
    CareerInfoTypeBoShiHaoZhaoPin = 6,
    CareerInfoTypeHaiWaiShenXue = 7,
} CareerInfoType;

@interface ZJUCareerListRequest : ZJUCareerRequest
@property (nonatomic, assign) CareerInfoType type;  // Defautl All
@property (nonatomic, readonly) ZJUNewsListResponse *response;
@end

extern NSString *const CareerNewsTypeNotice;
extern NSString *const CareerNewsTypeIntergated;

@interface ZJUCareerNewsRequest : ZJUCareerRequest
@property (nonatomic, retain) NSString *type;
@end

typedef enum {
    CareerTalkTypeFullTime      = 0,
    CareerTalkTypeIntern        = 1,
} CareerTalkType;

@interface ZJUCareerTalkRequest : ZJUCareerRequest
@property (nonatomic, assign) CareerTalkType type;
@end
