//
//  ZJULoginViewController.m
//  iZJU
//
//  Created by ricky on 13-6-8.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJULoginViewController.h"
#import "ZJUUser.h"
#import "UIView+iZJU.h"
#import "RAutoTextField.h"
#import "UIColor+RExtension.h"
#import "Toast+UIView.h"
#import "ZJURequest.h"
#import "APService.h"
#import <QuartzCore/QuartzCore.h>

@interface ZJUTextField : RAutoTextField
@end

@implementation ZJUTextField

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super rightViewRectForBounds:bounds];
    rect.origin.x -= 5;
    return rect;
}

@end

enum {
    USER_NAME_TAG = 50,
    PASS_WORD_TAG,
    EMAIL_TAG
};

@interface ZJULoginViewController () <UITextFieldDelegate>
@property (nonatomic, retain) ZJUUserNameCheckRequest *checkNmaeRequest;
@property (nonatomic, retain) ZJULoginRequest *loginRequest;
@property (nonatomic, retain) ZJURegisterRequest *registerRequest;
- (void)checkTextField:(UITextField*)textField;
@end

@implementation ZJULoginViewController
@synthesize userNameField = _userNameField;
@synthesize emailField = _emailField;
@synthesize passwordField = _passwordField;
@synthesize closeButton = _closeButton;
@synthesize forgetButton = _forgetButton;
@synthesize loginButton = _loginButton;
@synthesize registerButton = _registerButton;

- (void)dealloc
{
    self.checkNmaeRequest = nil;
    self.loginRequest = nil;
    self.registerRequest = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bg.image = [UIImage imageNamed:@"login-bg.png"];
    bg.contentMode = UIViewContentModeScaleAspectFill;
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bg];
    [bg release];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logo.center = self.view.center;
    logo.top = 12;
    logo.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:logo];
    [logo release];
    
    [self.view addSubview:self.userNameField];
    [self.view addSubview:self.passwordField];
    
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.loginButton];
    //[self.view addSubview:self.forgetButton];
    [self.view addSubview:self.closeButton];
    
    if ([ZJUUser currentUser].name.length > 0) {
        self.userNameField.text = [ZJUUser currentUser].name;
        [self checkTextField:self.userNameField];
        _flags.userNameChecked = 1;
    }
    
    self.state = ZJULoginStateLogin;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(onDismiss:)];
    self.navigationItem.leftBarButtonItem = [leftItem autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter & setter

- (UIButton*)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 6, 30, 30)];
        [_closeButton setImage:[UIImage imageNamed:@"close-icon.png"]
                      forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(onClose:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton*)loginButton
{
    if (!_loginButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setBackgroundImage:[UIImage imageNamed:@"login-btn.png"]
                          forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [button setTitle:@"登录"
                forState:UIControlStateNormal];
        
        [button addTarget:self
                   action:@selector(onLogin:)
         forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        button.center = self.view.center;
        button.top = 260;
        button.right = 150;
        _loginButton = [button retain];
    }
    return _loginButton;
}

- (UIButton*)registerButton
{
    if (!_registerButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setBackgroundImage:[UIImage imageNamed:@"reg-btn.png"]
                          forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [button setTitle:@"注册"
                forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"arrow-right.png"]
                forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(onRegister:)
         forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        button.center = self.view.center;
        button.top = 260;
        button.left = 170;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -15 , 0, 15);
        _registerButton = [button retain];
    }
    return _registerButton;
}

- (UIButton*)forgetButton
{
    if (!_forgetButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:1.0*0/255
                                              green:1.0*183/255
                                               blue:1.0*238/255
                                              alpha:0.7]
                     forState:UIControlStateHighlighted];
        [button setTitle:@"忘记密码"
                forState:UIControlStateNormal];
        UIImage *image = [UIImage imageNamed:@"arrow-right.png"];
        [button setImage:image
                forState:UIControlStateNormal];
        button.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [button sizeToFit];
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 60, -2, -60);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 15);
        button.center = self.view.center;
        button.top = 360;
        _forgetButton = [button retain];
    }
    return _forgetButton;
}

