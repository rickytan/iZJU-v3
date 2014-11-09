//
//  Library.h
//  iZJU
//
//  Created by ricky on 12-11-23.
//
//

#import <UIKit/UIKit.h>
#import "ZJUBaseViewController.h"

@interface Library : ZJUBaseViewController
<UIWebViewDelegate>
{
    UIActivityIndicatorView             * spinnerView;
    UISegmentedControl                  * segmentView;
}
@end
