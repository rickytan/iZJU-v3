//
//  ZJUAccountViewController.m
//  iZJU
//
//  Created by ricky on 13-6-10.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUAccountViewController.h"
#import "ZJUFavoriteViewController.h"
#import "ZJULoginViewController.h"
#import "ZJUAccountEditViewController.h"
#import "UIView+iZJU.h"
#import "ZJURequest.h"
#import "ZJUUser.h"
#import "Toast+UIView.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <QuartzCore/QuartzCore.h>

@interface ZJUInfoView : UIView
{
    UIImageView                 * _genderIndicatorView;
    UILabel                     * _nameLabel;
    UILabel                     * _signLabel;
}
@property (nonatomic, assign) UIImageView *backgroundView;
@property (nonatomic, assign) UIButton *avatarButton;
@property (nonatomic, assign) NSString *username;
@property (nonatomic, assign) NSString *sign;
@property (nonatomic, assign) Gender gender;
//@property (nonatomic, assign) UIButton *editButton;
@end

@implementation ZJUInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-4, self.height - 5, self.width + 8, 10)].CGPath;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.6;
        
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.image = [UIImage imageNamed:@"account-bg.png"];
        [self addSubview:_backgroundView];
        [_backgroundView release];
        
        
        _avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 13, 57, 57)];
        _avatarButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _avatarButton.layer.shadowRadius = 4.0;
        _avatarButton.layer.shadowOffset = CGSizeZero;
        _avatarButton.layer.shadowOpacity = 0.3;
        _avatarButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _avatarButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(_avatarButton.bounds, UIEdgeInsetsMake(-4, -4, -4, -4))
                                                                    cornerRadius:8].CGPath;
        [_avatarButton setBackgroundImage:[UIImage imageNamed:@"avatar-boy.png"]
                                 forState:UIControlStateNormal];
        [self addSubview:_avatarButton];
        [_avatarButton release];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarButton.right + 6, 14, 64, 20)];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = @" ";
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:_nameLabel];
        [_nameLabel release];
        
        _genderIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _genderIndicatorView.center = CGPointMake(_nameLabel.right + 8, _nameLabel.center.y);
        _genderIndicatorView.contentMode = UIViewContentModeCenter;
        _genderIndicatorView.image = [UIImage imageNamed:@"male.png"];
        _genderIndicatorView.hidden = YES;
        [self addSubview:_genderIndicatorView];
        [_genderIndicatorView release];
        
        _signLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarButton.right + 6, _nameLabel.bottom + 4, self.width - _avatarButton.right - 6, 28)];
        _signLabel.textColor = [UIColor whiteColor];
        _signLabel.backgroundColor = [UIColor clearColor];
        _signLabel.numberOfLines = 0;
        _signLabel.font = [UIFont systemFontOfSize:12];
        _signLabel.minimumFontSize = 10;
        _signLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_signLabel];
        [_signLabel release];
    }
    return self;
}

- (void)setGender:(Gender)gender
{
    if (_gender == gender)
        return;
    
    _gender = gender;
    [_avatarButton setBackgroundImage:(_gender == GenderGirl) ? [UIImage imageNamed:@"avatar-girl.png"] : [UIImage imageNamed:@"avatar-boy.png"]
                             forState:UIControlStateNormal];
    _genderIndicatorView.image = (_gender == GenderGirl) ? [UIImage imageNamed:@"female.png"] : [UIImage imageNamed:@"male.png"];
}

- (void)setUsername:(NSString *)username
{
    _nameLabel.text = username;
    [self setNeedsLayout];
}

- (NSString*)username
{
    return _nameLabel.text;
}

- (void)setSign:(NSString *)sign
{
    _signLabel.text = sign;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_nameLabel sizeToFit];
    _nameLabel.width = MIN(self.width - _nameLabel.left - 20, _nameLabel.width);
    
    _genderIndicatorView.hidden = NO;
    _genderIndicatorView.center = CGPointMake(_nameLabel.right + 8, _nameLabel.center.y);
}

@end

@interface ZJUAccountViewController ()
<UIAlertViewDelegate,
ZJULoginViewDelegate,
UIActionSheetDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
@property (nonatomic, retain) ZJUUserInfoRequest *infoRequest;
@property (nonatomic, retain) ZJUUserFavoriteRequest *favRequest;
- (void)loadUserInfo;
- (void)onAvatar:(id)sender;
- (void)reloadUserInfo;
@end

@implementation ZJUAccountViewController

