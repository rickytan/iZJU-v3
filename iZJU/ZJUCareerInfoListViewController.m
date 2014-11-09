//
//  ZJUCareerInfoListViewController.m
//  iZJU
//
//  Created by ricky on 13-6-12.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCareerInfoListViewController.h"
#import "ZJUInfoListCell.h"
#import "ZJUInfoDetailViewController.h"
#import "ZJURequest.h"
#import "ZJULoadMoreView.h"
#import "UIView+iZJU.h"
#import "ODRefreshControl.h"

static NSString *const ZJUCareerInfoLastRequestTimestampKey = @"ZJUCareerInfoLastRequestTimestampKey";

@interface ZJUCareerInfoListViewController () <ZJUInfoListCellDelegate>
{
    ZJULoadMoreView             * _loadMoreView;
    ODRefreshControl            * _refreshControl;
    
}
@property (nonatomic, retain) ZJUCareerListRequest *request;
@property (nonatomic, readonly) NSMutableArray *newsItems;
@property (nonatomic, retain) NSDate *requestTimestamp;
- (void)reloadNews;
- (void)appendNews;
- (void)onReload:(id)sender;
- (void)onLoadMore:(id)sender;
@end

@implementation ZJUCareerInfoListViewController
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
        self.type = CareerInfoTypeAll;
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
    
    self.request = [ZJUCareerListRequest request];
    self.request.timestamp = self.requestTimestamp;
    if (self.type != CareerInfoTypeAll)
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
    
    self.request = [ZJUCareerListRequest request];
    self.request.page = self.newsItems.count / 20;
    self.request.timestamp = self.requestTimestamp;
    if (self.type != CareerInfoTypeAll)
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
        cell.delegate = self;
    }
    // Configure the cell...
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item valueForKey:@"title"];;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"截止时间：%@",[item valueForKey:@"deadline"]];
    cell.userName = [item valueForKey:@"zptype"];
    cell.comment.text = [NSString stringWithFormat:@"%@ 点击",[item objectForKey:@"clicks"]];
    if ([[item objectForKey:@"verified"] boolValue])
        cell.badgeImage.image = [UIImage imageNamed:@"rz.png"];
    else
        cell.badgeImage.image = nil;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.newsItems objectAtIndex:indexPath.row];
    NSString *urlStr = [item objectForKey:@"url"];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"+"
                                               withString:@"%2B"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ZJUInfoDetailViewController *detail = [[ZJUInfoDetailViewController alloc] init];
    detail.empolyItem = item;
    [self.navigationController pushViewController:detail
                                         animated:YES];
    [detail release];
    
    [[ZJUVisitRequest requestWithURL:url] visit];
}

#pragma mark - ZJUInfoCell delegate

- (void)infoListCellDidTapComment:(ZJUInfoListCell *)cell
{
    
}

- (void)infoListCellDidTapUsername:(ZJUInfoListCell *)cell
{
    if (self.type != CareerInfoTypeAll)
        return;
    
    static NSString *types[] = {@"一般招聘",@"实习实训",@"重要央企",@"事业单位",@"军工集团",@"高校招聘",@"博士后招聘",@"海外升学就业"};
    
    CareerInfoType type = CareerInfoTypeAll;
    int i = 0;
    for (; i < 8; i++) {
        if ([cell.userName isEqualToString:types[i]]) {
            type = i;
            break;
        }
    }
    
    ZJUCareerInfoListViewController *career = [[ZJUCareerInfoListViewController alloc] init];
    career.type = type;
    career.title = types[i];
    [self.navigationController pushViewController:career
                                         animated:YES];
    [career release];
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
