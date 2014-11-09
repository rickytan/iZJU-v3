//
//  ZJUCareerInfoListViewController.h
//  iZJU
//
//  Created by ricky on 13-6-12.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUInfoListViewController.h"
#import "ZJUBaseViewController.h"
#import "ZJURequest.h"
#import "ZJUCareerMapper.h"

@interface ZJUCareerInfoListViewController : ZJUBaseTableViewController
@property (nonatomic, assign) CareerInfoType type;
@property (nonatomic, retain) ZJUCareerMapper *mapper;
@end
