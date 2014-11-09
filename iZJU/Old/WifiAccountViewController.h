//
//  WifiAccountViewController.h
//  iZJU
//
//  Created by ricky on 12-12-20.
//
//

#import <UIKit/UIKit.h>
#import "ZJUBaseTableViewController.h"

@interface WifiAccountViewController : ZJUBaseTableViewController <UIAlertViewDelegate>
{
    NSArray                     * accounts;
    NSInteger                     modifingIndex;
}
@end
