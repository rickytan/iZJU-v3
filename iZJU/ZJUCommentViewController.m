//
//  ZJUCommentViewController.m
//  iZJU
//
//  Created by ricky on 13-8-3.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCommentViewController.h"
#import "ODRefreshControl.h"
#import "ZJULoadMoreView.h"
#import "ZJURequest.h"
#import "ZJUCommentCell.h"
#import "UIView+iZJU.h"
#import "ZJUUser.h"
#import "ZJUCommentReplyViewController.h"
#import "ZJULoginViewController.h"

@interface ZJUCommentViewController ()
{
    ZJULoadMoreView             * _loadMoreView;
    ODRefreshControl            * _refreshControl;
}
@property (nonatomic, retain) ZJUCommentListRequest *request;
@property (nonatomic, readonly) NSMutableArray *newsItems;
//@property (nonatomic, retain) NSDate *requestTimestamp;
@property (nonatomic, retain) NSArray *originMenuItem;
- (void)reloadNews;
- (void)appendNews;
- (void)onReload:(id)sender;
- (void)onLoadMore:(id)sender;

- (void)onPost:(id)sender;
@end

@implementation ZJUCommentViewController
@synthesize newsItems = _newsItems;

- (void)dealloc
{
    [self.request cancel];
    self.request = nil;
    [UIMenuController sharedMenuController].menuItems = self.originMenuItem;
    self.originMenuItem = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"评论";
        self.originMenuItem = [UIMenuController sharedMenuController].menuItems;
        UIMenuItem *replyItem = [[UIMenuItem alloc] initWithTitle:@"回复"
                                                           action:@selector(reply:)];
        [UIMenuController sharedMenuController].menuItems = @[replyItem];
        [replyItem release];
        [[UIMenuController sharedMenuController] update];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]] autorelease];
    UIBarButtonItem *postItem = [[UIBarButtonItem alloc] initWithTitle:@"写跟帖"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(onPost:)];
    self.navigationItem.rightBarButtonItem = [postItem autorelease];
    
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
    //self.requestTimestamp = [NSDate date];
    
    self.request = [ZJUCommentListRequest request];
    self.request.newsID = self.newsID;
    //    self.request.timestamp = self.requestTimestamp;
    
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [self.newsItems removeAllObjects];
            [self.newsItems addObjectsFromArray:self.request.response.commentArray];
            [self.tableView reloadData];
            
            if (self.request.response.commentArray.count == 20)
                _loadMoreView.loadingState = ZJULoadMoreViewStateMayHaveMore;
            else
                _loadMoreView.loadingState = ZJULoadMoreViewStateNoMore;
        }
        else {
            _loadMoreView.loadingState = ZJULoadMoreViewStateError;
        }
        self.request = nil;
        [_refreshControl endRefreshing];
    }];
}

- (void)appendNews
{
    if (self.request.isLoading)
        return;
    
    _loadMoreView.loadingState = ZJULoadMoreViewStateLoading;
    
    self.request = [ZJUCommentListRequest request];
    self.request.newsID = self.newsID;
    self.request.page = self.newsItems.count / 20;
    //    self.request.timestamp = self.requestTimestamp;
    
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [self.newsItems addObjectsFromArray:self.request.response.commentArray];
            [self.tableView reloadData];
            
            if (self.request.response.commentArray.count == 20)
                _loadMoreView.loadingState = ZJULoadMoreViewStateMayHaveMore;
            else
                _loadMoreView.loadingState = ZJULoadMoreViewStateNoMore;
        }
        else {
            _loadMoreView.loadingState = ZJULoadMoreViewStateError;
        }
        self.request = nil;
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

- (void)onPost:(id)sender
{
    if ([ZJUUser currentUser].isLogin) {
        ZJUCommentReplyViewController *replyController = [[ZJUCommentReplyViewController alloc] init];
        replyController.newsID = self.newsID;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:replyController];
        nav.navigationBar.translucent = NO;
        [self presentModalViewController:nav
                                animated:YES];
        [replyController release];
        [nav release];
    }
    else {
        ZJULoginViewController *loginController = [[ZJULoginViewController alloc] init];
        [self presentModalViewController:loginController
                                animated:YES];
        [loginController release];
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
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    return [ZJUCommentCell heightWithItem:item];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ZJUCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[ZJUCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier] autorelease];
        cell.newsID = self.newsID;
        //cell.delegate = self;
    }
    // Configure the cell...
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    
    cell.commentItem = item;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    ZJUCommentCell *cell = (ZJUCommentCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell showMenu];
}

@end
