//
//  ZJUFavoriteManager.h
//  iZJU
//
//  Created by ricky on 13-9-4.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJUFavoriteManager : NSObject

+ (void)initializeWithNewsArray:(NSArray*)news;

+ (BOOL)isFavoriteNewsWithID:(NSString*)newsID;
+ (BOOL)isFavoriteNews:(NSDictionary*)newsItem;
+ (void)addFavoriteWithID:(NSString*)newsID;
+ (void)addFavoriteWithItem:(NSDictionary*)newsItem;
+ (void)removeFavoriteWithID:(NSString*)newsID;
+ (void)removeFavoriteWithItem:(NSDictionary*)newsItem;
+ (NSArray*)favoriteIDList;
+ (void)loadFavoriteNewsItemsWithBlock:(void(^)(NSArray *newsItems, NSError *error))block;

@end
