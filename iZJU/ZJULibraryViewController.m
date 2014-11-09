//
//  ZJULibraryViewController.m
//  iZJU
//
//  Created by ricky on 13-8-23.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJULibraryViewController.h"
#import "ZJUBookDetailViewController.h"
#import "ZJULibraryBook.h"
#import "ZJULibraryItem.h"
#import "ZJULibraryCell.h"
#import "GDataXMLNode.h"
#import "Toast+UIView.h"
#import "SVProgressHUD.h"
#import "ODRefreshControl.h"
#import "UIView+iZJU.h"
#import "ZBarReaderController.h"
#import "ZBarReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <SDWebImage/UIImageView+WebCache.h>


static NSString *const ZJU_LIBRARY_HOST = @"http://webpac.zju.edu.cn";
static NSString *const ZJU_LIBRARY_NEW_BOOKS_HOST = @"http://webpac.zju.edu.cn/cgi-bin/newbook.cgi?base=ALL&cls=ALL";
/*
 <select name="find_code" id="find_code">
 <option value="WRD">所有字段</option>
 <option value="WTI" selected="">题名关键词</option>
 <option value="TIT">题名(精确匹配）</option>
 <option value="WAU">著者</option>
 <option value="WSU">主题词</option>
 <option value="WPU">出版社</option>
 <option value="ISS">ISSN</option>
 <option value="ISB">ISBN</option>
 <option value="CAL">索书号</option>
 <option value="SYS">书目号</option>
 <option value="BAR">条形码</option>
 <option value="TAG">用户标签</option>
 </select>
 */
static NSString *const ZJU_LIBRARY_SEARCH_OPTION[] = {@"wrd",@"wti",@"tit",@"wau",@"wsu",@"wpu",@"iss",@"isb",@"cal",@"sys",@"bar",@"tag"};

typedef enum {
    ZJULibrarySearchOptionAllField              = 0,
    ZJULibrarySearchOptionBookTitleKeyword,
    ZJULibrarySearchOptionBookTitleFullMatch,
    ZJULibrarySearchOptionAuthor,
    ZJULibrarySearchOptionTheme,
    ZJULibrarySearchOptionPublich,
    ZJULibrarySearchOptionISSN,
    ZJULibrarySearchOptionISBN,
    ZJULibrarySearchOptionLocationID,
    ZJULibrarySearchOptionBookID,
    ZJULibrarySearchOptionBarCode,
    ZJULibrarySearchOptionUserTag,
} ZJULibrarySearchOption;

static NSString *const ZJU_LIBRARY_TYPE[] = {@"zju01", @"zju09"};
typedef enum {
    ZJULibraryTypeChinese   = 0,
    ZJULibraryTypeForeign   = 1,
} ZJULibraryType;

@interface ZJULibraryViewController () <UISearchBarDelegate, UISearchDisplayDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate>
{
    NSUInteger                   _datasetNumber;
    
    NSUInteger                   _currentPage;
    NSUInteger                   _totalNumberOfResults;
    
    ZJULibrarySearchOption       _currentOption;
    
    BOOL                         _hasMoreData;
    
    ODRefreshControl           * _refreshControl;
}
@property (nonatomic, retain) GDataXMLDocument *document;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain, readonly) NSMutableArray *bookArray;
@property (nonatomic, retain) ZJULibraryBook *bookToSearch;

- (NSURL*)buildFindURLWithKey:(NSString*)searchKey
                       option:(ZJULibrarySearchOption)option
               andLibraryType:(ZJULibraryType)type;
- (NSURL*)buildPresentURLWithDataset:(NSUInteger)dataset page:(NSUInteger)page size:(NSUInteger)size;
- (NSURL*)buildItemURLWithDocID:(NSString*)ID;
- (void)loadDataWithSearchKey:(NSString*)searchKey
                       option:(ZJULibrarySearchOption)option
                     andScope:(NSInteger)scope;
- (void)loadItemWithDocumentID:(NSString*)ID;
- (void)searchBookDetail:(ZJULibraryBook*)book;
- (void)addSearchWordToHistroy:(NSString*)word;
- (NSMutableArray*)searchHistory;

- (void)loadNewBooks;
- (void)showDetail:(ZJULibraryBook*)book;

- (void)onScan:(id)sender;
@end

@implementation ZJULibraryViewController
@synthesize document = _document;
@synthesize bookArray = _bookArray;

