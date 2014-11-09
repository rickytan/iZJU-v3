//
//  ZJUInfoListCell.h
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJUCommentBubble.h"

@class ZJUInfoListCell;

@protocol ZJUInfoListCellDelegate <NSObject>
@optional
- (void)infoListCellDidTapUsername:(ZJUInfoListCell*)cell;
- (void)infoListCellDidTapComment:(ZJUInfoListCell *)cell;

@end

@interface ZJUInfoListCell : UITableViewCell
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, readonly) ZJUCommentBubble *comment;
@property (nonatomic, readonly, retain) UIImageView *badgeImage;
@property (nonatomic, assign) IBOutlet id<ZJUInfoListCellDelegate> delegate;
@property (nonatomic, assign) BOOL textGray;
@end
