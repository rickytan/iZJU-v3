//
//  ZJUCareerInfoListViewController.m
//  iZJU
//
//  Created by ricky on 13-6-12.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCareerTalkListViewController.h"
#import "ZJUInfoListCell.h"
#import "ZJUInfoDetailViewController.h"
#import "ZJURequest.h"
#import "ZJULoadMoreView.h"
#import "UIView+iZJU.h"
#import "NSDate+RExtension.h"
#import "ODRefreshControl.h"
#import "Toast+UIView.h"

static NSString *const ZJUCareerTalkLastRequestTimestampKey = @"ZJUCareerTalkLastRequestTimestampKey";

@interface ZJUCareerTalkListViewController () <ZJUInfoListCellDelegate>
{
    ZJULoadMoreView             * _loadMoreView;
    ODRefreshControl            * _refreshControl;

}
@property (nonatomic, retain) ZJUCareerTalkRequest *request;
@property (nonatomic, readonly) NSMutableArray *newsItems;
@property (nonatomic, retain) NSDate *requestTimestamp;
- (void)reloadNews;
- (void)appendNews;
- (void)onReload:(id)sender;
- (void)onLoadMore:(id)sender;
@end

@implementation ZJUCareerTalkListViewController
@synthesize newsItems = _newsItems;

- (void)dealloc
{
    [self.request cancel];
    self.request = nil;
    [_newsItems release];
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]] autorelease];
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [_refreshControl addTarget:self
                        action:@selector(onReload:)
              forControlEvents:UIControlEventValueChanged];
    
    ZJULoadMoreView *loadMore = [[ZJULoadMoreView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    [loadMore addTarget:self
                 action:@selector(onLoadMore:)
       forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = loadMore;
    [loadMore release];
    _loadMoreView = loadMore;
    
    [_refreshControl beginRefreshing];
    [self reloadNews];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (NSMutableArray*)newsItems
{
    if (!_newsItems) {
        _newsItems = [[NSMutableArray alloc] initWithCapacity:57];
    }
    return _newsItems;
}

- (void)reloadNews
{
    if (self.request.isLoading)
        return;
    
    _loadMoreView.loadingState = ZJULoadMoreViewStateLoading;
    self.requestTimestamp = [NSDate date];
    
    self.request = [ZJUCareerTalkRequest request];
    self.request.timestamp = self.requestTimestamp;
    self.request.type = self.type;
    __block typeof(self) weakSelf = self;
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [weakSelf.newsItems removeAllObjects];
            [weakSelf.newsItems addObjectsFromArray:weakSelf.request.response.newsArray];
            [weakSelf.tableView reloadData];
            
            if (weakSelf.request.response.newsArray.count == 20)
                weakSelf->_loadMoreView.loadingState = ZJULoadMoreViewStateMayHaveMore;
            else
                weakSelf->_loadMoreView.loadingState = ZJULoadMoreViewStateNoMore;
        }
        else {
            weakSelf->_loadMoreView.loadingState = ZJULoadMoreViewStateError;
        }
        weakSelf.request = nil;
        [weakSelf->_refreshControl endRefreshing];
    }];
}

- (void)appendNews
{
    if (self.request.isLoading)
        return;
    
    _loadMoreView.loadingState = ZJULoadMoreViewStateLoading;
    
    self.request = [ZJUCareerTalkRequest request];
    self.request.page = self.newsItems.count / 20;
    self.request.timestamp = self.requestTimestamp;
    self.request.type = self.type;
    __block typeof(self) weakSelf = self;
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [weakSelf.newsItems addObjectsFromArray:weakSelf.request.response.newsArray];
            [weakSelf.tableView reloadData];
            
            if (weakSelf.request.response.newsArray.count == 20)
                weakSelf->_loadMoreView.loadingState = ZJULoadMoreViewStateMayHaveMore;
            else
                weakSelf->_loadMoreView.loadingState = ZJULoadMoreViewStateNoMore;
        }
        else {
            weakSelf->_loadMoreView.loadingState = ZJULoadMoreViewStateError;
        }
        weakSelf.request = nil;
    }];
}

- (void)onReload:(id)sender
{
    [self reloadNews];
}

- (void)onLoadMore:(id)sender
{
    [self appendNews];
}

- (BOOL)hasScheduledLocalNotificationForItem:(NSDictionary*)item
{
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *l in localNotifications) {
        if ([[l.userInfo objectForKey:@"type"] isEqualToString:@"career"] &&
            [[l.userInfo objectForKey:@"id"] isEqualToString:[item objectForKey:@"id"]]) {
            return YES;
        }
    }
    return NO;
}

