//
//  ZJUFeedbackViewController.m
//  iZJU
//
//  Created by ricky on 13-6-22.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUFeedbackViewController.h"
#import "UIView+iZJU.h"
#import "RAutoTextView.h"
#import "Toast+UIView.h"
#import "ZJULoginViewController.h"
#import "ZJUUser.h"
#import "ZJURequest.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#define MAIL_PULL_BOTTOM    54.0


@interface ZJUFeedbackViewController () <UITextViewDelegate, ZJULoginViewDelegate, UIAlertViewDelegate>
{
    SystemSoundID           soundID;
    BOOL                    didEdited;
    BOOL                    shouldSend;
}
@property (nonatomic, assign) UIView *mailCoverView;
@property (nonatomic, assign) UIView *mailPaperView;
@property (nonatomic, assign) UIView *mailPullView;
@property (nonatomic, assign) UIView *mailArrow;
@property (nonatomic, assign) RAutoTextView *textView;
@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) UIActivityIndicatorView *spinnerView;
@property (nonatomic, retain) ZJUFeedbackRequest *request;
@end

@implementation ZJUFeedbackViewController

- (void)dealloc
{
    [self.request cancel];
    self.request = nil;
    AudioServicesRemoveSystemSoundCompletion(soundID);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"联系我们";
        
        CFURLRef soundFileURL = (CFURLRef)[[NSBundle mainBundle] URLForResource:@"pulldown"
                                                                  withExtension:@"caf"];
        AudioServicesCreateSystemSoundID(soundFileURL, &soundID);
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    UIImageView *image = nil;
    UIImage *mailCover = [UIImage imageNamed:@"mail-cover.png"];
    UIImage *mailPaper = [UIImage imageNamed:@"mail-paper.png"];
    UIImage *mailPull = [UIImage imageNamed:@"mail-pull.png"];
    UIImage *mailArrow = [UIImage imageNamed:@"mail-arrow.png"];
    
    _mailCoverView = [[UIImageView alloc] initWithImage:mailCover];
    _mailCoverView.center = self.view.center;
    _mailCoverView.bottom = self.view.height;
    _mailCoverView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_mailCoverView];
    [_mailCoverView release];
    
    _mailPaperView = [[UIView alloc] initWithFrame:(CGRect){{0,0},mailPaper.size}];
    _mailPaperView.center = self.view.center;
    _mailPaperView.top = _mailCoverView.top - 68;
    _mailPaperView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    image = [[UIImageView alloc] initWithImage:mailPaper];
    [_mailPaperView addSubview:image];
    [image release];
    
    _textView = [[RAutoTextView alloc] init];
    _textView.visibleLinesWhenKeyboardOverlay = 4;
    _textView.left = 12;
    _textView.width = _mailPaperView.width - 12*2;
    _textView.top = 44;
    _textView.height = 100;
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.textColor = [UIColor lightGrayColor];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.text = @"请留下您的建议，帮助我们做得更好！";
    _textView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [_mailPaperView addSubview:_textView];
    [_textView release];
    
    [self.view insertSubview:_mailPaperView
                belowSubview:_mailCoverView];
    [_mailPaperView release];
    
    _mailPullView = [[UIView alloc] initWithFrame:(CGRect){{0,0},mailPull.size}];
    _mailPullView.center = self.view.center;
    _mailPullView.bottom = 0;
    _mailPullView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    image = [[UIImageView alloc] initWithImage:mailPull];
    [_mailPullView addSubview:image];
    [image release];
    
    
    image = [[UIImageView alloc] initWithImage:mailArrow];
    image.center = CGPointMake(_mailPullView.width/2, _mailPullView.height - 20);
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         CGPoint p = image.center;
                         p.y += 4;
                         image.center = p;
                     }
                     completion:NULL];
    [_mailPullView addSubview:image];
    [image release];
    self.mailArrow = image;
    
    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint center = image.center;
    center.y -= 8;
    _spinnerView.center = center;
    [_mailPullView addSubview:_spinnerView];
    [_spinnerView release];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.text = @"下拉发送";
    lable.textAlignment = UITextAlignmentCenter;
    lable.textColor = [UIColor colorWithWhite:0.8
                                        alpha:0.8];
    lable.backgroundColor = [UIColor clearColor];
    lable.font = [UIFont boldSystemFontOfSize:12];
    [lable sizeToFit];
    lable.center = image.center;
    lable.top -= 24;
    [_mailPullView addSubview:lable];
    [lable release];
    _label = lable;
    
    [self.view addSubview:_mailPullView];
    [_mailPullView release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(0xe3, 0xe8, 0xef);
    
    CATransform3D trans = CATransform3DIdentity;
    trans.m34 = -1.0 / 500;
    self.view.layer.sublayerTransform = trans;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPan:)];
    [self.mailPullView addGestureRecognizer:pan];
    [pan release];
    
    if (![ZJUUser currentUser].isLogin) {
        ZJULoginViewController *login = [[ZJULoginViewController alloc] init];
        login.delegate = self;
        [self presentModalViewController:login
                                animated:YES];
        [login release];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGPoint p = self.mailPullView.center;
    p.y = MAIL_PULL_BOTTOM - self.mailPullView.height / 2;
    [self.mailPullView moveEaseOutBounceTo:p
                                  duration:1.25];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)resetPulldown
{
    AudioServicesPlaySystemSound(soundID);
    self.label.text = @"下拉发送";
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.mailPullView.bottom = MAIL_PULL_BOTTOM;
                         self.mailPaperView.top = _mailCoverView.top - 68;
                     }];
}