- (void)dealloc
{
    [_refreshControl release];
    self.document = nil;
    self.request = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"图书馆";
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(onScan:)];
    self.navigationItem.rightBarButtonItem = scanItem;
    [scanItem release];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.scopeButtonTitles = @[@"中文书库", @"外文书库"];
    searchBar.delegate = self;
    searchBar.placeholder = @"好好学习，天天向上！";
    searchBar.barStyle = UIBarStyleBlack;
    if (IS_IOS_7)
        searchBar.tintColor = [UIColor whiteColor];
    [searchBar sizeToFit];
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                                    contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    
    [searchBar release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
     _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
     [_refreshControl addTarget:self
     action:@selector(loadNewBooks)
     forControlEvents:UIControlEventValueChanged];
     */
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]] autorelease];
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    
    
    //[self loadNewBooks];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController)
        [self.searchDisplayController setActive:NO
                                       animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)onScan:(id)sender
{
    ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
    reader.readerDelegate = self;
    //reader.cameraMode = ZBarReaderControllerCameraModeSequence;
    reader.tracksSymbols = YES;
    UIImageView *image = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan.png"]] autorelease];
    UIImageView *scanLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x-ray.png"]] autorelease];
    scanLine.center = CGPointMake(image.width / 2, 16);
    [image addSubview:scanLine];
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         scanLine.center = CGPointMake(scanLine.center.x, scanLine.center.y + 180);
                     }
                     completion:NULL];
    image.center = CGPointMake(160, 180);
    reader.cameraOverlayView = image;
    reader.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentModalViewController:reader
                            animated:YES];
    UIToolbar *toolbar = [[[reader valueForKeyPath:@"controls"] subviews] lastObject];
    NSMutableArray *items = [[[toolbar items] mutableCopy] autorelease];
    [items removeLastObject];
    toolbar.items = items;
    
    [reader release];
}

#pragma mark - Methods

- (void)loadNewBooks
{
    if (_refreshControl.refreshing)
        return;
    
    [_refreshControl beginRefreshing];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:ZJU_LIBRARY_NEW_BOOKS_HOST]];
    request.timeOutSeconds = 4.0;
    __block typeof(self) weakSelf = self;
    [request setCompletionBlock:^{
        NSError *error = nil;
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"newbook\\((.+)\\);"
                                                                             options:NSRegularExpressionDotMatchesLineSeparators
                                                                               error:&error];
        NSArray *matches = [reg matchesInString:request.responseString
                                        options:0
                                          range:NSMakeRange(0, request.responseString.length)];
        NSTextCheckingResult *result = [matches lastObject];
        NSString *jsonStr = [request.responseString substringWithRange:[result rangeAtIndex:1]];
        reg = [NSRegularExpression regularExpressionWithPattern:@"([0-9a-z]+?):"
                                                        options:NSRegularExpressionDotMatchesLineSeparators
                                                          error:&error];
        NSMutableString *mutStr = [jsonStr mutableCopy];
        [reg replaceMatchesInString:mutStr
                            options:0
                              range:NSMakeRange(0, mutStr.length)
                       withTemplate:@"\"$1\":"];
        
        id JSON = [NSJSONSerialization JSONObjectWithData:[mutStr dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingAllowFragments
                                                    error:&error];
        NSLog(@"%@", JSON);
        [mutStr release];
        [weakSelf->_refreshControl endRefreshing];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"新书加载失败！"];
        [weakSelf->_refreshControl endRefreshing];
    }];
    [request startAsynchronous];
}

- (void)addSearchWordToHistroy:(NSString *)word
{
    NSMutableArray *history = [self searchHistory];
    if (history.count == 0)
        [history addObject:word];
    else if (![history containsObject:word])
        [history insertObject:word
                      atIndex:0];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSMutableArray*)searchHistory
{
    return [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"ZJULibrarySearchHistoryKey"];
}

- (NSMutableArray*)bookArray
{
    if (!_bookArray) {
        _bookArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return _bookArray;
}

- (void)loadDataOfPage:(NSUInteger)page
{
    if (_totalNumberOfResults <= page * 20)
        return;
    _currentPage = page;
    
    NSURL *url = [self buildPresentURLWithDataset:_datasetNumber
                                             page:_currentPage
                                             size:20];
    
    self.request = [ASIHTTPRequest requestWithURL:url];
    self.request.timeOutSeconds = 6.0f;
    __block typeof(self) weakSelf = self;
    [self.request setCompletionBlock:^{
        NSError *error = nil;
        weakSelf->_document = [[GDataXMLDocument alloc] initWithData:weakSelf.request.responseData
                                                             options:0
                                                               error:&error];
        if (weakSelf->_currentPage == 0) {
            [weakSelf.bookArray removeAllObjects];
        }
        
        NSArray *records = [[weakSelf->_document rootElement] elementsForName:@"record"];
        for (GDataXMLElement *element in records) {
            ZJULibraryBook *book = [ZJULibraryBook bookWithXMLElement:element];
            NSLog(@"%@", book);
            [weakSelf.bookArray addObject:book];
        }
        [weakSelf->_document release];
        weakSelf->_document = nil;
        
        weakSelf->_hasMoreData = weakSelf.bookArray.count < weakSelf->_totalNumberOfResults;
        [UIView setAnimationsEnabled:NO];
        [weakSelf.searchDisplayController.searchResultsTableView reloadData];
        [UIView setAnimationsEnabled:YES];
        [SVProgressHUD dismiss];
    }];
    [self.request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"网络失败"];
    }];
    [self.request startAsynchronous];
}