- (void)scheduleLocalNotificationForItem:(NSDictionary*)item
{
    NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%@ %@", [item objectForKey:@"zphrq"], [item objectForKey:@"zphsjs"]] withFormat:@"yyyy-MM-dd HH:mm"];
    if (!date) {
        [self.view makeToast:@"时间格式无法识别！"];
        return;
    }
    
    NSString *ID = [item objectForKey:@"id"];
    NSString *urlStr = [NSString stringWithFormat:@"http://www.career.zju.edu.cn/ejob/xjh_detail_index.do?pkValue=%@", ID];
    NSDictionary *userinfo = @{@"id":[item objectForKey:@"id"],
                               @"type":@"career",
                               @"template":@"talk.html",
                               @"title":[item objectForKey:@"jbdwmc"],
                               @"url": urlStr
                               };
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"%@ 的宣讲会要开始了！", [item objectForKey:@"jbdwmc"]];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertAction = @"查看活动";
    localNotification.fireDate = [date dateByAddingTimeInterval:-30*60];
    localNotification.userInfo = userinfo;
    localNotification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [localNotification release];
}

- (void)cancelocalNotificationForItem:(NSDictionary*)item
{
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *l in localNotifications) {
        if ([[l.userInfo objectForKey:@"type"] isEqualToString:@"career"] &&
            [[l.userInfo objectForKey:@"id"] isEqualToString:[item objectForKey:@"id"]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:l];
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.newsItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ZJUInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[ZJUInfoListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item valueForKey:@"jbdwmc"];;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"时间:%@ %@",[item valueForKey:@"zphrq"], [item valueForKey:@"zphsjs"]];
    cell.userName = [NSString stringWithFormat:@"地点:%@", [item valueForKey:@"zphcdmc"]];
    cell.accessoryView = nil;
    
    if ([self hasScheduledLocalNotificationForItem:item])
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock.png"]] autorelease];
    
    NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%@ %@",[item valueForKey:@"zphrq"], [item valueForKey:@"zphsjs"]] withFormat:@"yyyy-MM-dd HH:mm"];
    if (date && [date compare:[NSDate date]] == NSOrderedAscending)
        cell.textGray = YES;
    else
        cell.textGray = NO;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    BOOL have = [self hasScheduledLocalNotificationForItem:item];
    UIMenuItem *menuitem = nil;
    if (!have) {
        menuitem = [[UIMenuItem alloc] initWithTitle:@"添加提醒"
                                                  action:@selector(onAddNotification:)];
    }
    else {
        menuitem = [[UIMenuItem alloc] initWithTitle:@"取消提醒"
                                              action:@selector(onCancelNotification:)];
    }
    [[UIMenuController sharedMenuController] setMenuItems:@[menuitem]];
    [[UIMenuController sharedMenuController] update];
    [menuitem release];
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
 canPerformAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    return action == @selector(copy:) || action == @selector(onAddNotification:) || action == @selector(onCancelNotification:);
}

- (void)tableView:(UITableView *)tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)sender
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    
    if (action == @selector(copy:)) {
        NSString *text = [NSString stringWithFormat:@"[企业]%@\n[地点]%@\n[时间]%@ %@", [item objectForKey:@"jbdwmc"], [item objectForKey:@"zphcdmc"], [item objectForKey:@"zphrq"], [item objectForKey:@"zphsjs"]];
        [UIPasteboard generalPasteboard].string = text;
    }
    else if (action == @selector(onAddNotification:)) {
        [self scheduleLocalNotificationForItem:item];
        [self.tableView reloadData];
    }
    else if (action == @selector(onCancelNotification:)) {
        [self cancelocalNotificationForItem:item];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    NSString *ID = [item objectForKey:@"id"];
    NSString *urlStr = [NSString stringWithFormat:@"http://www.career.zju.edu.cn/ejob/xjh_detail_index.do?pkValue=%@", ID];
    ZJUInfoDetailViewController *detail = [[ZJUInfoDetailViewController alloc] init];
    detail.url = [NSURL URLWithString:urlStr];
    detail.htmlTemplate = @"talk.html";
    detail.title = [item objectForKey:@"jbdwmc"];
    [self.navigationController pushViewController:detail
                                         animated:YES];
    [detail release];
    
}

#pragma mark - ZJUInfoCell delegate

- (void)infoListCellDidTapComment:(ZJUInfoListCell *)cell
{
    
}

#pragma mark - Scroll view Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint v = [scrollView.panGestureRecognizer velocityInView:scrollView];
    if (self.navigationController.isNavigationBarHidden && v.y > 80.0)
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
    else if (!self.navigationController.isNavigationBarHidden && v.y < -48.0)
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:YES];
}

@end
