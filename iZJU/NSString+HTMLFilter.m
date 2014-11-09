//
//  ZJUHTMLFilter.m
//  iZJU
//
//  Created by ricky on 13-6-21.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+HTMLFilter.h"

@implementation NSString (HTMLFilter)

- (NSString*)stringByFilterAttributes
{
    NSSet *set = [NSSet setWithObjects:@"style", @"class",@"align", @"valign", @"color", @"id", @"face", @"width", @"height", @"size", @"border", @"onclick", @"cellspacing", @"cellpadding",@"nowrap", @"lang", @"bgcolor", nil];
    return [self stringByFilterAttributesInSet:set];
}

- (NSString*)stringByFilterAttributesInSet:(NSSet *)attributes
{
    NSString *string = [[self copy] autorelease];
    
    string = [string stringByReplacingOccurrencesOfString:@"(&nbsp;){4,}"
                                               withString:@"&nbsp;"
                                                  options:NSRegularExpressionSearch
                                                    range:NSMakeRange(0, string.length)];
    
    string = [string stringByReplacingOccurrencesOfString:@" {4,}"
                                               withString:@" "
                                                  options:NSRegularExpressionSearch
                                                    range:NSMakeRange(0, string.length)];
    
    for (NSString *attr in attributes) {
        NSString *pattern = [NSString stringWithFormat:@"\\s%@\\s*=\\s*\"[^\"]*\"", attr];
        
        NSError *error = nil;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                             options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionDotMatchesLineSeparators
                                                                               error:&error];
        
        string = [reg stringByReplacingMatchesInString:string
                                               options:0
                                                 range:NSMakeRange(0, string.length)
                                          withTemplate:@""];
    }
    return string;
}

- (NSString*)stringByFilterAllAttributes
{
    NSSet *set = [NSSet setWithObjects:@"span", @"div", @"p", @"font", @"table", @"td", @"tr", @"li", @"col", nil];
    return [self stringByFilterAllAttributesOfTagsInSet:set];
}

- (NSString*)stringByFilterAllAttributesOfTagsInSet:(NSSet *)tags
{
    NSMutableString *string = [[self mutableCopy] autorelease];
    
    for (NSString *tag in tags) {
#warning This is NOT ok
        NSString *pattern = [NSString stringWithFormat:@"<(%@)^class*(\\s(class)\\s*=\\s*['\"]?[^'\"]*['\"]?)?^class*\\/?>", tag];
        
        NSError *error = nil;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                             options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionDotMatchesLineSeparators
                                                                               error:&error];
        NSUInteger count = [reg replaceMatchesInString:string
                                               options:0
                                                 range:NSMakeRange(0, string.length)
                                          withTemplate:@"<$1$2>"];
        NSLog(@"%d matched!",count);
    }
    return string;
}

- (NSString*)stringByReplacingVariableInDictionary:(NSDictionary *)dictionary
{
    NSString *pattern = @"\\$\\{([a-z]+)\\}";
    NSError *error = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionDotMatchesLineSeparators
                                                                           error:&error];
    NSMutableString *mutaStr = [[self mutableCopy] autorelease];
    NSArray *matchedItem = [reg matchesInString:mutaStr
                                        options:0
                                          range:NSMakeRange(0, mutaStr.length)];
    NSInteger offset = 0;
    for (NSTextCheckingResult *result in matchedItem) {
        NSRange fullrange = [result rangeAtIndex:0];
        fullrange.location += offset;
        NSRange keyrange = [result rangeAtIndex:1];
        keyrange.location += offset;
        
        NSString *full = [mutaStr substringWithRange:fullrange];
        NSString *key = [mutaStr substringWithRange:keyrange];
        NSString *replacingStr = [dictionary objectForKey:key];
        if (!replacingStr || [replacingStr isKindOfClass:[NSNull class]])
            replacingStr = @"";
        else {
            replacingStr = [replacingStr stringByFilterAttributes];
        }
        [mutaStr replaceCharactersInRange:fullrange
                               withString:replacingStr];
        offset += replacingStr.length - full.length;
    }
    return [NSString stringWithString:mutaStr];
}

@end
