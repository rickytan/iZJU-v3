//
//  SchoolBusDetailViewController.h
//  iZJU
//
//  Created by ricky on 12-10-23.
//
//

#import <UIKit/UIKit.h>
#import "ZJUSchoolBusDataRequest.h"
#import "ZJUBaseTableViewController.h"

@interface SchoolBusDetailViewController : ZJUBaseTableViewController
@property (nonatomic, strong) ZJUSchoolBusDataItem *item;
@end
