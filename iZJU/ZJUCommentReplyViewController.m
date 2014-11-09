//
//  ZJUCommentReplyViewController.m
//  iZJU
//
//  Created by ricky on 13-8-22.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCommentReplyViewController.h"
#import "ZJURequest.h"
#import "Toast+UIView.h"
#import "ZJULoginViewController.h"
#import "ZJUUser.h"
#import <QuartzCore/QuartzCore.h>

@interface ZJUCommentReplyViewController () <UITextViewDelegate, UIAlertViewDelegate, ZJULoginViewDelegate>
{
    UIView                  * _filterView;
    UITextView              * _textView;
}
@property (nonatomic, retain) ZJUCommentReplyRequest *request;
- (void)onCancel:(id)sender;
- (void)onPost:(id)sender;
@end

@implementation ZJUCommentReplyViewController

- (void)dealloc
{
    [self.request cancel];
    self.request = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"发表评论";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 160)];
    _textView.layer.cornerRadius = 6.0f;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _textView.font = [UIFont systemFontOfSize:16.0];
    _textView.delegate = self;
    _textView.textColor = [UIColor darkGrayColor];
    [self.view addSubview:_textView];
    [_textView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(onCancel:)];
    UIBarButtonItem *postItem = [[UIBarButtonItem alloc] initWithTitle:@"发布"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(onPost:)];
    postItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [cancelItem autorelease];
    self.navigationItem.rightBarButtonItem = [postItem autorelease];
    
    [_textView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)onCancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onPost:(id)sender
{
    self.request = [ZJUCommentReplyRequest request];
    self.request.newsID = self.newsID;
    self.request.replyCommentID = self.replyCommentID;
    self.request.content = _textView.text;
    self.request.session = [ZJUUser currentUser].session;
    
    self.view.userInteractionEnabled = NO;
    [_textView resignFirstResponder];
    [self.view makeToastActivity];
    __block typeof(self) this = self;
    [self.request startRequestWithCompleteHandler:^(ZJURequest *request) {
        
        if (request.response.errorCode == 0) {
            [this.view.window makeToast:@"发布成功！"
                               duration:2.0
                               position:@"center"];
            [this dismissModalViewControllerAnimated:YES];
        }
        else if (request.response.errorCode == -5) {
            [[[[UIAlertView alloc] initWithTitle:@"需要登录"
                                         message:@"您的登录信息已经过时，请重新登录！"
                                        delegate:this
                               cancelButtonTitle:@"好"
                               otherButtonTitles:nil] autorelease] show];
        }
        else {
            [this.view makeToast:request.response.message
                        duration:1.0
                        position:@"center"];
            [this->_textView becomeFirstResponder];
        }
        [this.view hideToastActivity];
        this.view.userInteractionEnabled = YES;
    }];
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

#pragma mark - ZJULogin Delegate

- (void)loginView:(ZJULoginViewController *)loginController
 didLoginWithUser:(ZJUUser *)user
{
    [self onPost:nil];
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = textView.text.length > 0;
}

@end
