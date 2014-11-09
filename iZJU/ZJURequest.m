//
//  ZJURequest.m
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "ZJURequest.h"
#import "ZJUSession.h"
#import "UIImage+DD.h"

#define API_VERSION @"v2"

#define MAIN_SERVER_ADDRESS @"api.izju.org"

#ifdef DEBUG
#define NEWS_SERVER_ADDRESS @"api.izju.org/"API_VERSION"/news"
#else
#define NEWS_SERVER_ADDRESS @"news.izju.org"
#endif

#define IZJU_ERROR_DOMAIN @"org.izju.izju"

@interface ZJURequest ()
{
@private
    ASIFormDataRequest              *_asiRequest;
}
@property (nonatomic, retain) ASIFormDataRequest *asiRequest;
@property (nonatomic, retain) ZJUResponse *response;
@property (nonatomic, assign) BOOL loading;
- (void)buildRequest;
@end

@implementation ZJURequest
@synthesize asiRequest = _asiRequest;
@synthesize response = _response;
@synthesize loading = _loading;

+ (Class)responseClass
{
    return [ZJUResponse class];
}

+ (NSString*)hostAddress
{
    static NSString *address = nil;
    if (!address) {
        address = [[NSString alloc] initWithFormat:@"%@/%@",MAIN_SERVER_ADDRESS,API_VERSION];
    }
    return address;
}

+ (NSString*)staticContentAddress
{
    return [NSString stringWithFormat:@"http://%@", NEWS_SERVER_ADDRESS];
}

+ (id)request
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    NSLog(@"%@ dellocated.", NSStringFromClass(self.class));
    self.response = nil;
    self.delegate = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@ initailized.", NSStringFromClass(self.class));
    }
    return self;
}

- (NSString*)buildStaticPath
{
    return nil;
}

- (NSString*)buildHostURL
{
    return [NSString stringWithFormat:@"%@://%@",self.isSecure?@"https":@"http",[ZJURequest hostAddress]];
}

- (NSString*)buildRequestPath
{
    NSAssert(NO, @"Should subclass this Method!");  // Override Me!
    return nil;
}

- (void)beforeRequest
{
    
}

- (void)buildRequest
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [self buildHostURL], [self buildRequestPath]]];
    self.asiRequest = [ASIFormDataRequest requestWithURL:requestURL];
    self.asiRequest.cachePolicy = self.useCache ? (ASIAskServerIfModifiedWhenStaleCachePolicy | ASIAskServerIfModifiedCachePolicy) : ASIUseDefaultCachePolicy;
    self.asiRequest.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
}

- (void)startRequestWithCompleteHandler:(ZJURequestCompleteHandler)complete
{
    [self retain];
    __block typeof(self) weakSelf = self;
    void(^doRequest)() = ^() {
        [weakSelf buildRequest];
        [weakSelf beforeRequest];
        
        [weakSelf.asiRequest setCompletionBlock:^() {
            NSData *data = weakSelf.asiRequest.responseData;
            NSError *error = nil;
            id JSON = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingAllowFragments
                                                        error:&error];
            weakSelf.response = [[weakSelf.class responseClass] responseWithJSON:JSON];
            weakSelf.loading = NO;
            complete(weakSelf);
            // Block_release(complete);
            [weakSelf release];
        }];
        [weakSelf.asiRequest setFailedBlock:^{
            NSLog(@"%@",weakSelf.asiRequest.error);
            if (weakSelf.asiRequest.error.code != 4) {  // Error didn't due to Cancel
                weakSelf.response = [[weakSelf.class responseClass] responseWithJSON:nil];
                weakSelf.loading = NO;
                complete(weakSelf);
            }
            [weakSelf release];
        }];
        
        weakSelf.loading = YES;
        
        [weakSelf.asiRequest startAsynchronous];
    };
    
    NSString *staticPath = [weakSelf buildStaticPath];
    if (staticPath) {
        weakSelf.loading = YES;
        
        NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [ZJURequest staticContentAddress], staticPath]];
        [NSURLConnection sendAsynchronousRequest:
         [NSURLRequest requestWithURL:requestURL
                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                      timeoutInterval:6.0]
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                                   if (e) {
                                       NSLog(@"%@",e);
                                       weakSelf.response = [[weakSelf.class responseClass] responseWithJSON:nil];
                                       weakSelf.loading = NO;
                                       complete(weakSelf);
                                   }
                                   else {
                                       id JSON = [NSJSONSerialization JSONObjectWithData:d
                                                                                 options:NSJSONReadingAllowFragments
                                                                                   error:&e];
                                       weakSelf.response = [[weakSelf.class responseClass] responseWithJSON:JSON];
                                       if (weakSelf.response.errorCode == 404) {
                                           doRequest();
                                       }
                                       else {
                                           weakSelf.loading = NO;
                                           complete(weakSelf);
                                       }
                                   }
                                   [weakSelf release];
                               }];
    }
    else {
        doRequest();
    }
}

