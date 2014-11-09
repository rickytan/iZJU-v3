//
//  ZJUFavoriteManager.m
//  iZJU
//
//  Created by ricky on 13-9-4.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUFavoriteManager.h"
#import "ZJUUser.h"
#import "ZJURequest.h"

static NSString *const ZJUFavoriteNewsUserDefaultKey = @"ZJUFavoriteNewsUserDefaultKey";

@implementation ZJUFavoriteManager

+ (void)load
{
    @autoreleasepool {
        [self initialize];
    }
}

+ (void)initialize
{
    if ([ZJUUser currentUser].isLogin) {
        [self loadFavoriteNewsItemsWithBlock:^(NSArray *newsItems, NSError *error) {
            if (newsItems) {
                [self initializeWithNewsArray:newsItems];
            }
        }];
    }
}

+ (void)initializeWithNewsArray:(NSArray *)news
{
    NSMutableArray *mutArr = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:ZJUFavoriteNewsUserDefaultKey];
    [mutArr removeAllObjects];
    for (NSDictionary *item in news) {
        [mutArr addObject:[item[@"id"] stringValue]];
    }
}

+ (BOOL)isFavoriteNewsWithID:(NSString*)newsID
{
    return [[self favoriteIDList] containsObject:newsID];
}

+ (BOOL)isFavoriteNews:(NSDictionary*)newsItem
{
    return [self isFavoriteNewsWithID:newsItem[@"id"]];
}

+ (void)addFavoriteWithID:(NSString*)newsID
{
    ZJUUserFavoriteAddRequest *add = [ZJUUserFavoriteAddRequest request];
    add.session = [ZJUUser currentUser].session;
    add.newsID = newsID;
    [add startRequestWithCompleteHandler:^(ZJURequest *request) {
        if (request.response.errorCode == 0) {
            NSMutableArray *mutArr = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:ZJUFavoriteNewsUserDefaultKey];
            if (![mutArr containsObject:newsID])
                [mutArr addObject:newsID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

+ (void)addFavoriteWithItem:(NSDictionary*)newsItem
{
    [self addFavoriteWithID:newsItem[@"id"]];
}

+ (void)removeFavoriteWithID:(NSString*)newsID
{
    ZJUUserFavoriteRemoveRequest *remove = [ZJUUserFavoriteRemoveRequest request];
    remove.session = [ZJUUser currentUser].session;
    remove.newsID = newsID;
    [remove startRequestWithCompleteHandler:^(ZJURequest *request) {
        if (request.response.errorCode == 0) {
            NSMutableArray *mutArr = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:ZJUFavoriteNewsUserDefaultKey];
            [mutArr removeObject:newsID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

+ (void)removeFavoriteWithItem:(NSDictionary*)newsItem
{
    [self removeFavoriteWithID:newsItem[@"id"]];
}

+ (NSArray*)favoriteIDList
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:ZJUFavoriteNewsUserDefaultKey];
}

+ (void)loadFavoriteNewsItemsWithBlock:(void (^)(NSArray *, NSError *))block
{
    ZJUUserFavoriteRequest *fav = [ZJUUserFavoriteRequest request];
    fav.session = [ZJUUser currentUser].session;
    [fav startRequestWithCompleteHandler:^(ZJURequest *request) {
        if (fav.response.errorCode == 0) {
            block(fav.response.newsArray, nil);
        }
        else
            block(nil, [NSError errorWithDomain:@"org.izju"
                                           code:fav.response.errorCode
                                       userInfo:@{@"message": fav.response.message}]);
    }];
}

@end
