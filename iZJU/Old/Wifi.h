//
//  Wifi.h
//  iZJU
//
//  Created by ricky on 12-12-14.
//
//

#import <UIKit/UIKit.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "Reachability.h"
#import "ZJUBaseViewController.h"

typedef enum {
    kWiFiConnectStatusNone,
    kWiFiConnectStatusNeedLogin,
    kWiFiConnectStatusChecking,
    kWiFiConnectStatusAuthenticating,
    kWiFiConnectStatusConnected,
    kWiFiConnectStatusLocal,
    kWiFiConnectStatusNotSupported,
    kWiFiConnectStatusAuthenticateFailed
} WiFiConnectStatus;

@interface Wifi : ZJUBaseViewController
<UITableViewDataSource,
UITableViewDelegate,
ASIHTTPRequestDelegate,
UIAlertViewDelegate>
{
    Reachability                            * reachability;
    WiFiConnectStatus                         status;
    
    ASIFormDataRequest                      * authRequest;
    BOOL                                      redirected;
    BOOL                                      hasTriedAuthenticate;
    BOOL                                      manuallyLogout;
    
    NSString                                * authURL;
    NSDictionary                            * authConfig;
    
    IBOutlet UIActivityIndicatorView        * spinnerView;
    UIBarButtonItem                         * _logoutItem;
}

@property (nonatomic, assign) IBOutlet UITableView *tableView;

+ (NSArray*)getSavedAccounts;
+ (BOOL)saveAccount:(NSDictionary*)account;
+ (BOOL)deleteAccountAtIndex:(NSInteger)index;
+ (BOOL)updateAccount:(NSDictionary*)account atIndex:(NSInteger)index;
+ (void)setDefaultAccountIndex:(NSUInteger)index;
+ (NSInteger)defaultAccountIndex;
@end
