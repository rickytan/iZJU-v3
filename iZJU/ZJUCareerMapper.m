//
//  ZJUCareerMapper.m
//  iZJU
//
//  Created by ricky on 13-6-28.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCareerMapper.h"

@implementation ZJUCareerMapper

+ (id)mapperWithItem:(id)item
{
    ZJUCareerMapper *mapper = [[self alloc] init];
    mapper.item = item;
    return [mapper autorelease];
}

@end
