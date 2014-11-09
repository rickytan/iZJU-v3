//
//  ZJUURLProtocol.m
//  iZJU
//
//  Created by ricky on 13-9-27.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUURLProtocol.h"
#import "Reachability.h"

static NSString *const ZJUURLCacheHeaderKey = @"X-ZJUCache";


@interface ZJUURLProtocol () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, readwrite, retain) NSURLConnection *connection;
@property (nonatomic, readwrite, retain) NSMutableData *data;
@property (nonatomic, readwrite, retain) NSURLResponse *response;
@end

@implementation ZJUURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // 不处理 gif 图，因为可能影响百度统计接口， http://hmma.baidu.com/app.gif
    if ([@[@"jpeg", @"jpg", @"png", @"bmp", @"webp"] containsObject:request.URL.pathExtension.lowercaseString] &&
        !request.URL.isFileURL &&
        [request valueForHTTPHeaderField:ZJUURLCacheHeaderKey ] == nil)
        return YES;
    return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)dealloc
{
    self.connection = nil;
    self.data = nil;
    self.response = nil;
    
    [super dealloc];
}

- (void)appendData:(NSData*)data
{
    if (self.data)
        [self.data appendData:data];
    else
        self.data = [[data mutableCopy] autorelease];
}

- (void)cacheData
{
    [[NSURLCache sharedURLCache] storeCachedResponse:[[[NSCachedURLResponse alloc] initWithResponse:self.response
                                                                                               data:self.data] autorelease]
                                          forRequest:self.request];
    
    self.response = nil;
    self.connection = nil;
    self.data = nil;
}

- (void)startLoading
{
    //NSLog(@"%@", self.request.URL);
    //NSLog(@"%@", self.request.allHTTPHeaderFields);
    
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request];
    if (resp) {
        [self.client URLProtocol:self
              didReceiveResponse:resp.response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self
                     didLoadData:resp.data];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else {
        NetworkStatus status = [[Reachability reachabilityWithHostName:self.request.URL.host] currentReachabilityStatus];
        switch (status) {
            case NotReachable:
                [self.client URLProtocol:self
                        didFailWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                             code:-4
                                                         userInfo:nil]];
                break;
            case ReachableViaWWAN:
            {
                NSMutableURLRequest *connectionRequest = [self.request mutableCopy];
                [connectionRequest setValue:@"" forHTTPHeaderField:ZJUURLCacheHeaderKey];
                self.connection = [NSURLConnection connectionWithRequest:connectionRequest
                                                                delegate:self];
                [connectionRequest release];
            }
                break;
            default:
            {
                NSURL *placeholderURL = [[NSBundle mainBundle] URLForResource:@"placeholder"
                                                                withExtension:@"png"];
                NSData *data = [NSData dataWithContentsOfURL:placeholderURL];
                [self.client URLProtocol:self
                      didReceiveResponse:[[[NSHTTPURLResponse alloc] initWithURL:placeholderURL
                                                                      statusCode:200
                                                                     HTTPVersion:@"HTTP/1.1"
                                                                    headerFields:@{
                                           @"Content-Length" : [NSString stringWithFormat:@"%ul", data.length],
                                                           ZJUURLCacheHeaderKey : @""}] autorelease]
                      cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [self.client URLProtocol:self
                             didLoadData:data];
                [self.client URLProtocolDidFinishLoading:self];
            }
                break;
        }
    }
}

- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark - NSURLConnection Delegate

- (NSURLRequest*)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)response
{
    if (response != nil) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSString *redirect = [[httpResponse allHeaderFields] objectForKey:@"Location"];
            if ([redirect isEqualToString:request.URL.absoluteString]) {    // 重定向循环
                return nil;
            }
        }
        NSMutableURLRequest *redirectableRequest = [[request mutableCopy] autorelease];

        [redirectableRequest setValue:nil
                   forHTTPHeaderField:ZJUURLCacheHeaderKey];
        
        [self cacheData];
        
        [[self client] URLProtocol:self
            wasRedirectedToRequest:redirectableRequest
                  redirectResponse:response];
        return redirectableRequest;
    } else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self
                 didLoadData:data];
    [self appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    
    [self cacheData];
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self
            didFailWithError:error];
    
    self.response = nil;
    self.connection = nil;
    self.data = nil;
}

@end
