//
//  ZJUCommentCell.h
//  iZJU
//
//  Created by ricky on 13-8-3.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJUCommentCell : UITableViewCell
@property (nonatomic, retain) NSDictionary *commentItem;
@property (nonatomic, assign) NSUInteger newsID;

+ (CGFloat)heightWithItem:(NSDictionary*)commentItem;
- (void)showMenu;

@end