- (void)loadDataWithSearchKey:(NSString *)searchKey
                       option:(ZJULibrarySearchOption)option
                     andScope:(NSInteger)scope
{
    _currentOption = option;
    
    if (self.request.isExecuting)
        [self.request clearDelegatesAndCancel];
    
    [self addSearchWordToHistroy:searchKey];
    
    [SVProgressHUD showWithStatus:@"搜索中..."];
    
    NSURL *url = [self buildFindURLWithKey:searchKey
                                    option:option
                            andLibraryType:scope];
    self.request = [ASIHTTPRequest requestWithURL:url];
    self.request.timeOutSeconds = 6.0f;
    __block typeof(self) weakSelf = self;
    [self.request setCompletionBlock:^{
        NSError *error = nil;
        GDataXMLDocument *tmpDoc = [[GDataXMLDocument alloc] initWithData:weakSelf.request.responseData
                                                                  options:0
                                                                    error:&error];
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"xml解析错误"];
            [tmpDoc release];
            return;
        }
        
        GDataXMLElement *find = [tmpDoc rootElement];
        NSLog(@"%@",[find XMLString]);
        
        for (GDataXMLNode *node in find.children) {
            if ([node.name isEqualToString:@"set_number"])
                weakSelf->_datasetNumber = [[node stringValue] integerValue];
            else if ([node.name isEqualToString:@"no_entries"])
                weakSelf->_totalNumberOfResults = [[node stringValue] integerValue];
            else if ([node.name isEqualToString:@"error"]) {
                [weakSelf.bookArray removeAllObjects];
                weakSelf->_hasMoreData = NO;
                [weakSelf.searchDisplayController.searchResultsTableView reloadData];
                [tmpDoc release];
                [SVProgressHUD dismiss];
                return;
            }
        }
        [tmpDoc release];
        
        [weakSelf loadDataOfPage:0];
    }];
    [self.request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"网络失败"];
    }];
    [self.request startAsynchronous];
}

- (void)loadDataWithSearchKey:(NSString *)searchKey
                     andScope:(NSInteger)scope
{
    [self loadDataWithSearchKey:searchKey
                         option:ZJULibrarySearchOptionBookTitleKeyword
                       andScope:scope];
}

- (void)loadItemWithDocumentID:(NSString *)ID
{
    [SVProgressHUD showWithStatus:@"正在查询..."];
    
    NSURL *url = [self buildItemURLWithDocID:ID];
    self.request = [ASIHTTPRequest requestWithURL:url];
    self.request.timeOutSeconds = 6.0f;
    __block typeof(self) weakSelf = self;
    [self.request setCompletionBlock:^{
        NSError *error = nil;
        GDataXMLDocument *tmpDoc = [[GDataXMLDocument alloc] initWithData:weakSelf.request.responseData
                                                                  options:0
                                                                    error:&error];
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"xml解析错误"];
            [tmpDoc release];
            return;
        }
        
        GDataXMLElement *find = [tmpDoc rootElement];
        [tmpDoc autorelease];
        
        NSArray *itemElements = [find elementsForName:@"item"];
        NSMutableArray *mulArr = [NSMutableArray arrayWithCapacity:itemElements.count];
        for (GDataXMLElement *el in itemElements) {
            ZJULibraryItem *item = [ZJULibraryItem itemWithXMLElement:el];
            [mulArr addObject:item];
        }
        weakSelf.bookToSearch.items = [NSArray arrayWithArray:mulArr];
        
        [weakSelf showDetail:weakSelf.bookToSearch];
        
        [SVProgressHUD dismiss];
    }];
    [self.request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"查询失败"];
    }];
    [self.request startAsynchronous];
}

- (void)searchBookDetail:(ZJULibraryBook *)book
{
    self.bookToSearch = book;
    [self loadItemWithDocumentID:book.bookID];
}

