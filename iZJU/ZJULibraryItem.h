//
//  ZJULibraryItem.h
//  iZJU
//
//  Created by ricky on 13-9-20.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface ZJULibraryItem : NSObject
@property (nonatomic, retain) NSString *status;
@property (nonatomic, assign, getter = isHold) BOOL hold;
@property (nonatomic, retain) NSString *sublibrary;
@property (nonatomic, retain) NSString *locationID;
@property (nonatomic, retain) NSString *returnDate;
@property (nonatomic, retain) NSString *barcode;
@property (nonatomic, retain) NSString *count;
+ (id)itemWithXMLElement:(GDataXMLElement*)element;
@end