- (void)startRequestWithCompleteDelegate:(id<ZJURequestDelegate>)delegate
{
    self.delegate = delegate;
    __block typeof(self) this = self;
    [self startRequestWithCompleteHandler:^(ZJURequest *request) {
        if ([this.delegate respondsToSelector:@selector(requestDidFinished:)])
            [this.delegate requestDidFinished:this];
    }];
}

- (void)cancel
{
    [self.asiRequest cancel];
}

@end


@implementation ZJUAuthedRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.secure = YES;
    }
    return self;
}

- (void)beforeRequest
{
    [super beforeRequest];
    NSAssert(self.session != nil, @"You must set session before send request!");
    [self.asiRequest addPostValue:self.session.token
                           forKey:@"token"];
}

@end

@interface ZJUVisitRequest () <NSURLConnectionDataDelegate>
@end

@implementation ZJUVisitRequest

+ (id)requestWithURL:(NSURL *)url
{
    ZJUVisitRequest *request = [[ZJUVisitRequest alloc] init];
    request.url = url;
    return [request autorelease];
}

- (void)dealloc
{
    self.url = nil;
    [super dealloc];
}

- (void)visit
{
    if (!self.url)
        return;
    if ([self.url isKindOfClass:[NSString class]])
        self.url = [NSURL URLWithString:(NSString*)self.url];
    
    [self retain];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request
                                                                delegate:self];
    [connection start];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self release];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [connection cancel];
    [self release];
}

@end

@implementation ZJULoginRequest

+ (Class)responseClass
{
    return [ZJULoginResponse class];
}

- (void)dealloc
{
    self.username = nil;
    self.password = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.secure = YES;
    }
    return self;
}

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"user/auth?username=%@&password=%@",self.username,self.password];
}

@end

@implementation ZJURegisterRequest

+ (Class)responseClass
{
    return [ZJULoginResponse class];
}

- (void)dealloc
{
    self.username = nil;
    self.email = nil;
    self.password = nil;
    [super dealloc];
}

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"user/register?username=%@&password=%@&email=%@",self.username,self.password,self.email];
}

@end

@implementation ZJUUserNameCheckRequest

+ (Class)responseClass
{
    return [ZJUUserNameCheckResponse class];
}

- (void)dealloc
{
    self.username = nil;
    [super dealloc];
}

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"user/verify_username?username=%@", self.username];
}

@end

@implementation ZJUUserInfoRequest

+ (Class)responseClass
{
    return [ZJUUserInfoResponse class];
}

- (NSString*)buildRequestPath
{
    return @"user/info";
}

@end

@implementation ZJUUserInfoSaveRequest

- (NSString*)buildRequestPath
{
    return @"user/updateinfo";
}

- (void)beforeRequest
{
    [super beforeRequest];
    [self.detailedInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.asiRequest addPostValue:obj
                               forKey:key];
    }];
    if (self.avatarImage) {
        UIImage *image = [self.avatarImage resizedImageWithMaxHeight:160
                                                            maxWidth:160];
        [self.asiRequest addData:UIImageJPEGRepresentation(image, 0.7)
                    withFileName:@"header.jpg"
                  andContentType:@"image/jpeg"
                          forKey:@"avatarfile"];
    }
}

@end

@implementation ZJUNewsListRequest

+ (Class)responseClass
{
    return [ZJUNewsListResponse class];
}

- (void)dealloc
{
    self.category = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.page = 0;
        self.size = 20;
        self.category = @"campus";
    }
    return self;
}

- (NSString*)buildStaticPath
{
    return [NSString stringWithFormat:@"cate/%@/list_%u_%u.json",self.category,self.page,self.size];
}

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"news/list?cate=%@&page=%u&size=%u",self.category, self.page,self.size];
}

@end

@implementation ZJUCommentListRequest

+ (Class)responseClass
{
    return [ZJUCommentListResponse class];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.page = 0;
        self.size = 20;
    }
    return self;
}

- (NSString*)buildStaticPath
{
    return [NSString stringWithFormat:@"cate/campus/%u/comment/list_%u_%u.json", self.newsID, self.page, self.size];
}

- (NSString*)buildRequestPath
{
    //NSAssert(self.newsID > 0, @"news id must be set!");
    return [NSString stringWithFormat:@"comment/list?id=%u&page=%u&size=%u",self.newsID, self.page,self.size];
}

@end

@implementation ZJUCommentReplyRequest

