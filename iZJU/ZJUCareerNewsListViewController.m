//
//  ZJUCareerInfoListViewController.m
//  iZJU
//
//  Created by ricky on 13-6-12.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCareerNewsListViewController.h"
#import "ZJUInfoListCell.h"
#import "ZJUInfoDetailViewController.h"
#import "ZJURequest.h"
#import "ZJULoadMoreView.h"
#import "UIView+iZJU.h"
#import "ODRefreshControl.h"

static NSString *const ZJUCareerNewsLastRequestTimestampKey = @"ZJUCareerNewsLastRequestTimestampKey";

@interface ZJUCareerNewsListViewController () <ZJUInfoListCellDelegate>
{
    ZJULoadMoreView             * _loadMoreView;
    ODRefreshControl            * _refreshControl;

}
@property (nonatomic, retain) ZJUCareerNewsRequest *request;
@property (nonatomic, readonly) NSMutableArray *newsItems;
@property (nonatomic, retain) NSDate *requestTimestamp;
- (void)reloadNews;
- (void)appendNews;
- (void)onReload:(id)sender;
- (void)onLoadMore:(id)sender;
@end

@implementation ZJUCareerNewsListViewController
@synthesize newsItems = _newsItems;

- (void)dealloc
{
    [self.request cancel];
    self.request = nil;
    
    [_newsItems release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.type = CareerNewsTypeNotice;
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
    
    self.request = [ZJUCareerNewsRequest request];
    self.request.timestamp = self.requestTimestamp;
    self.request.type = self.type;
    __block typeof(self) this = self;
    [self.request startRequestWithCompleteHandler:^(ZJURequest *r) {
        if (r.response.errorCode == 0) {
            [this.newsItems removeAllObjects];
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
        [this->_refreshControl endRefreshing];
    }];
}

- (void)appendNews
{
    if (self.request.isLoading)
        return;
    
    _loadMoreView.loadingState = ZJULoadMoreViewStateLoading;
    
    self.request = [ZJUCareerNewsRequest request];
    self.request.page = self.newsItems.count / 20;
    self.request.timestamp = self.requestTimestamp;
    self.request.type = self.type;
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
    
    cell.textLabel.text = [item valueForKey:@"xwbt"];;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"发布时间：%@",[item valueForKey:@"fbsj"]];
    NSString *clicks = [item objectForKey:@"djsl"];
    if (!clicks || [clicks isKindOfClass:[NSNull class]])
        cell.comment.text = @"0 点击";
    else
        cell.comment.text = [NSString stringWithFormat:@"%@ 点击",clicks];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    NSString *urlStr = [item objectForKey:@"xwdz"];
    
    ZJUInfoDetailViewController *detail = [[ZJUInfoDetailViewController alloc] init];
    if ([urlStr isEqualToString:@"http://"]) {
        NSString *ID = [item objectForKey:@"xwbh"];
        urlStr = [NSString stringWithFormat:@"http://www.career.zju.edu.cn/ejob/lm_detail_index.do?pkValue=%@", ID];
        detail.url = [NSURL URLWithString:urlStr];
        detail.htmlTemplate = @"news.html";
    }
    else {
        detail.directURL = [NSURL URLWithString:urlStr];
    }
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