- (NSURL*)buildFindURLWithKey:(NSString *)searchKey
                       option:(ZJULibrarySearchOption)option
               andLibraryType:(ZJULibraryType)type
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/X?op=find&base=%@&code=%@&request=%@", ZJU_LIBRARY_HOST, ZJU_LIBRARY_TYPE[type], ZJU_LIBRARY_SEARCH_OPTION[option], searchKey];
    return [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL*)buildPresentURLWithDataset:(NSUInteger)dataset
                                page:(NSUInteger)page
                                size:(NSUInteger)size
{
    NSMutableArray *entry = [NSMutableArray arrayWithCapacity:size];
    for (int i=0; i < size; ++i) {
        [entry addObject:@(page * size + i + 1)];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/X?op=present&set_no=%d&set_entry=%@&format=marc", ZJU_LIBRARY_HOST, dataset, [entry componentsJoinedByString:@","]];
    return [NSURL URLWithString:urlStr];
}

- (NSURL*)buildItemURLWithDocID:(NSString *)ID
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/X?op=item-data&base=%@&doc_number=%@", ZJU_LIBRARY_HOST, (self.searchDisplayController.searchBar.selectedScopeButtonIndex == ZJULibraryTypeChinese) ? @"zju01" : @"zju09", ID];
    return [NSURL URLWithString:urlStr];
}

- (void)showDetail:(ZJULibraryBook *)book
{
    ZJUBookDetailViewController *detail = [[ZJUBookDetailViewController alloc] init];
    detail.book = book;
    [self.navigationController pushViewController:detail
                                         animated:YES];
    [detail release];
}

#pragma mark - UISearchDisplay Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller
willUnloadSearchResultsTableView:(UITableView *)tableView
{
    [self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSCharacterSet *space = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *text = [controller.searchBar.text stringByTrimmingCharactersInSet:space];
    if (text.length > 0)
        [self loadDataWithSearchKey:controller.searchBar.text
                             option:_currentOption
                           andScope:searchOption];
    return NO;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSCharacterSet *space = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *text = [searchBar.text stringByTrimmingCharactersInSet:space];
    if (text.length > 0)
        [self loadDataWithSearchKey:searchBar.text
                           andScope:searchBar.selectedScopeButtonIndex];
}

#pragma mark - UITable Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.bookArray.count;
    }
    else {
        return [self searchHistory].count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView == tableView)
        return 44.0f;
    return 96.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
        return 20.0f;
    return 0.0f;
}
- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView)
        return @"搜索历史";
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView == self.tableView;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *history = [self searchHistory];
        [history removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[[ZJULibraryCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"Cell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.numberOfLines = 3;
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
        
        if ((indexPath.row > (self.bookArray.count - 3)) && _hasMoreData && !self.request.isExecuting)
            [self loadDataOfPage:_currentPage + 1];
        
        ZJULibraryBook *book = [self.bookArray objectAtIndex:indexPath.row];
        cell.textLabel.text = book.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"作者：%@\n出版社：%@\n描述：%@", book.author, book.publish, book.summary];
        [cell.imageView setImageWithURL:[NSURL URLWithString:book.coverImage]
                       placeholderImage:[UIImage imageNamed:@"placeholder-book.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  
                              }];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:@"HistoryCell"] autorelease];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.textLabel.text = self.searchHistory[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ZJULibraryBook *book = self.bookArray[indexPath.row];
        if (!book.items)
            [self searchBookDetail:book];
        else {
            [self showDetail:book];
        }
    }
    else {
        
        [self.searchDisplayController setActive:YES
                                       animated:YES];
        
        self.searchDisplayController.searchBar.text = self.searchHistory[indexPath.row];
        //[self.searchDisplayController.searchBar resignFirstResponder];
        
        [self loadDataWithSearchKey:self.searchDisplayController.searchBar.text
                             option:ZJULibrarySearchOptionAllField
                           andScope:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
        
    }
}

#pragma mark - ZBarReader Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    ZBarReaderViewController *readController = (ZBarReaderViewController*)picker;
    [readController dismissModalViewControllerAnimated:YES];
    
    ZBarSymbolSet *symbolSet = [info objectForKey:ZBarReaderControllerResults];
    for (ZBarSymbol *symbol in symbolSet) {
        if (symbol.type == ZBAR_ISBN13 ||
            symbol.type == ZBAR_ISBN10 ||
            symbol.type == ZBAR_EAN13) {
            [self.searchDisplayController setActive:YES];
            self.searchDisplayController.searchBar.text = symbol.data;
            [self loadDataWithSearchKey:symbol.data
                                 option:ZJULibrarySearchOptionISBN
                               andScope:0];
            break;
        }
    }
}

- (void)readerControllerDidFailToRead:(ZBarReaderController *)reader
                            withRetry:(BOOL)retry
{
    
}

@end
