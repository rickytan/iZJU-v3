//
//  JPushAPI.h
//  iZJU
//
//  Created by ricky on 13-6-19.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_KEY             @"3e3260435426457060c695fc"
#define APP_MARSTER_SECRET  @"b66095e9fc5be323b3610d37"


typedef void(^JPushCallback)(NSDictionary *info, NSError *error);

typedef enum {
    JPushTypeAll    = 4,
    JPushTypeTags   = 2,
    JPushTypeAlias  = 3,
}JPushType;

@interface JPushAPI : NSObject
{
    NSMutableDictionary             * _extarDictionary;
    NSMutableArray                  * _tagOrAlias;
}
@property (nonatomic) JPushType type;           // Default JPushTypeAll
@property (nonatomic) long timeToLive;          // Default 60*60*24, max 10*60*60*24
@property (nonatomic) BOOL pushToAndroid;       // Default YES
@property (nonatomic) BOOL pushToiOS;           // Default YES
@property (nonatomic, retain) NSString *alert;
@property (nonatomic, retain) NSNumber *badge;  // Default nil
@property (nonatomic, retain) NSString *sound;  // Default nil

- (void)addTagOrAlias:(NSString*)tagOrAlias;
- (void)addExtarValue:(id)value forKey:(NSString*)key;
- (void)pushWithCallback:(JPushCallback)callback;
@end
