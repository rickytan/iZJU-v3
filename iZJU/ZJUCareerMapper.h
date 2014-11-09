//
//  ZJUCareerMapper.h
//  iZJU
//
//  Created by ricky on 13-6-28.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJUCareerMapper : NSObject
@property (nonatomic, retain) id item;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detail;
@property (nonatomic, readonly) NSString *comment;
@property (nonatomic, readonly) UIImage *badge;
+ (id)mapperWithItem:(id)item;
@end

@interface ZJUCareerInfoMapper : ZJUCareerMapper
@end

@interface ZJUCareerNewsMapper : ZJUCareerMapper
@end

@interface ZJUCareerTalkMapper : ZJUCareerMapper
@end