- (UITextField*)userNameField
{
    if (!_userNameField) {
        UITextField  *textField = [[ZJUTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 32)];
        textField.background = [UIImage imageNamed:@"input-bg.png"];
        /*
         _userNameField.backgroundColor = [UIColor colorWithRed:1.0*15/255
         green:1.0*46/255
         blue:1.0*141/255
         alpha:0.7];
         */
        textField.placeholder = @"用户名";
        textField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        textField.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
        textField.textColor = [UIColor whiteColor];
        textField.leftView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user.png"]] autorelease];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.center = self.view.center;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.top = 180;
        textField.delegate = self;
        textField.tag = USER_NAME_TAG;
        _userNameField = textField;
    }
    return _userNameField;
}

- (UITextField*)emailField
{
    if (!_emailField) {
        UITextField *textField = [[ZJUTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 32)];
        textField.background = [UIImage imageNamed:@"input-bg.png"];
        textField.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
        textField.textColor = [UIColor whiteColor];
        textField.placeholder = @"邮箱（只能zju.edu.cn）";
        textField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        textField.leftView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email.png"]] autorelease];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.center = self.view.center;
        textField.top = 220;
        textField.hidden = YES;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.delegate = self;
        textField.tag = EMAIL_TAG;
        _emailField = textField;
    }
    return _emailField;
}

- (UITextField*)passwordField
{
    if (!_passwordField) {
        UITextField  *textField = [[ZJUTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 32)];
        textField.background = [UIImage imageNamed:@"input-bg.png"];
        /*
         _userNameField.backgroundColor = [UIColor colorWithRed:1.0*15/255
         green:1.0*46/255
         blue:1.0*141/255
         alpha:0.7];
         */
        textField.placeholder = @"密码（至少六位）";
        textField.secureTextEntry = YES;
        textField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        textField.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
        textField.textColor = [UIColor whiteColor];
        textField.leftView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pass.png"]] autorelease];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.returnKeyType = UIReturnKeyJoin;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.center = self.view.center;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.top = 220;
        textField.delegate = self;
        textField.tag = PASS_WORD_TAG;
        _passwordField = textField;
    }
    return _passwordField;
}

#pragma mark - Methods

- (void)checkTextField:(UITextField *)textField
{
    UIImageView *check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
    textField.rightView = check;
    [check release];
}

- (void)verifyUserName
{
    _flags.userNameChecked = 0;
    
    __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.userNameField.rightView = spinner;
    [spinner startAnimating];
    
    ZJUUserNameCheckRequest *request = self.checkNmaeRequest;
    if (request)
        [request cancel];
    
    request = [ZJUUserNameCheckRequest request];
    self.checkNmaeRequest = request;
    request.username = self.userNameField.text;
    __block typeof(self) this = self;
    [request startRequestWithCompleteHandler:^(ZJURequest *r) {
        [spinner stopAnimating];
        [spinner release];
        
        ZJUUserNameCheckResponse *response = request.response;
        if (response.errorCode == 0 && response.isAvailable) {
            [this checkTextField:this.userNameField];
            _flags.userNameChecked = 1;
        }
        else if (response.errorCode != 0)
            [this.view makeToast:response.message
                        duration:3.0
                        position:@"bottom"];
        else {
            this.userNameField.textColor = [UIColor redColor];
            [this.view makeToast:@"该帐号已被占用！"
                        duration:2.0
                        position:@"center"];
        }
        this.checkNmaeRequest = nil;
    }];
}

