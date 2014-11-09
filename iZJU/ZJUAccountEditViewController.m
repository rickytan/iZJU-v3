//
//  ZJUAccountEditViewController.m
//  iZJU
//
//  Created by ricky on 13-6-17.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUAccountEditViewController.h"
#import "ZJUEditingViewController.h"
#import "UIApplication+RExtension.h"
#import "Toast+UIView.h"

typedef enum {
    EditingStateNone,
    EditingStateName,
    EditingStateGender,
    EditingStatePhone,
} EditingState;

@interface ZJUAccountEditViewController () <UIAlertViewDelegate, ZJUEditingViewControllerDelegate>
{
    
}
@property (nonatomic, assign, getter = isModified) BOOL modified;
- (void)setGender:(Gender)gender;
- (void)setPhone:(NSString*)phone;
- (void)setSign:(NSString*)sign;
- (void)setEmail:(NSString*)email;
- (void)setName:(NSString*)name;
- (void)setBirth:(NSString*)birth;
- (void)setRealname:(NSString*)realname;
@end

@implementation ZJUAccountEditViewController

- (void)dealloc
{
    
    [super dealloc];
}

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"编辑个人信息";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]] autorelease];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(onBack:)];
    [back  setBackgroundImage:[[UIImage imageNamed:@"navbar-back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]
                     forState:UIControlStateNormal
                   barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(onSave:)];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.rightBarButtonItem = save;
    [back release];
    [save release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)setModified:(BOOL)modified
{
    _modified = modified;
    if (_modified)
        [self.tableView reloadData];
}

- (void)setEmail:(NSString *)email
{
    if (![self.user.email isEqual:email]) {
        self.user.email = [[email copy] autorelease];
        self.modified = YES;
    }
}

- (void)setPhone:(NSString *)phone
{
    if (!phone)
        return;
    
    if (![[self.user.details objectForKey:@"phone"] isEqual:phone]) {
        [self.user.details setObject:phone forKey:@"phone"];
        self.modified = YES;
    }
}

- (void)setName:(NSString *)name
{
    if (![self.user.name isEqualToString:name]) {
        self.user.name = [[name copy] autorelease];
        self.modified = YES;
    }
}

- (void)setSign:(NSString *)sign
{
    if (!sign)
        return;
    
    if (![[self.user.details objectForKey:@"sign"] isEqual:sign]) {
        [self.user.details setObject:sign forKey:@"sign"];
        self.modified = YES;
    }
}

- (void)setGender:(Gender)gender
{
    if ([[self.user.details objectForKey:@"sex"] intValue] != gender) {
        [self.user.details setObject:@(gender)
                              forKey:@"sex"];
        self.modified = YES;
    }
}

- (void)setBirth:(NSString *)birth
{
    if (!birth)
        return;
    
    if (![[self.user.details objectForKey:@"birth"] isEqual:birth]) {
        [self.user.details setObject:birth
                              forKey:@"birth"];
        self.modified = YES;
    }
}

- (void)setRealname:(NSString *)realname
{
    if (!realname)
        return;
    
    if (![[self.user.details objectForKey:@"realname"] isEqual:realname]) {
        [self.user.details setObject:realname
                              forKey:@"realname"];
        self.modified = YES;
    }
}

- (void)onBack:(UIBarButtonItem*)backItem
{
    if (self.isModified) {
        [[[[UIAlertView alloc] initWithTitle:@"不保存就返回？"
                                     message:@"您已经对信息进行过修改，直接返回将会丢失。确定要返回吗？"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                           otherButtonTitles:@"确认", nil] autorelease] show];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSave:(UIBarButtonItem*)saveItem
{
    self.view.userInteractionEnabled = NO;
    [self.view makeToastActivity];
    
    ZJUUserInfoSaveRequest *request = [ZJUUserInfoSaveRequest request];
    request.session = self.user.session;
    request.detailedInfo = self.user.details;
    [request startRequestWithCompleteHandler:^(ZJURequest *request) {
        if (request.response.errorCode == 0) {
            [self.view makeToast:@"保存成功！"];
            self.modified = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [self.view makeToast:request.response.message];
        self.view.userInteractionEnabled = YES;
        [self.view hideToastActivity];
    }];
}

- (void)onLogout:(id)sender
{
    [[ZJUUser currentUser] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITable Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    else if (section == 1)
        return 2;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 2)
        return 44;
    return 32;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return [NSString stringWithFormat:@"iZJU工作室©2013 iZJU软件版本%@\n所有权利保留", [[UIApplication sharedApplication] appVersion]];
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //cell.backgroundView = nil;
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"真实姓名";
                    cell.detailTextLabel.text = [self.user.details objectForKey:@"realname"];
                    break;
                case 1:
                    cell.textLabel.text = @"性别";
                    cell.detailTextLabel.text = ([[self.user.details objectForKey:@"sex"] intValue] == GenderGirl) ? @"女" : @"男";
                    break;
                case 2:
                    cell.textLabel.text = @"个性签名";
                    cell.detailTextLabel.text = [self.user.details objectForKey:@"sign"];
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //cell.backgroundView = nil;
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"生日";
                    cell.detailTextLabel.text = [self.user.details objectForKey:@"birth"];
                    break;
                case 1:
                    cell.textLabel.text = @"手机";
                    cell.detailTextLabel.text = [self.user.details objectForKey:@"phone"];
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
            logout.titleLabel.font = [UIFont systemFontOfSize:14];
            logout.titleLabel.textAlignment = UITextAlignmentCenter;
            logout.frame = cell.contentView.bounds;
            logout.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            logout.showsTouchWhenHighlighted = YES;
            //[logout setBackgroundImage:[UIImage imageNamed:@"quit.png"]
            //                  forState:UIControlStateNormal];
            [logout setTitle:@"退出登录"
                    forState:UIControlStateNormal];
            [logout setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            [logout addTarget:self
                       action:@selector(onLogout:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:logout];
            cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"quit.png"]] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZJUEditingViewController *editingController = [[ZJUEditingViewController alloc] init];
    editingController.delegate = self;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    editingController.title = cell.textLabel.text;
    editingController.string = cell.detailTextLabel.text;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                    editingController.type = EditingTypeOptions;
                    editingController.options = @[@"男", @"女"];
                    break;
                case 2:
                    editingController.type = EditingTypeTextView;
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    editingController.type = EditingTypeDate;
                    break;
                case 1:
                    editingController.type = EditingTypePhone;
                    break;
                default:
                    break;
            }
        default:
            break;
    }
    
    [self.navigationController pushViewController:editingController
                                         animated:YES];
    [editingController release];
}

#pragma mark - ZJUEditingView Delegate

- (void)editingViewController:(ZJUEditingViewController *)controller
        didEndEditingWithText:(NSString *)text
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self setRealname:text];
                    break;
                case 1:
                    [self setGender:[@[@"保密",@"男",@"女"] indexOfObject:text]];
                    break;
                case 2:
                    [self setSign:text];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self setBirth:text];
                    break;
                case 1:
                    [self setPhone:text];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

@end
