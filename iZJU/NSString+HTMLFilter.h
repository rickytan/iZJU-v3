//
//  ZJUHTMLFilter.h
//  iZJU
//
//  Created by ricky on 13-6-21.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTMLFilter)

- (NSString*)stringByFilterAttributesInSet:(NSSet*)attributes;
- (NSString*)stringByFilterAttributes;

- (NSString*)stringByFilterAllAttributesOfTagsInSet:(NSSet*)tags;
- (NSString*)stringByFilterAllAttributes;

- (NSString*)stringByReplacingVariableInDictionary:(NSDictionary*)dictionary;

@end