- (void)setState:(ZJULoginState)state
{
    if (_state == state)
        return;
    
    switch (state) {
        case ZJULoginStateLogin:
            self.userNameField.top = 180;
            self.forgetButton.alpha = 0.0;
            //self.forgetButton.hidden = NO;
            [UIView animateWithDuration:0.35
                             animations:^{
                                 self.passwordField.top = 220;
                                 
                                 self.emailField.alpha = 0.0;
                                 self.emailField.top = 200;
                                 
                                 self.registerButton.top = 260;
                                 [self.registerButton setImage:[UIImage imageNamed:@"arrow-right.png"]
                                                      forState:UIControlStateNormal];
                                 self.registerButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
                                 self.registerButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15 , 0, 15);
                                 
                                 self.loginButton.top = 260;
                                 [self.loginButton setImage:nil
                                                   forState:UIControlStateNormal];
                                 self.loginButton.imageEdgeInsets = UIEdgeInsetsZero;
                                 self.loginButton.titleEdgeInsets = UIEdgeInsetsZero;
                                 
                                 self.forgetButton.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 [self.emailField removeFromSuperview];
                             }];
            break;
        case ZJULoginStateRegister:
            self.userNameField.top = 180;
            [self.view insertSubview:self.emailField
                        belowSubview:self.userNameField];
            self.emailField.alpha = 0.0;
            self.emailField.hidden = NO;
            
            if (self.userNameField.text.length > 0)
                [self verifyUserName];
            [UIView animateWithDuration:0.35
                             animations:^{
                                 self.passwordField.top = 260;
                                 
                                 self.emailField.alpha = 1.0;
                                 self.emailField.top = 220;
                                 
                                 self.registerButton.top = 300;
                                 [self.registerButton setImage:nil
                                                      forState:UIControlStateNormal];
                                 self.registerButton.imageEdgeInsets = UIEdgeInsetsZero;
                                 self.registerButton.titleEdgeInsets = UIEdgeInsetsZero;
                                 
                                 self.loginButton.top = 300;
                                 [self.loginButton setImage:[UIImage imageNamed:@"arrow-left.png"]
                                                   forState:UIControlStateNormal];
                                 self.loginButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
                                 
                                 self.forgetButton.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 self.forgetButton.hidden = YES;
                             }];
            break;
        case ZJULoginStateForget:
            
            break;
        default:
            break;
    }
    _state = state;
}

- (void)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if ([self.delegate respondsToSelector:@selector(loginViewDidCancelled:)])
                                     [self.delegate loginViewDidCancelled:self];
                             }];
}

- (void)onLogin:(id)sender
{
    if (self.state != ZJULoginStateLogin)
        self.state = ZJULoginStateLogin;
    else {
        if (_flags.userNameChecked && _flags.passWordChecked) {
            self.view.userInteractionEnabled = NO;
            [self.view makeToastActivity];
            
            ZJULoginRequest *request = [ZJULoginRequest request];
            self.loginRequest = request;
            request.username = self.userNameField.text;
            request.password = self.passwordField.text;
            __block typeof(self) this = self;
            [request startRequestWithCompleteHandler:^(ZJURequest *request) {
                [this.view hideToastActivity];
                this.view.userInteractionEnabled = YES;
                
                ZJULoginResponse *response = ((ZJULoginRequest*)request).response;
                if (response.errorCode == 0) {
                    __block ZJUUser *user = response.user;
                    [user saveToDisk];
                    __block typeof(self) strongSelf = [this retain];
                    [this dismissViewControllerAnimated:YES
                                             completion:^{
                                                 if ([strongSelf.delegate respondsToSelector:@selector(loginView:didLoginWithUser:)])
                                                     [strongSelf.delegate loginView:strongSelf
                                                                   didLoginWithUser:user];
                                                 [strongSelf release];
                                             }];
                }
                else
                    [this.view makeToast:response.message
                                duration:3.0
                                position:@"bottom"];
            }];
        }
        else {
            [self.view makeToast:@"请填写信息！"];
        }
    }
}

