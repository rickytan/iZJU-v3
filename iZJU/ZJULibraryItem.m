//
//  ZJULibraryItem.m
//  iZJU
//
//  Created by ricky on 13-9-20.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJULibraryItem.h"

static const NSDictionary * ZJU_BOOK_STATUS_MAP = nil;

@implementation ZJULibraryItem

+ (void)initialize
{
    ZJU_BOOK_STATUS_MAP = [@{
                           @"12" : @"已借出",
                           @"11" : @"订购中",
                           @"21" : @"在架上"
                           } retain];
}

+ (id)itemWithXMLElement:(GDataXMLElement *)element
{
    ZJULibraryItem *item = [[ZJULibraryItem alloc] init];
    
    //NSError *error = nil;
    
    item.sublibrary = [[[[element elementsForName:@"sub-library"] lastObject] stringValue] stringByAppendingString:[[[element elementsForName:@"collection"] lastObject] stringValue]];
    item.barcode = [[[element elementsForName:@"barcode"] lastObject] stringValue];
    item.status = ZJU_BOOK_STATUS_MAP[[[[element elementsForName:@"item-status"] lastObject] stringValue]];
    if (!item.status)
        item.status = @"未知状态";
    item.locationID = [[[element elementsForName:@"call-no-1"] lastObject] stringValue];
    item.returnDate = [[[element elementsForName:@"loan-due-date"] lastObject] stringValue];
    item.hold = [[[[element elementsForName:@"on-hold"] lastObject] stringValue] isEqualToString:@"Y"];
    
    return [item autorelease];
}

@end
