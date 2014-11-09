//
//  ZJUURLCache.m
//  iZJU
//
//  Created by ricky on 13-9-27.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUURLCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIApplication+RExtension.h"
#import "Reachability.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabasePool.h"

@interface ZJUURLCache ()
{
    FMDatabaseQueue             *_theDatabaseQueue;
}
@end

@implementation ZJUURLCache

- (void)dealloc
{
    [_theDatabaseQueue release];
    _theDatabaseQueue = nil;
    [super dealloc];
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity
                diskCapacity:(NSUInteger)diskCapacity
                    diskPath:(NSString *)path
{
    self = [super initWithMemoryCapacity:memoryCapacity
                            diskCapacity:diskCapacity
                                diskPath:path];
    if (self) {
        NSString *cachePath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/ImageCache.db"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            [[NSFileManager defaultManager] createFileAtPath:cachePath
                                                    contents:nil
                                                  attributes:nil];
        }
        _theDatabaseQueue = [[FMDatabaseQueue alloc] initWithPath:cachePath];
        [_theDatabaseQueue inDatabase:^(FMDatabase *db) {
            if ([db executeUpdate:
                 @"CREATE TABLE IF NOT EXISTS URLCache ("
                 //              @"    id          INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,"
                 @"    url         VARCHAR(1024) PRIMARY KEY NOT NULL UNIQUE,"
                 @"    response    BLOB,"
                 @"    data        BLOB,"
                 @"    time        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
                 @");"])
                [db executeUpdate:@"CREATE INDEX url_index ON URLCache(url);"];
            else
                NSLog(@"%@", [db lastErrorMessage]);
        }];
        //[self removeAllCachedResponses];
    }
    return self;
}

- (NSCachedURLResponse*)cachedResponseForRequest:(NSURLRequest *)request
{
    __block NSCachedURLResponse *cachedResponse = nil;
    [_theDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT response r, data d FROM URLCache WHERE url=?", request.URL.absoluteString];
        if ([result next]) {
            NSURLResponse *response = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"r"]];
            NSData *data = [result dataForColumn:@"d"];
            cachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:response
                                                                       data:data
                                                                   userInfo:nil
                                                              storagePolicy:NSURLCacheStorageAllowed] autorelease];
        }
        [result close];
    }];
    if (!cachedResponse)
        cachedResponse = [super cachedResponseForRequest:request];
    
    return cachedResponse;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse
                 forRequest:(NSURLRequest *)request
{
    __block BOOL success = YES;
    [_theDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSData *response = [NSKeyedArchiver archivedDataWithRootObject:cachedResponse.response];
        NSData *data = cachedResponse.data;
        
        if (![db executeUpdate:@"INSERT OR REPLACE INTO URLCache (url, response, data) values (?,?,?)", request.URL.absoluteString, response, data]) {
            NSLog(@"%@", [db lastErrorMessage]);
            success = NO;
        }
    }];
    if (!success)
        [super storeCachedResponse:cachedResponse forRequest:request];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [super removeCachedResponseForRequest:request];
    [_theDatabaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM URLCache WHERE url=?", request.URL.absoluteString];
    }];
}

- (void)removeAllCachedResponses
{
    [super removeAllCachedResponses];
    [_theDatabaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"TRUNCATE TABLE URLCache"];
    }];
}

@end
