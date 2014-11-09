//
//  ZJUInfoListViewController.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUFavoriteViewController.h"
#import "ZJUInfoListCell.h"
#import "ZJUInfoDetailViewController.h"
#import "ZJULoginViewController.h"
#import "ZJURequest.h"
#import "ZJULoadMoreView.h"
#import "ZJUFavoriteManager.h"
#import "UIView+iZJU.h"
#import "ZJUUser.h"
#import "ODRefreshControl.h"

@interface ZJUFavoriteViewController ()
{
    ZJULoadMoreView             * _loadMoreView;
    ODRefreshControl            * _refreshControl;
}
@property (nonatomic, retain) ZJUUserFavoriteRequest *request;
@property (nonatomic, readonly) NSMutableArray *newsItems;
- (void)reloadNews;
- (void)appendNews;
- (void)onReload:(id)sender;
- (void)onLoadMore:(id)sender;
@end

@implementation ZJUFavoriteViewController
@synthesize newsItems = _newsItems;

- (void)dealloc
{
    [self.request cancel];
    self.request = nil;
    
    [_refreshControl release];
    [_newsItems release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"校园信息";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor clearColor];
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
    
    
    if ([ZJUUser currentUser].isLogin) {
        [_refreshControl beginRefreshing];
        [self reloadNews];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.presentedViewController isKindOfClass:[ZJULoginViewController class]]) {
        if ([ZJUUser currentUser].isLogin) {
            [_refreshControl beginRefreshing];
            [self reloadNews];
        }
    }
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
    
    self.request = [ZJUUserFavoriteRequest request];
    self.request.session = [ZJUUser currentUser].session;
    __block typeof(self) this = self;
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [this.newsItems removeAllObjects];
            [this.newsItems addObjectsFromArray:this.request.response.newsArray];
            [this.tableView reloadData];
            [ZJUFavoriteManager initializeWithNewsArray:this.request.response.newsArray];
            
            if (this.request.response.newsArray.count == 20)
                this->_loadMoreView.loadingState = ZJULoadMoreViewStateMayHaveMore;
            else
                this->_loadMoreView.loadingState = ZJULoadMoreViewStateNoMore;
        }
        else {
            this->_loadMoreView.loadingState = ZJULoadMoreViewStateError;
        }
        this.request = nil;
        [this->_refreshControl endRefreshing];
    }];
}

- (void)appendNews
{
    if (self.request.isLoading)
        return;
    
    _loadMoreView.loadingState = ZJULoadMoreViewStateLoading;
    
    self.request = [ZJUUserFavoriteRequest request];
    self.request.session = [ZJUUser currentUser].session;
    __block typeof(self) this = self;
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [this.newsItems addObjectsFromArray:this.request.response.newsArray];
            [this.tableView reloadData];
            
            if (this.request.response.newsArray.count == 20)
                this->_loadMoreView.loadingState = ZJULoadMoreViewStateMayHaveMore;
            else
                this->_loadMoreView.loadingState = ZJULoadMoreViewStateNoMore;
        }
        else {
           this->_loadMoreView.loadingState = ZJULoadMoreViewStateError;
        }
        this.request = nil;
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"我的收藏";
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    NSInteger comment = [[item objectForKey:@"n"] intValue];
    if (comment == 0)
        return 44.0;
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
    
    cell.textLabel.text = [item valueForKey:@"t"];;
    cell.detailTextLabel.text = [item valueForKey:@"c"];
    cell.userName = [item valueForKey:@"u"];
    NSInteger comment = [[item objectForKey:@"n"] intValue];
    cell.comment.text = (comment == 0) ? @"＋" : [NSString stringWithFormat:@"%d 评论",comment];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    NSString *urlString = [item valueForKey:@"f"];
    if (!urlString) {
        urlString = [NSString stringWithFormat:@"http://news.izju.org/cate/campus/%d/full.html",[[item objectForKey:@"id"] intValue]];
    }
    
    ZJUInfoDetailViewController *detail = [[ZJUInfoDetailViewController alloc] init];
    detail.url = [NSURL URLWithString:urlString];
    [self.navigationController pushViewController:detail
                                         animated:YES];
    [detail release];
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