- (void)beforeRequest
{
    [super beforeRequest];
    if (self.replyCommentID > 0) {
        [self.asiRequest addPostValue:[NSNumber numberWithUnsignedInt:self.replyCommentID]
                               forKey:@"cid"];
    }
    [self.asiRequest addPostValue:self.content
                           forKey:@"content"];
}

- (NSString*)buildRequestPath
{
    NSAssert(self.newsID > 0, @"news id must be set!");
    return [NSString stringWithFormat:@"comment/add?nid=%u", self.newsID];
}

@end

@implementation ZJUUserFavoriteAddRequest

- (void)beforeRequest
{
    [super beforeRequest];
    if (self.newsID) {
        [self.asiRequest addPostValue:self.newsID
                               forKey:@"nid"];
    }
    else {
        [self.asiRequest addPostValue:[self.newsIDs componentsJoinedByString:@","]
                               forKey:@"nid"];
    }
}

- (NSString*)buildRequestPath
{
    return @"favourite/add";
}

@end

@implementation ZJUUserFavoriteRemoveRequest

- (void)beforeRequest
{
    [super beforeRequest];
    if (self.newsID) {
        [self.asiRequest addPostValue:self.newsID
                               forKey:@"nid"];
    }
    else {
        [self.asiRequest addPostValue:[self.newsIDs componentsJoinedByString:@","]
                               forKey:@"nid"];
    }
}

- (NSString*)buildRequestPath
{
    return @"favourite/remove";
}

@end

@implementation ZJUUserFavoriteRequest

+ (Class)responseClass
{
    return [ZJUNewsListResponse class];
}

- (NSString*)buildRequestPath
{
    return @"favourite/list";
}

@end

@implementation ZJUFeedbackRequest

- (void)dealloc
{
    self.message = nil;
    [super dealloc];
}

- (void)beforeRequest
{
    [super beforeRequest];
    [self.asiRequest addPostValue:self.message
                           forKey:@"message"];
}

- (NSString*)buildRequestPath
{
    return @"feedback";
}

@end


NSString *const CareerNewsTypeNotice = @"01010708";
NSString *const CareerNewsTypeIntergated = @"01010302";

@implementation ZJUCareerRequest

+ (Class)responseClass
{
    return [ZJUNewsListResponse class];
}

- (void)dealloc
{
    self.timestamp = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.page = 0;
        self.size = 20;
        self.timestamp = [NSDate date];
    }
    return self;
}

- (void)startRequestWithCompleteHandler:(ZJURequestCompleteHandler)complete
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://www.career.zju.edu.cn/ejob/%@"
                                       @"updatetime=%d&"
                                       @"page=%u&"
                                       @"size=%u",
                                       [self buildRequestPath],
                                       (int)[self.timestamp timeIntervalSince1970],
                                       self.page,
                                       self.size]];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.cachePolicy = ASIAskServerIfModifiedCachePolicy;
    request.timeOutSeconds = 6.0;
    __block typeof(self) weakSelf = self;
    [request setCompletionBlock:^{
        NSError *e = nil;
        NSData *d = request.responseData;
        NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *str = [[NSString alloc] initWithData:d
                                              encoding:encode];
        d = [str dataUsingEncoding:NSUTF8StringEncoding];
        [str release];
        id JSON = [NSJSONSerialization JSONObjectWithData:d
                                                  options:NSJSONReadingAllowFragments
                                                    error:&e];
        if ([JSON isKindOfClass:[NSArray class]]) {
            NSDictionary *dic = @{@"errorcode": @0, @"list": JSON};
            weakSelf.response = [ZJUNewsListResponse responseWithJSON:dic];
        }
        else
            weakSelf.response = [ZJUNewsListResponse responseWithJSON:JSON];
        weakSelf.loading = NO;
        complete(weakSelf);
    }];
    [request setFailedBlock:^{
        weakSelf.response = [ZJUNewsListResponse responseWithJSON:nil];
        weakSelf.loading = NO;
        complete(weakSelf);
    }];
    self.loading = YES;
    [request startAsynchronous];
}

@end

@implementation ZJUCareerListRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.type = CareerInfoTypeAll;
    }
    return self;
}

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"data_sync_index.do?%@",(self.type == CareerInfoTypeAll) ? @"" : [NSString stringWithFormat:@"zptype=%d&", self.type]];
}

@end

@implementation ZJUCareerNewsRequest

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"lm_sync_index.do?lmdm=%@&",self.type];
}

@end

@implementation ZJUCareerTalkRequest

- (NSString*)buildRequestPath
{
    return [NSString stringWithFormat:@"xjh_sync_index.do?type=%d&",self.type];
}

@end
