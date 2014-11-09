//
//  SchoolbusSpecifiedBusViewController.h
//  iZJU
//
//  Created by ricky on 12-11-16.
//
//

#import <UIKit/UIKit.h>
#import "ZJUBaseTableViewController.h"

@interface SchoolBusSpecifiedBusViewController : ZJUBaseTableViewController
{
    IBOutlet UIView              * headerView;
}

@property (nonatomic, strong) NSArray *results;
@end