- (void)onPan:(UIPanGestureRecognizer*)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self.view endEditing:YES];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint trans = [pan translationInView:self.view];
            if (trans.y > 64)
                trans.y = 64;
            
            self.mailPullView.bottom = MAIL_PULL_BOTTOM + trans.y;
            if (trans.y > 36) {
                if (!shouldSend)
                    AudioServicesPlaySystemSound(soundID);
                shouldSend = YES;
                self.label.text = @"松开发送";
            }
            else {
                if (shouldSend)
                    AudioServicesPlaySystemSound(soundID);
                shouldSend = NO;
                self.label.text = @"下拉发送";
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint v = [pan velocityInView:self.view];
            if (shouldSend || v.y > 600.0) {
                [self onSend:nil];
            }
            else
                [self resetPulldown];
        }
            break;
        case UIGestureRecognizerStateCancelled:
            [self resetPulldown];
            break;
        default:
            break;
    }
}

- (void)playSendAnimation
{
    __block UIImageView *mailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mail.png"]];
    mailImage.layer.anchorPoint = CGPointMake(0.5, 1.0);
    mailImage.bottom = self.view.height;
    mailImage.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-8, mailImage.height-8, mailImage.width+8*2, 8*2)
                                                            cornerRadius:8].CGPath;
    mailImage.layer.shadowRadius = 6;
    mailImage.layer.shadowColor = [UIColor grayColor].CGColor;
    mailImage.layer.shadowOpacity = 0.8;
    [self.view addSubview:mailImage];
    [mailImage release];
    
    self.mailCoverView.hidden = YES;
    self.mailPaperView.hidden = YES;
    self.mailPullView.hidden = YES;
    
    [UIView animateWithDuration:.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         mailImage.layer.transform = CATransform3DMakeRotation(45 * M_PI / 180, 1, 0, 0);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              mailImage.alpha = 0.0;
                                              mailImage.layer.transform = CATransform3DTranslate(mailImage.layer.transform, 0, -440/cosf(45 * M_PI / 180), 0);
                                          }
                                          completion:^(BOOL finished) {
                                              [mailImage removeFromSuperview];
                                              UILabel *label = [[UILabel alloc] init];
                                              label.text = @"您的建议已收到，我们会尽快回复！";
                                              label.textColor = RGB(16, 66, 182);
                                              label.backgroundColor = [UIColor clearColor];
                                              label.numberOfLines = 2;
                                              label.font = [UIFont boldSystemFontOfSize:16];
                                              label.textAlignment = UITextAlignmentCenter;
                                              [label sizeToFit];
                                              label.center = CGPointMake(self.view.width/2, 160);
                                              [self.view addSubview:label];
                                              [label release];
                                          }];
                     }];
}

- (void)onSend:(id)sender
{
    if (didEdited && self.textView.text.length > 0) {
        self.mailPullView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.label.alpha = 0.0;
                             self.mailArrow.alpha = 0.0;
                             self.mailPullView.bottom = self.view.height - self.mailCoverView.height / 2 + 56;
                             self.mailPaperView.top = self.mailCoverView.top + 12;
                         }
                         completion:^(BOOL finished) {
                             [self.spinnerView startAnimating];
                             
                             self.request = [ZJUFeedbackRequest request];
                             self.request.session = [ZJUUser currentUser].session;
                             self.request.message = self.textView.text;
                             __block typeof(self) this = self;
                             [self.request startRequestWithCompleteHandler:^(ZJURequest *request) {
                                 this.mailPullView.userInteractionEnabled = YES;
                                 if (request.response.errorCode == 0) {
                                     [this playSendAnimation];
                                 }
                                 else if (request.response.errorCode == -5) {
                                     [[[[UIAlertView alloc] initWithTitle:@"需要登录"
                                                                  message:@"您的登录信息已经过时，请重新登录！"
                                                                 delegate:this
                                                        cancelButtonTitle:@"好"
                                                        otherButtonTitles:nil] autorelease] show];
                                 }
                                 [this.spinnerView stopAnimating];
                                 this.label.alpha = 1.0;
                                 this.mailArrow.alpha = 1.0;
                                 [this resetPulldown];
                                 [this.view makeToast:request.response.message];
                             }];
                         }];
    }
    else {
        [self resetPulldown];
        [self.view makeToast:@"请填写内容！"
                    duration:1.0
                    position:@"bottom"];
    }
}

#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!didEdited) {
        didEdited = YES;
        textView.text = nil;
        textView.textColor = RGB(99, 108, 119);
    }
}

#pragma mark - ZJULogin Delegate

- (void)loginView:(ZJULoginViewController *)loginController
 didLoginWithUser:(ZJUUser *)user
{
    if (didEdited) {
        [self onSend:nil];
    }
}

- (void)loginViewDidCancelled:(ZJULoginViewController *)loginController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ZJULoginViewController *login = [[ZJULoginViewController alloc] init];
    login.delegate = self;
    [self presentModalViewController:login
                            animated:YES];
    [login release];
}

@end
