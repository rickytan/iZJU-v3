//
//  ZJUAccountViewController.h
//  iZJU
//
//  Created by ricky on 13-6-10.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBaseViewController.h"

@class ZJUUser;
@class ZJUInfoView;
@class ZJUFavoriteViewController;


@interface ZJUAccountViewController : ZJUBaseViewController
{
@private
    ZJUInfoView                     * _infoView;
    UIView                          * _contentView;
    //UIView                          * _segmentView;
    //UITableView                     * _listView;
    
    ZJUFavoriteViewController       * _favController;
}
@property (nonatomic, retain) ZJUUser *user;
@end
