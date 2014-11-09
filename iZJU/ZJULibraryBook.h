//
//  ZJULibraryBook.h
//  iZJU
//
//  Created by ricky on 13-9-20.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface ZJULibraryBook : NSObject
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *ISBN;
@property (nonatomic, retain) NSString *coverImage;
@property (nonatomic, retain) NSString *publish;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *bookID;
@property (nonatomic, retain) NSArray *items;
+ (id)bookWithXMLElement:(GDataXMLElement*)element;
@end