- (void)onRegister:(id)sender
{
    if (self.state != ZJULoginStateRegister)
        self.state = ZJULoginStateRegister;
    else {
        if (_flags.userNameChecked && _flags.passWordChecked && _flags.emailChecked) {
            self.view.userInteractionEnabled = NO;
            [self.view makeToastActivity];
            
            ZJURegisterRequest *request = [ZJURegisterRequest request];
            self.registerRequest = request;
            request.username = self.userNameField.text;
            request.email = self.emailField.text;
            request.password = self.passwordField.text;
            __block typeof(self) this = self;
            [request startRequestWithCompleteHandler:^(ZJURequest *request) {
                [this.view hideToastActivity];
                this.view.userInteractionEnabled = YES;
                
                ZJULoginResponse *response = ((ZJURegisterRequest*)request).response;
                if (response.errorCode == 0) {
                    __block ZJUUser *user = response.user;
                    [APService setTags:nil
                                 alias:[ZJUUser currentUser].name
                      callbackSelector:NULL
                                object:nil];
                    [user saveToDisk];
                    [this dismissViewControllerAnimated:YES
                                             completion:^{
                                                 if ([this.delegate respondsToSelector:@selector(loginView:didLoginWithUser:)])
                                                     [this.delegate loginView:this
                                                             didLoginWithUser:user];
                                             }];
                }
                else
                    [this.view makeToast:response.message
                                duration:3.0
                                position:@"bottom"];
            }];
        }
        else {
            [self.view makeToast:@"请填写信息！"];
        }
    }
}

- (void)onForget:(id)sender
{
    
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == USER_NAME_TAG)
        self.userNameField.textColor = [UIColor whiteColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case USER_NAME_TAG:
        {
            if (self.state == ZJULoginStateRegister) {
                if (self.userNameField.text.length > 0) {
                    [self verifyUserName];
                }
                else {
                    self.userNameField.rightView = nil;
                    _flags.userNameChecked = 0;
                }
            }
            else if (self.state == ZJULoginStateLogin) {
                if (self.userNameField.text.length > 0) {
                    [self checkTextField:self.userNameField];
                    _flags.userNameChecked = 1;
                }
                else {
                    self.userNameField.rightView = nil;
                    _flags.userNameChecked = 0;
                }
            }
        }
            break;
        case EMAIL_TAG:
        {
            NSString *regExp = @"[a-zA-Z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[a-zA-Z]{2,4}";
            NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regExp];
            if ([match evaluateWithObject:self.emailField.text]) {
                if ([self.emailField.text hasSuffix:@"zju.edu.cn"]) {
                    [self checkTextField:self.emailField];
                    _flags.emailChecked = 1;
                }
                else {
                    [self.view makeToast:@"请填写zju邮箱！"
                                duration:3.0
                                position:@"center"];
                    self.emailField.rightView = nil;
                    _flags.emailChecked = 0;
                }
            }
            else if (self.emailField.text.length > 0 &&
                     [self.emailField.text rangeOfString:@"@"].location == NSNotFound) {
                self.emailField.text = [self.emailField.text stringByAppendingString:@"@zju.edu.cn"];
                [self checkTextField:self.emailField];
                _flags.emailChecked = 1;
            }
            else {
                self.emailField.rightView = nil;
                _flags.emailChecked = 0;
            }
        }
            break;
        case PASS_WORD_TAG:
            if (self.passwordField.text.length >= 6) {
                [self checkTextField:self.passwordField];
                _flags.passWordChecked = 1;
            }
            else {
                self.passwordField.rightView = nil;
                _flags.passWordChecked = 0;
            }
            break;
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == PASS_WORD_TAG) {
        [textField resignFirstResponder];
        if (self.state == ZJULoginStateLogin)
            [self onLogin:nil];
        else if (self.state == ZJULoginStateRegister)
            [self onRegister:nil];
        
        return YES;
    }
    return NO;
}

@end
