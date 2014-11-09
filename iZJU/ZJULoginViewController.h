//
//  ZJULoginViewController.h
//  iZJU
//
//  Created by ricky on 13-6-8.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBaseViewController.h"

@class ZJULoginViewController;
@class ZJUUser;

@protocol ZJULoginViewDelegate <NSObject>
@optional
- (void)loginView:(ZJULoginViewController*)loginController
 didLoginWithUser:(ZJUUser*)user;
- (void)loginViewDidCancelled:(ZJULoginViewController*)loginController;

@end

typedef enum {
    ZJULoginStateLogin,
    ZJULoginStateRegister,
    ZJULoginStateForget,
}ZJULoginState;

@interface ZJULoginViewController : ZJUBaseViewController
{
    struct {
        unsigned int userNameChecked:1;
        unsigned int emailChecked:1;
        unsigned int passWordChecked:1;
    } _flags;
}
@property (nonatomic, readonly) UITextField *userNameField;
@property (nonatomic, readonly) UITextField *emailField;
@property (nonatomic, readonly) UITextField *passwordField;
@property (nonatomic, readonly) UIButton *closeButton;
@property (nonatomic, readonly) UIButton *loginButton;
@property (nonatomic, readonly) UIButton *registerButton;
@property (nonatomic, readonly) UIButton *forgetButton;
@property (nonatomic, assign) ZJULoginState state;
@property (nonatomic, assign) id<ZJULoginViewDelegate> delegate;
@end
