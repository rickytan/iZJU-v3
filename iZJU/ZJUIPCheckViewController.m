//
//  ZJUIPCheckViewController.m
//  iZJU
//
//  Created by 董鑫宝 on 13-12-16.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUIPCheckViewController.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface ZJUIPCheckViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, retain, readonly) UITextField *IPTextField;
@property (nonatomic, retain, readonly) UIButton *button;
@property (nonatomic, retain, readonly) UILabel *IPResult1;
@property (nonatomic, retain, readonly) UILabel *IPResult2;
@end

@implementation ZJUIPCheckViewController
@synthesize IPTextField = _IPTextField;
@synthesize IPResult1 = _IPResult1, IPResult2 = _IPResult2;
@synthesize button = _button;

- (void)dealloc
{
    [_IPTextField release];
    [_IPResult1 release];
    [_IPResult2 release];
    _button = nil;
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = @"IP查询";
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	// Do any additional setup after loading the view.
    [self IPSearch:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (UITextField*)IPTextField
{
    if (!_IPTextField) {
        _IPTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, 220, 30)];
        _IPTextField.placeholder = @"请输入IP地址";
        _IPTextField.clearsOnInsertion = YES;
        _IPTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_IPTextField setBorderStyle:UITextBorderStyleLine];
        _IPTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_IPTextField setDelegate:self];
        if (IS_IOS_7) {
            _IPTextField.tintColor = [UIColor blueColor];
        }
        _IPTextField.text = [self getIPAddress];
    }
    return _IPTextField;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:CGRectMake(0, 0, 60, 30)];
        [_button setTitle:@"查询"
                 forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor darkGrayColor]
                      forState:UIControlStateNormal];
        [_button addTarget:self
                    action:@selector(IPSearch:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UILabel *)IPResult2
{
    if (!_IPResult2) {
        _IPResult2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 270, 30)];
        [_IPResult2 setFont:[UIFont systemFontOfSize:14.]];
        _IPResult2.adjustsFontSizeToFitWidth = YES;
        [_IPResult2 setMinimumFontSize:12.];
        _IPResult2.backgroundColor = [UIColor clearColor];
    }
    return _IPResult2;
}

- (UILabel *)IPResult1
{
    if (!_IPResult1) {
        _IPResult1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 270, 30)];
        _IPResult1.text = @"     暂无结果";
        [_IPResult1 setFont:[UIFont systemFontOfSize:14.]];
        _IPResult1.adjustsFontSizeToFitWidth = YES;
        [_IPResult1 setMinimumFontSize:12.];
        _IPResult1.backgroundColor = [UIColor clearColor];
    }
    return _IPResult1;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1)
        return @"Powered By lt6s.com";
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Cell"] autorelease];
        if (indexPath.section == 0) {
            [cell.contentView addSubview:self.IPTextField];
            cell.accessoryView = self.button;
        }
        else {
            [cell.contentView addSubview:self.IPResult1];
            [cell.contentView addSubview:self.IPResult2];
        }
        
        
    }
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.IPTextField resignFirstResponder];
    [self IPSearch:nil];
    return NO;
}

- (void)IPSearch:(UIButton *)sender
{
    [self.IPTextField resignFirstResponder];
    ASIFormDataRequest *httpRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.lt6s.com/index.php"]];
    [httpRequest setDelegate:self];
    [httpRequest setPostValue:_IPTextField.text forKey:@"ip"];
    [httpRequest setDidFailSelector:@selector(requestError:)];
    [httpRequest setDidFinishSelector:@selector(IPSearchFinished:)];
    [httpRequest startAsynchronous];
    
}

- (void)IPSearchFinished:(ASIFormDataRequest *)request
{
    //NSLog(@"%@", request.responseString);
    NSString *result = request.responseString;
    NSRange range = [result rangeOfString:@"<br />"];
    result = [result substringFromIndex:range.length + range.location];
    range = [result rangeOfString:@"<br />"];
    NSString *result1 = [result substringToIndex:range.location];
    result = [result substringFromIndex:range.location + range.length];
    range = [result rangeOfString:@"<br />"];
    NSString *result2 = [result substringToIndex:range.location];
    if ([result1 length] == 0) {
        result1 = @"请输入浙大校园网范围的IP。";
        result2 = @"";
    }
    self.IPResult1.text = result1;
    self.IPResult2.text = result2;
}

- (void)requestError:(ASIFormDataRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
    self.IPResult1.text = @"网络错误！";
    self.IPResult2.text = @"";
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 80;
    }
    else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

@end