- (void)dealloc
{
    [_infoView release];
    [_contentView release];
    [self.infoRequest cancel];
    [self.favRequest cancel];
    self.infoRequest = nil;
    self.favRequest = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我";
        
        _favController = [[ZJUFavoriteViewController alloc] init];
        [self addChildViewController:_favController];
        [_favController release];
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _infoView = [[ZJUInfoView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 86)];
    _infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_infoView];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, _infoView.height, self.view.width, self.view.height - _infoView.height)];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    [self.view bringSubviewToFront:_infoView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    ZJUUser *user = [ZJUUser currentUser];
    _infoView.username = user.name;
    [_infoView.avatarButton addTarget:self
                               action:@selector(onAvatar:)
                     forControlEvents:UIControlEventTouchUpInside];
    UIImage *placeHolder = [_infoView.avatarButton backgroundImageForState:UIControlStateNormal];
    if ([user.details.allKeys containsObject:@"avatar"]) {
        [_infoView.avatarButton setBackgroundImageWithURL:[NSURL URLWithString:[user.details objectForKey:@"avatar"]]
                                                 forState:UIControlStateNormal
                                         placeholderImage:placeHolder];
    }
    
    _favController.view.frame = _contentView.bounds;
    _favController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_contentView addSubview:_favController.view];
    
    if ([ZJUUser currentUser].isLogin)
        [self loadUserInfo];
    else {
        [self showLogin];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    [self reloadUserInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)showLogin
{
    ZJULoginViewController *login = [[ZJULoginViewController alloc] init];
    login.delegate = self;
    [self presentModalViewController:login
                            animated:YES];
    [login release];
}

- (void)reloadUserInfo
{
    ZJUUser *user = [ZJUUser currentUser];
    
    if ([user.details.allKeys containsObject:@"realname"])
        _infoView.username = [NSString stringWithFormat:@"%@(%@)", user.name, [user.details objectForKey:@"realname"]];
    else
        _infoView.username = user.name;
    _infoView.sign = [user.details objectForKey:@"sign"];
    _infoView.gender = [[user.details objectForKey:@"sex"] intValue];
    
    UIImage *placeHolder = [_infoView.avatarButton backgroundImageForState:UIControlStateNormal];
    if ([user.details.allKeys containsObject:@"avatar"])
        [_infoView.avatarButton setBackgroundImageWithURL:[NSURL URLWithString:[user.details objectForKey:@"avatar"]]
                                                 forState:UIControlStateNormal
                                         placeholderImage:placeHolder];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    ZJUAccountEditViewController *accountEdit = [[ZJUAccountEditViewController alloc] init];
    accountEdit.user = [ZJUUser currentUser];
    [self.navigationController pushViewController:accountEdit
                                         animated:YES];
    [accountEdit release];
}

- (void)loadUserInfo
{
    if (self.infoRequest.isLoading)
        return;
    
    self.infoRequest = [ZJUUserInfoRequest request];
    self.infoRequest.session = [ZJUUser currentUser].session;
    __block typeof(self) this = self;
    [self.infoRequest startRequestWithCompleteHandler:^(ZJURequest *request) {
        ZJUUserInfoResponse *resp = this.infoRequest.response;
        ZJUUser *user = [ZJUUser currentUser];
        if (resp.errorCode == 0) {
            if ([resp.realname isKindOfClass:[NSString class]])
                [user.details setObject:resp.realname
                                 forKey:@"realname"];
            [user.details setObject:@(resp.gender)
                             forKey:@"sex"];
            if ([resp.avatar isKindOfClass:[NSString class]])
                [user.details setObject:resp.avatar
                                 forKey:@"avatar"];
            if ([resp.phone isKindOfClass:[NSString class]])
                [user.details setObject:resp.phone
                                 forKey:@"phone"];
            if ([resp.sign isKindOfClass:[NSString class]])
                [user.details setObject:resp.sign
                                 forKey:@"sign"];
            if ([resp.birth isKindOfClass:[NSString class]])
                [user.details setObject:resp.birth
                                 forKey:@"birth"];
            
            [this reloadUserInfo];
        }
        else {
            if (resp.errorCode == -5) {
                [[[[UIAlertView alloc] initWithTitle:@"需要登录"
                                             message:@"您的登录信息已经过时，请重新登录！"
                                            delegate:this
                                   cancelButtonTitle:@"好"
                                   otherButtonTitles:nil] autorelease] show];
            }
            else
                [this.view makeToast:resp.message];
        }
    }];
}

- (void)loadUserFav
{
    
}

- (void)onAvatar:(id)sender
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"修改头像"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"从相册选取", @"从相机拍摄", nil];
    [action showInView:self.view];
    [action release];
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self showLogin];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:     // 相册
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        case 1:     // 相机
            if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                [imagePicker release];
                imagePicker = nil;
                [[[[UIAlertView alloc] initWithTitle:@"错误"
                                             message:@"您的设备不支持前置摄像头！"
                                            delegate:nil
                                   cancelButtonTitle:@"好"
                                   otherButtonTitles:nil] autorelease] show];
                return;
            }
            else {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(40, 40);
            }
            break;
        default:
            break;
    }
    [self presentModalViewController:imagePicker
                            animated:YES];
    [imagePicker release];
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
                                   
                                   ZJUUserInfoSaveRequest *request = [ZJUUserInfoSaveRequest request];
                                   request.session = [ZJUUser currentUser].session;
                                   request.avatarImage = image;
                                   self.view.userInteractionEnabled = NO;
                                   [self.view makeToastActivity];
                                   [request startRequestWithCompleteHandler:^(ZJURequest *request) {
                                       if (request.response.errorCode == 0) {
                                           [[SDImageCache sharedImageCache] removeImageForKey:[[ZJUUser currentUser].details objectForKey:@"avatar"]
                                                                                     fromDisk:YES];
                                           [_infoView.avatarButton setBackgroundImage:image
                                                                             forState:UIControlStateNormal];
                                       }
                                       else
                                           [self.view makeToast:request.response.message];
                                       self.view.userInteractionEnabled = YES;
                                       [self.view hideToastActivity];
                                   }];
                               }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - ZJULogin Delegate

- (void)loginView:(ZJULoginViewController *)loginController
 didLoginWithUser:(ZJUUser *)user
{
    [self loadUserInfo];
}

- (void)loginViewDidCancelled:(ZJULoginViewController *)loginController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
