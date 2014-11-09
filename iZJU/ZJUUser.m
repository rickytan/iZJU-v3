//
//  ZJUUser.m
//  iZJU
//
//  Created by ricky on 13-6-6.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUUser.h"

static NSString *USER_SAVE_PATH = nil;

@implementation ZJUUser
@synthesize details = _details;

+ (void)initialize
{
    if (!USER_SAVE_PATH) {
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *dir = [arr lastObject];
        USER_SAVE_PATH = [[dir stringByAppendingPathComponent:@"user.dat"] retain];
    }
}

+ (ZJUUser*)currentUser
{
    static ZJUUser *_currentUser = nil;
    @synchronized(self) {
        if (!_currentUser) {
            @try {
                _currentUser = [[NSKeyedUnarchiver unarchiveObjectWithFile:USER_SAVE_PATH] retain];
            }
            @catch (NSException *exception) {
                _currentUser = [[ZJUUser alloc] init];
            }
            @finally {
                if (!_currentUser)
                    _currentUser = [[ZJUUser alloc] init];
            }
        }
        return _currentUser;
    }
    return nil;
}

- (void)dealloc
{
    [_details release];
    self.name = nil;
    self.email = nil;
    self.session = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        //self.ID = [aDecoder decodeObjectForKey:@"userID"];
        self.name = [aDecoder decodeObjectForKey:@"userName"];
        self.email = [aDecoder decodeObjectForKey:@"userEmail"];
        self.session = [aDecoder decodeObjectForKey:@"session"];
        _details = [[aDecoder decodeObjectForKey:@"details"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //    [aCoder encodeObject:self.ID
    //                  forKey:@"userID"];
    [aCoder encodeObject:self.name
                  forKey:@"userName"];
    [aCoder encodeObject:self.email
                  forKey:@"userEmail"];
    if (self.details.allKeys.count > 0)
        [aCoder encodeObject:self.details
                      forKey:@"details"];
    if (self.isLogin)
        [aCoder encodeObject:self.session
                      forKey:@"session"];
}

- (NSMutableDictionary*)details
{
    if (!_details) {
        _details = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _details;
}

- (BOOL)isLogin
{
    return self.session && self.session.isAuthenticated;
}

- (BOOL)saveToDisk
{
    return [NSKeyedArchiver archiveRootObject:self
                                       toFile:USER_SAVE_PATH];
}

- (void)logout
{
    self.session = nil;
    [self.details removeAllObjects];
    [self saveToDisk];
}

@end
