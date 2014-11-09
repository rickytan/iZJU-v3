//
//  ZJUBookDetailViewController.h
//  iZJU
//
//  Created by ricky on 13-9-20.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBaseTableViewController.h"
#import "ZJULibraryItem.h"
#import "ZJULibraryBook.h"

@interface ZJUBookDetailViewController : ZJUBaseTableViewController
@property (nonatomic, retain) ZJULibraryBook *book;
@end
