//
//  ZJULibraryBook.m
//  iZJU
//
//  Created by ricky on 13-9-20.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJULibraryBook.h"
#import "ZJULibraryItem.h"

@implementation ZJULibraryBook

+ (id)bookWithXMLElement:(GDataXMLElement *)element
{
    ZJULibraryBook *book = [[ZJULibraryBook alloc] init];
    
    NSError *error = nil;
    GDataXMLElement *el = [[element elementsForName:@"metadata"] lastObject];
    el = [[el elementsForName:@"oai_marc"] lastObject];
    
    GDataXMLElement *authorEl = [[el nodesForXPath:@"varfield[@id='200']"
                                             error:&error] lastObject];
    
    if (authorEl) {
        book.name = [[[authorEl nodesForXPath:@"subfield[@label='a']"
                                        error:&error] lastObject] stringValue];
        book.author = [[[authorEl nodesForXPath:@"subfield[@label='f']"
                                          error:&error] lastObject] stringValue];
    }
    else {
        authorEl = [[el nodesForXPath:@"varfield[@id='245']"
                                error:&error] lastObject];
        book.name = [[[authorEl nodesForXPath:@"subfield[@label='a']"
                                        error:&error] lastObject] stringValue];
        book.author = [[[authorEl nodesForXPath:@"subfield[@label='c']"
                                          error:&error] lastObject] stringValue];
    }
    
    GDataXMLElement *publishEl = [[el nodesForXPath:@"varfield[@id='210']"
                                              error:&error] lastObject];
    if (publishEl) {
        book.publish = [publishEl.children componentsJoinedByString:@" "];
        book.year = [[[publishEl nodesForXPath:@"subfield[@label='d']"
                                         error:&error] lastObject] stringValue];
    }
    else {
        publishEl = [[el nodesForXPath:@"varfield[@id='260']"
                                 error:&error] lastObject];
        book.publish = [publishEl.children componentsJoinedByString:@" "];
        book.year = [[[publishEl nodesForXPath:@"subfield[@label='c']"
                                         error:&error] lastObject] stringValue];
    }
    
    
    book.ISBN = [[el nodesForXPath:@"varfield[@id='010']"
                             error:&error] componentsJoinedByString:@"\n"];
    if (book.ISBN.length == 0)
        book.ISBN = [[el nodesForXPath:@"varfield[@id='020']"
                                 error:&error] componentsJoinedByString:@"\n"];
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"\\d{3}-?\\d-?\\d{2,}-?\\d{2,}-?\\d"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
    NSArray *matches = [reg matchesInString:book.ISBN
                                    options:NSMatchingReportCompletion
                                      range:NSMakeRange(0, book.ISBN.length)];
    if (matches.count) {
        NSTextCheckingResult *result = [matches objectAtIndex:0];
        NSString *isbn = [book.ISBN substringWithRange:result.range];
        book.coverImage = [NSString stringWithFormat:@"http://book.izju.org/index.php?client=aleph&isbn=%@/cover", isbn];
    }
    NSArray *arr = [el nodesForXPath:@"varfield[@id='606']"
                               error:&error];
    if (arr.count == 0)
        arr = [el nodesForXPath:@"varfield[@id='650']"
                          error:&error];
    
    NSMutableArray *strArr = [NSMutableArray arrayWithCapacity:arr.count];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GDataXMLElement *element = (GDataXMLElement*)obj;
        NSArray *sub = [element.children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            GDataXMLElement *el = (GDataXMLElement*)evaluatedObject;
            NSString *label = [el attributeForName:@"label"].stringValue;
            return [label.lowercaseString isEqualToString:label];
        }]];
        
        [strArr addObject:[sub componentsJoinedByString:@"/"]];
    }];
    
    book.category = [strArr componentsJoinedByString:@" "];
    
    book.summary = [[[el nodesForXPath:@"varfield[@id='330']/subfield[@label='a']"
                                 error:&error] lastObject] stringValue];
    if (!book.summary) {
        book.summary = [[[el nodesForXPath:@"varfield[@id='500']/subfield[@label='a']"
                                     error:&error] lastObject] stringValue];
    }
    book.bookID = [[[element nodesForXPath:@"doc_number"
                                     error:&error] lastObject] stringValue];
    
    return [book autorelease];
}

- (void)dealloc
{
    self.author = nil;
    self.category = nil;
    self.ISBN = nil;
    self.coverImage = nil;
    self.publish = nil;
    self.name = nil;
    self.year = nil;
    self.price = nil;
    self.summary = nil;
    self.bookID = nil;
    self.items = nil;
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"书名：%@\n作者：%@\n年份：%@\n出版社：%@\n分类：%@\nISBN：%@\nID：%@\n描述：%@", self.name, self.author, self.year, self.publish, self.category, self.ISBN, self.bookID, self.summary];
}

@end
