//
//  JPushAPI.m
//  iZJU
//
//  Created by ricky on 13-6-19.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "JPushAPI.h"
#import <CommonCrypto/CommonDigest.h>

@implementation JPushAPI

- (void)dealloc
{
    [_extarDictionary release];
    [_tagOrAlias release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _extarDictionary = [[NSMutableDictionary alloc] init];
        _tagOrAlias = [[NSMutableArray alloc] init];
        
        self.type = JPushTypeAll;
        self.timeToLive = 60*60*24;
        self.pushToAndroid = YES;
        self.pushToiOS = YES;
    }
    return self;
}

- (void)addExtarValue:(id)value forKey:(NSString*)key
{
    [_extarDictionary setValue:value
                        forKey:key];
}

- (void)addTagOrAlias:(NSString *)tagOrAlias
{
    [_tagOrAlias addObject:tagOrAlias];
}

- (void)pushWithCallback:(JPushCallback)callback
{
    
    NSUInteger sendNo = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    NSString *apiKey = APP_KEY;
    NSString *apiSecret = APP_MARSTER_SECRET;
    NSInteger receiverType = self.type;
    NSString *receiverValue = [_tagOrAlias componentsJoinedByString:@","];
    static NSInteger messageType = 1;
    
    NSString *verify = [NSString stringWithFormat:@"%u%d%@%@",sendNo,receiverType,receiverValue,apiSecret];
    const char *ch = [verify UTF8String];
    unsigned char result[16];
    CC_MD5(ch, strlen(ch), result);
    NSString *verificationCode = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
    
    NSMutableDictionary *apnInfo = nil;
    if (self.badge) {
        if (!apnInfo) apnInfo =  [NSMutableDictionary dictionary];
        [apnInfo setValue:self.badge
                   forKey:@"badge"];
    }
    if (self.sound) {
        if (!apnInfo) apnInfo = [NSMutableDictionary dictionary];
        [apnInfo setValue:self.sound
                   forKey:@"sound"];
    }
    if (apnInfo)
        [_extarDictionary setValue:apnInfo
                            forKey:@"ios"];
    
    NSDictionary *pushMessage = @{@"n_content" : self.alert,
                                  @"n_extra" : _extarDictionary};
    
    unsigned char *buffer = (unsigned char*)malloc(1024);
    
    NSOutputStream *outStream = [NSOutputStream outputStreamToBuffer:buffer
                                                            capacity:1024];
    [outStream open];
    NSUInteger count = [NSJSONSerialization writeJSONObject:pushMessage
                                                   toStream:outStream
                                                    options:0
                                                      error:NULL];
    [outStream close];
    NSString *messageContent = [[NSString alloc] initWithBytesNoCopy:buffer
                                                              length:count
                                                            encoding:NSUTF8StringEncoding
                                                        freeWhenDone:YES];
    NSMutableArray *platforms = [NSMutableArray arrayWithCapacity:2];
    if (self.pushToAndroid)
        [platforms addObject:@"android"];
    if (self.pushToiOS)
        [platforms addObject:@"ios"];
    
    NSString *postString = [NSString stringWithFormat:
                            @"sendno=%u&"
                            @"app_key=%@&"
                            @"receiver_type=%d&"
                            @"receiver_value=%@&"
                            @"verification_code=%@&"
                            @"msg_content=%@&"
                            @"msg_type=%d&"
                            @"platform=%@&"
                            @"time_to_live=%ld",
                            sendNo++,
                            apiKey,
                            receiverType,
                            receiverValue,
                            verificationCode,
                            messageContent,
                            messageType,
                            [platforms componentsJoinedByString:@","],
                            self.timeToLive
                            ];
    [messageContent release];
    
    // https://api.jpush.cn:443/sendmsg/v2/sendmsg
    NSURL *url = [NSURL URLWithString:@"http://api.jpush.cn:8800/sendmsg/v2/sendmsg"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    /*
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES
                                       forHost:@"api.jpush.cn"];
     */
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                               if (e) {
                                   NSLog(@"%@",e);
                                   callback(nil, e);
                               }
                               else {
                                   id JSON = [NSJSONSerialization JSONObjectWithData:d
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&e];
                                   NSLog(@"%@",JSON);
                                   callback(JSON, e);
                               }
                           }];
}

@end
