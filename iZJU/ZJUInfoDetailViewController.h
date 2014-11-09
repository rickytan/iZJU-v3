//
//  ZJUInfoDetailViewController.h
//  iZJU
//
//  Created by ricky on 13-6-8.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBaseViewController.h"

@interface ZJUInfoDetailViewController : ZJUBaseViewController
{
@private
    UIView                      * _navbarShadowView;
    UIImage                     * _originNavbarImage;
    UIImage                     * _originShadowImage;
    NSURL                       * _imageURL;
    CGRect                        _imageRect;
}
// Only one of the following should be set
@property (nonatomic, retain) NSString *htmlTemplate;       // Use for ZJUCareer News and Talk
@property (nonatomic, retain) NSURL *url;                   // Use for ZJUInfo
@property (nonatomic, retain) NSURL *directURL;             // Use for web page
// @property (nonatomic, retain) NSDictionary *newsDetail;
// @property (nonatomic, retain) NSString *newsID;
@property (nonatomic, retain) NSDictionary *empolyItem;     // Use for ZJUCareerInfo Employment
@end
