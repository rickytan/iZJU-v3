//
//  SchoolBusSearchResultViewController.h
//  iZJU
//
//  Created by ricky on 12-10-23.
//
//

#import <UIKit/UIKit.h>
#import "SchoolBusSearchResultCell.h"
#import "ZJUBaseTableViewController.h"

@class SchoolBusSearchResultViewController;

@protocol SchoolBusSearchResultViewControllerDelegate <NSObject>
@optional
- (void)SchoolBusSearchResultDidPressReverse:(SchoolBusSearchResultViewController*)resultView;

@end

@interface SchoolBusSearchResultViewController : ZJUBaseTableViewController
{
    IBOutlet UIView              * headerView;
}

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, assign) id<SchoolBusSearchResultViewControllerDelegate> delegate;

@end
